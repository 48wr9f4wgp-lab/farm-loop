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
    _ok(packed != null,"v1.4 main scene loads")
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
    scene.call("_show_tab","village")
    await process_frame
    await process_frame

    _ok(_has_text(scene,"今日の村"),"village leads with daily village hero")
    _ok(_has_text(scene,"納品OK"),"village surfaces ready delivery state")
    _ok(_has_text(scene,"美緒"),"requester identity is visible")
    _ok(_has_text(scene,"必要："),"request need is visible")
    _ok(_has_text(scene,"雪里の人々"),"relationship section is visible")
    _ok(_has_text(scene,"匠") and _has_text(scene,"源"),"all core villagers are visible")
    var delivery := _find_button(scene,"へ納品")
    _ok(delivery != null and delivery.custom_minimum_size.y >= 50.0,"delivery CTA keeps mobile tap target")
    _ok(delivery != null and not delivery.disabled,"ready request delivery CTA is enabled")

    print("V1.4 VILLAGE TESTS COMPLETE failures=",failures)
    scene.queue_free()
    quit(1 if failures > 0 else 0)
