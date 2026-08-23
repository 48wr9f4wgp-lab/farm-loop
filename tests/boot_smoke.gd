extends SceneTree

var failures := 0

func fail_test(message: String) -> void:
    failures += 1
    printerr("FAIL: ", message)

func mark_pass(message: String) -> void:
    print("PASS: ", message)

func _init() -> void:
    var packed := load("res://main.tscn") as PackedScene
    if packed == null:
        fail_test("main.tscn load")
        quit(1)
        return
    mark_pass("main.tscn load")

    var scene := packed.instantiate()
    if scene == null:
        fail_test("main scene instantiate")
        quit(1)
        return
    mark_pass("main scene instantiate")
    root.add_child(scene)

    await process_frame
    await process_frame
    mark_pass("main scene ready")

    for tab in ["farm", "work", "market", "village", "farm"]:
        scene.call("_show_tab", tab)
        await process_frame
        mark_pass("tab " + tab)

    var state: Variant = scene.get("state")
    if typeof(state) != TYPE_DICTIONARY:
        fail_test("state dictionary")
    else:
        mark_pass("state dictionary")
        if not state.has("settings") or not state.has("ui"):
            fail_test("v0.3 fields")
        else:
            mark_pass("v0.3 fields")

    print("BOOT SMOKE COMPLETE failures=", failures)
    scene.queue_free()
    quit(1 if failures else 0)
