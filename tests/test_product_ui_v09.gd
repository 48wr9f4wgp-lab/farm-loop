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

    _ok(_count_exact_labels(scene,"今いる場所") == 0,"legacy duplicate location card removed")
    var selected_button = scene.get("selected_action_button")
    _ok(selected_button is Button,"primary facility action exists")
    if selected_button is Button:
        _ok(selected_button.custom_minimum_size.y >= 50.0,"primary action keeps mobile tap target")

    print("3D PRODUCT UI CONTRACT COMPLETE failures=",failures)
    scene.queue_free()
    quit(1 if failures > 0 else 0)
