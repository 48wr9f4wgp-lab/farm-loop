extends SceneTree

var failures: int = 0

func _ok(condition: bool, message: String) -> void:
    if condition:
        print("PASS: ",message)
    else:
        failures += 1
        printerr("FAIL: ",message)

func _count_exact_labels(root_node: Node, target: String) -> int:
    var count: int = 0
    if root_node is Label and str(root_node.text) == target:
        count += 1
    for child in root_node.get_children():
        count += _count_exact_labels(child,target)
    return count

func _find_named(root_node: Node, target: String) -> Node:
    if str(root_node.name) == target:
        return root_node
    for child in root_node.get_children():
        var found := _find_named(child,target)
        if found != null:
            return found
    return null

func _init() -> void:
    var packed := load("res://main.tscn") as PackedScene
    _ok(packed != null,"current main scene loads")
    if packed == null:
        quit(1)
        return
    var scene := packed.instantiate()
    _ok(scene != null,"current main scene instantiates")
    if scene == null:
        quit(1)
        return
    root.add_child(scene)
    await process_frame
    await process_frame

    scene.call("_show_tab","farm")
    await process_frame
    await process_frame

    var map_value = scene.get("map")
    _ok(map_value != null,"farm map exists")
    if map_value != null:
        _ok(bool(map_value.get("is_3d_diorama")),"3D diorama farm map active")
        _ok(map_value.get("viewport_3d") is SubViewport,"farm hero owns 3D viewport")
        _ok(map_value.get("camera") is Camera3D,"farm hero owns 3D camera")
        _ok(str(map_value.get_script().resource_path).ends_with("circulation_board_v5.gd"),"M5 direct-world interaction layer is active")
        _ok(map_value.has_method("set_chain_preview"),"M5 board can visualize predicted ecological chains")

    _ok(_count_exact_labels(scene,"今いる場所") == 0,"legacy duplicate location card removed")
    var selected_button = scene.get("selected_action_button")
    _ok(selected_button == null or not (selected_button is Button and selected_button.visible),"legacy primary facility CTA is absent from V4 default state")
    _ok(_find_named(scene,"V4InterventionTray") == null,"context tray stays hidden until player selects land")
    _ok(_find_named(scene,"V4RecoveryLabel") != null,"V4 compact recovery status is visible")
    _ok(_find_named(scene,"V4ActionPointsLabel") != null,"V4 monthly action budget is visible")

    print("3D PRODUCT UI V4 M5 CONTRACT COMPLETE failures=",failures)
    scene.queue_free()
    await process_frame
    quit(1 if failures > 0 else 0)
