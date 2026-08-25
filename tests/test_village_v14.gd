extends SceneTree

const GameDataClass = preload("res://scripts/core/game_data.gd")
const GameStateClass = preload("res://scripts/core/game_state.gd")
const RulesV14Class = preload("res://scripts/core/game_rules_v14.gd")

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
    var rules = RulesV14Class.new(data)
    var state: Dictionary = GameStateClass.create(data)
    var request: Dictionary = data.get_table("requests")[0].duplicate(true)
    request["done"] = false

    var status_missing: Dictionary = rules.request_status(state,request)
    _ok(not bool(status_missing["ready"]),"request reports missing inventory")
    _ok(not str(status_missing["missing"]).is_empty(),"request explains missing items")

    state["inventory"]["eggs"] = 5
    var status_ready: Dictionary = rules.request_status(state,request)
    _ok(bool(status_ready["ready"]),"request becomes ready when inventory is sufficient")

    _ok(str(rules.relation_progress(0)["tier"]) == "知り合い","relationship starts at acquaintance")
    _ok(str(rules.relation_progress(10)["tier"]) == "顔なじみ","relationship tier advances at 10")
    _ok(str(rules.relation_progress(25)["tier"]) == "頼れる相手","relationship tier advances at 25")
    _ok(str(rules.relation_progress(50)["tier"]) == "里山の仲間","relationship tier advances at 50")

    var packed := load("res://main.tscn") as PackedScene
    _ok(packed != null,"current main scene loads for village contract")
    if packed == null:
        quit(1)
        return
    var scene = packed.instantiate()
    root.add_child(scene)
    await process_frame
    await process_frame

    var scene_state: Dictionary = scene.get("state")
    var scene_data = scene.get("data")
    var ui_request: Dictionary = scene_data.get_table("requests")[0].duplicate(true)
    ui_request["done"] = false
    scene_state["village_requests"] = [ui_request]
    scene_state["inventory"]["eggs"] = 5

    # Guided village beat: purpose/request only, not the whole management UI.
    scene_state["ftue_v2"]["step"] = 7
    scene_state["ftue_v2"]["active"] = true
    scene_state["ftue_v2"]["completed"] = false
    scene.call("_show_tab","village")
    await process_frame
    await process_frame

    _ok(_has_text(scene,"今日の村"),"guided village leads with daily village hero")
    _ok(_has_text(scene,"納品OK"),"guided village surfaces ready delivery state")
    _ok(_has_text(scene,"美緒"),"guided request shows requester identity")
    _ok(_has_text(scene,"必要："),"guided request need is visible")
    _ok(_has_text(scene,"入手先：農場の雪国鶏舎"),"starter request tells player where the item comes from")
    _ok(not _has_text(scene,"雪里の人々"),"guided beat hides relationship management noise")
    var delivery := _find_button(scene,"へ納品")
    _ok(delivery != null and delivery.custom_minimum_size.y >= 50.0,"delivery CTA keeps mobile tap target")

    # After FTUE, the complete village meta returns, including the safe test tool.
    scene_state["ftue_v2"]["step"] = 9
    scene_state["ftue_v2"]["active"] = false
    scene_state["ftue_v2"]["completed"] = true
    scene.call("_show_tab","village")
    await process_frame
    _ok(_has_text(scene,"雪里の人々"),"free play restores relationship section")
    _ok(_has_text(scene,"匠") and _has_text(scene,"源"),"free play shows all core villagers")
    _ok(_has_text(scene,"初回体験を最初から試す"),"free play exposes non-destructive FTUE test entry")

    print("CURRENT VILLAGE CONTRACT TESTS COMPLETE failures=",failures)
    scene.queue_free()
    quit(1 if failures > 0 else 0)
