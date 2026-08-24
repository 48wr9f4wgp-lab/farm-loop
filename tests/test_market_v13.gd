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

    var p1: Dictionary = rules.basket_preview(state,"roadside")
    var p2: Dictionary = rules.basket_preview(state,"roadside")
    _ok(int(p1["net"]) == int(p2["net"]),"market preview is deterministic")
    _ok(int(p1["items"]) == 9,"market preview counts basket items")
    _ok(rules.best_channel(state) == "roadside","level 1 recommends unlocked roadside channel")

    state["level"] = 4
    var best: String = rules.best_channel(state)
    _ok(best in ["roadside","restaurant","giftshop"],"best-channel recommendation stays valid")
    _ok(int(rules.basket_preview(state,best)["net"]) >= 0,"best-channel preview has nonnegative net")

    var packed := load("res://main.tscn") as PackedScene
    _ok(packed != null,"v1.3 main scene loads")
    if packed == null:
        quit(1)
        return
    var scene = packed.instantiate()
    root.add_child(scene)
    await process_frame
    await process_frame
    scene.call("_show_tab","market")
    await process_frame
    await process_frame

    _ok(_has_text(scene,"今日の出荷"),"market leads with shipment hero")
    _ok(_has_text(scene,"予想手取り"),"market shows net preview")
    _ok(_has_text(scene,"売り先を選ぶ"),"market exposes channel choice")
    _ok(_has_text(scene,"おすすめ"),"market surfaces recommendation")
    var sell_button := _find_button(scene,"まとめて出荷")
    _ok(sell_button != null and sell_button.custom_minimum_size.y >= 50.0,"batch shipment CTA keeps mobile tap target")

    print("V1.3 MARKET TESTS COMPLETE failures=",failures)
    scene.queue_free()
    quit(1 if failures > 0 else 0)
