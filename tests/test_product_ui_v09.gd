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
    _ok(packed != null,"v0.9 main scene loads")
    if packed == null:
        quit(1)
        return
    var scene := packed.instantiate()
    _ok(scene != null,"v0.9 main scene instantiates")
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
        _ok(str(map_value.get_script().resource_path).ends_with("farm_map_v09.gd"),"asset-first farm map active")
        _ok(map_value.get_child_count() > 0,"farm map has product art overlay")

    _ok(_count_exact_labels(scene,"今いる場所") == 0,"legacy duplicate location card removed")
    var selected_button = scene.get("selected_action_button")
    _ok(selected_button is Button,"primary facility action exists")
    if selected_button is Button:
        _ok(selected_button.custom_minimum_size.y >= 50.0,"primary action keeps mobile tap target")

    print("V0.9 PRODUCT UI TESTS COMPLETE failures=",failures)
    scene.queue_free()
    quit(1 if failures > 0 else 0)
