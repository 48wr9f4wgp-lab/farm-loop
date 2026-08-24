extends SceneTree

var failures: int = 0

func _ok(condition: bool, message: String) -> void:
    if condition:
        print("PASS: ",message)
    else:
        failures += 1
        printerr("FAIL: ",message)

func _has_text(root_node: Node, target: String) -> bool:
    if root_node is Label and target in str(root_node.text):
        return true
    if root_node is Button and target in str(root_node.text):
        return true
    for child in root_node.get_children():
        if _has_text(child,target):
            return true
    return false

func _init() -> void:
    var packed := load("res://main.tscn") as PackedScene
    _ok(packed != null,"v1.0 main scene loads")
    if packed == null:
        quit(1)
        return

    var scene = packed.instantiate()
    _ok(scene != null,"v1.0 main scene instantiates")
    if scene == null:
        quit(1)
        return
    root.add_child(scene)
    await process_frame
    await process_frame

    var root_box = scene.get("root_box")
    _ok(root_box != null,"product shell exists")
    if root_box != null and root_box.get_child_count() > 2:
        var secondary = root_box.get_child(2)
        _ok(not secondary.visible,"secondary metric row removed from hero")

    _ok(_has_text(scene,"YUKISATO"),"brand metadata visible")
    var map = scene.get("map")
    _ok(map != null,"farm map exists")
    if map != null:
        _ok(float(map.custom_minimum_size.y) >= 380.0,"farm map remains hero sized")

    var desc = scene.get("selected_desc_label")
    _ok(desc != null and not desc.visible,"facility paragraph hidden from first screen")

    scene.call("_show_tab","work")
    await process_frame
    _ok(_has_text(scene,"今日の山仕事"),"work tab has product hero")

    scene.call("_show_tab","market")
    await process_frame
    _ok(_has_text(scene,"今日の出荷"),"market tab has product hero")
    _ok(_has_text(scene,"まとめて出荷する"),"market has primary batch sell CTA")

    scene.call("_show_tab","village")
    await process_frame
    _ok(_has_text(scene,"村のお願い"),"village requests lead the tab")

    print("V1.0 PRODUCT UI TESTS COMPLETE failures=",failures)
    scene.queue_free()
    quit(1 if failures > 0 else 0)
