extends SceneTree

var failures: int = 0

func _ok(condition: bool, message: String) -> void:
    if condition:
        print("PASS: ",message)
    else:
        failures += 1
        printerr("FAIL: ",message)

func _find_script(root_node: Node, suffix: String) -> Node:
    if root_node.get_script() != null and str(root_node.get_script().resource_path).ends_with(suffix):
        return root_node
    for child in root_node.get_children():
        var found := _find_script(child,suffix)
        if found != null:
            return found
    return null

func _init() -> void:
    var packed := load("res://main.tscn") as PackedScene
    _ok(packed != null,"v1.5 main scene loads")
    if packed == null:
        quit(1)
        return
    var scene = packed.instantiate()
    root.add_child(scene)
    await process_frame
    await process_frame
    scene.call("_show_tab","farm")
    await process_frame
    await process_frame

    var map_value = scene.get("map")
    _ok(map_value is Control,"farm map exists")
    if map_value is Control:
        _ok(map_value.custom_minimum_size.y >= 385.0,"farm hero keeps minimum visual height")
        var polish := _find_script(map_value,"farm_polish_overlay_v15.gd")
        _ok(polish != null,"farm guidance polish overlay is attached")
        if polish is Control:
            _ok(polish.mouse_filter == Control.MOUSE_FILTER_IGNORE,"farm polish never steals touch input")

    var action = scene.get("selected_action_button")
    _ok(action is Button and action.custom_minimum_size.y >= 50.0,"farm CTA remains thumb-sized")

    print("V1.5 FARM FINAL TESTS COMPLETE failures=",failures)
    scene.queue_free()
    quit(1 if failures > 0 else 0)
