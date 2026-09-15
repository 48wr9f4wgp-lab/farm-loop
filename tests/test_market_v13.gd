extends SceneTree

const GameDataClass = preload("res://scripts/core/game_data.gd")
const GameStateClass = preload("res://scripts/core/game_state.gd")
const RulesV13Class = preload("res://scripts/core/game_rules_v13.gd")

var failures: int = 0

func _ok(condition: bool, message: String) -> void:
    if condition:
        print("PASS: ",message)
    else:
        failures += 1
        printerr("FAIL: ",message)

func _has_text(node: Node, target: String) -> bool:
    if node is Label and target in str(node.text): return true
    if node is Button and target in str(node.text): return true
    for child in node.get_children():
        if _has_text(child,target): return true
    return false

func _find_button(node: Node, target: String) -> Button:
    if node is Button and target in str(node.text): return node
    for child in node.get_children():
        var found := _find_button(child,target)
        if found != null: return found
    return null

func _init() -> void:
    var data = GameDataClass.new()
    var rules = RulesV13Class.new(data)
    var state: Dictionary = GameStateClass.create(data)
    state["inventory"]["eggs"] = 6
    state["inventory"]["taranome"] = 3

    # Legacy market math remains protected while selling is out of V3 proof.
    var p1: Dictionary = rules.basket_preview(state,"roadside")
    var p2: Dictionary = rules.basket_preview(state,"roadside")
    _ok(int(p1["net"]) == int(p2["net"]),"market preview remains deterministic")
    _ok(int(p1["items"]) == 9,"market preview counts basket items")
    _ok(rules.best_channel(state) == "roadside","level 1 recommendation remains valid")

    state["level"] = 4
    var best: String = rules.best_channel(state)
    _ok(best in ["roadside","restaurant","giftshop"],"best-channel recommendation remains valid")
    _ok(int(rules.basket_preview(state,best)["net"]) >= 0,"best-channel preview has nonnegative net")

    var packed := load("res://main.tscn") as PackedScene
    _ok(packed != null,"current main scene loads")
    if packed == null:
        quit(1)
        return
    var scene = packed.instantiate()
    root.add_child(scene)
    await process_frame
    await process_frame

    var runtime_state: Dictionary = scene.get("state")
    runtime_state["restoration_v3"]["proof_mode"] = true
    scene.call("_show_tab","market")
    await process_frame
    await process_frame
    _ok(_has_text(scene,"今は里山を蘇らせる"),"V3 proof de-emphasizes selling")
    _ok(not _has_text(scene,"売り先を選ぶ"),"V3 proof hides channel comparison")
    _ok(_find_button(scene,"農場へ戻る") != null,"V3 market redirect provides farm CTA")

    runtime_state["ftue_v3"]["step"] = 6
    runtime_state["ftue_v3"]["active"] = false
    runtime_state["ftue_v3"]["completed"] = true
    runtime_state["restoration_v3"]["proof_mode"] = false
    runtime_state["inventory"]["eggs"] = 6
    runtime_state["inventory"]["taranome"] = 3
    scene.call("_show_tab","market")
    await process_frame
    await process_frame

    _ok(_has_text(scene,"今日の出荷"),"legacy market hero remains available outside proof mode")
    _ok(_has_text(scene,"予想手取り"),"legacy market shows net preview")
    _ok(_has_text(scene,"売り先を選ぶ"),"legacy channel choice remains available")
    var sell_button := _find_button(scene,"まとめて出荷")
    _ok(sell_button != null and sell_button.custom_minimum_size.y >= 50.0,"legacy batch shipment CTA remains thumb-sized")

    print("V1.3 LEGACY MARKET + V3 PROOF TESTS COMPLETE failures=",failures)
    scene.queue_free()
    quit(1 if failures > 0 else 0)
