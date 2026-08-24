extends SceneTree

const GameDataClass = preload("res://scripts/core/game_data.gd")
const GameStateClass = preload("res://scripts/core/game_state.gd")
const RulesV12Class = preload("res://scripts/core/game_rules_v12.gd")

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
    var rules = RulesV12Class.new(data)
    var state: Dictionary = GameStateClass.create(data)
    rules.ensure_route_fields(state)

    for route_id in ["stream","beech","ridge"]:
        var before: int = int(state["entertainment"]["route_counts"][route_id])
        var result: Dictionary = rules.explore_route(state,route_id)
        _ok(bool(result.get("ok",false)),"route always advances: " + route_id)
        _ok(str(result.get("route","")) == route_id,"route result identifies choice: " + route_id)
        _ok(int(state["entertainment"]["route_counts"][route_id]) == before + 1,"route counter increments: " + route_id)

    for i in range(5):
        var result: Dictionary = rules.explore_route(state,"ridge")
        _ok(bool(result.get("ok",false)),"exploration has no energy dead-end %d" % i)

    var packed := load("res://main.tscn") as PackedScene
    _ok(packed != null,"current main scene loads")
    if packed == null:
        quit(1)
        return
    var scene = packed.instantiate()
    root.add_child(scene)
    await process_frame
    await process_frame

    # Current FTUE intentionally hides route choice until its mountain beat.
    var runtime_state: Dictionary = scene.get("state")
    runtime_state["ftue_v2"]["step"] = 6
    runtime_state["ftue_v2"]["active"] = true
    runtime_state["ftue_v2"]["completed"] = false
    scene.call("_show_tab","work")
    await process_frame
    await process_frame

    _ok(_has_text(scene,"今日の山道を選ぶ"),"mountain beat leads with route choice")
    _ok(_has_text(scene,"沢沿い"),"stream route visible")
    _ok(_has_text(scene,"ブナ林"),"beech route visible")
    _ok(_has_text(scene,"尾根"),"ridge route visible")
    _ok(not _has_text(scene,"山を探索する"),"generic lottery CTA removed")

    for label in ["沢沿い","ブナ林","尾根"]:
        var button := _find_button(scene,label)
        _ok(button != null and button.custom_minimum_size.y >= 50.0,"route tap target >=50px: " + label)

    print("V1.2 WORK ADVENTURE TESTS COMPLETE failures=",failures)
    scene.queue_free()
    quit(1 if failures > 0 else 0)
