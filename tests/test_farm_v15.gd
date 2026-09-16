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

        # V4 has no persistent facility CTA. The primary action appears only after
        # the player selects land in the 3D board.
        if map_value.has_signal("zone_selected"):
            map_value.emit_signal("zone_selected","stream")
            await process_frame
            await process_frame
        elif scene.has_method("_on_zone_selected"):
            scene.call("_on_zone_selected","stream")
            await process_frame

    var action = scene.get("context_action_button")
    _ok(action is Button and action.visible and action.custom_minimum_size.y >= 50.0,"V4 contextual farm action remains thumb-sized")

    print("FARM PRODUCT V4 CONTRACT TESTS COMPLETE failures=",failures)
    scene.queue_free()
    quit(1 if failures > 0 else 0)
