extends SceneTree

var failures: int = 0

func _ok(condition: bool, message: String) -> void:
    if condition:
        print("PASS: ",message)
    else:
        failures += 1
        printerr("FAIL: ",message)

func _visual_layers_ignore_input(root_node: Node) -> bool:
    for child in root_node.get_children():
        if child is Control and child.mouse_filter != Control.MOUSE_FILTER_IGNORE:
            return false
        if not _visual_layers_ignore_input(child):
            return false
    return true

func _find_button(node: Node, target: String) -> Button:
    if node is Button and target in str(node.text):
        return node
    for child in node.get_children():
        var found := _find_button(child,target)
        if found != null:
            return found
    return null

func _init() -> void:
    var packed := load("res://main.tscn") as PackedScene
    _ok(packed != null,"current main scene loads")
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
        _ok(_visual_layers_ignore_input(map_value),"farm visual layers never steal touch input")
        if map_value.has_method("play_action_feedback"):
            map_value.call("play_action_feedback","coop")
            _ok(str(map_value.get("action_facility")) == "coop","farm action feedback targets selected facility")
            _ok(float(map_value.get("action_timer")) > 0.0,"farm action feedback starts immediately")
        else:
            _ok(false,"farm exposes action feedback behavior")

        # V4 intentionally removes the persistent facility CTA. Drive the same
        # 3D tap path a player uses, then verify the contextual action target.
        if map_value.get("camera") is Camera3D:
            var camera: Camera3D = map_value.get("camera")
            var tap := InputEventMouseButton.new()
            tap.button_index = MOUSE_BUTTON_LEFT
            tap.pressed = true
            tap.position = camera.unproject_position(map_value.zone_world_position("stream") + Vector3(0,0.2,0))
            map_value._gui_input(tap)
            await process_frame
            await process_frame
            var action := _find_button(scene,"沢を整える")
            _ok(action is Button and action.custom_minimum_size.y >= 48.0,"V4 contextual farm action remains thumb-sized")
        else:
            _ok(false,"V4 board exposes a tappable 3D camera")

    print("FARM PRODUCT V4 CONTRACT TESTS COMPLETE failures=",failures)
    scene.queue_free()
    await process_frame
    quit(1 if failures > 0 else 0)
