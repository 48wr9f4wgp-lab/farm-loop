extends SceneTree

var failures := 0

func fail(message: String) -> void:
    failures += 1
    printerr("FAIL: ", message)

func pass(message: String) -> void:
    print("PASS: ", message)

func _init() -> void:
    var packed := load("res://main.tscn") as PackedScene
    if packed == null:
        fail("main.tscn load")
        quit(1)
        return
    pass("main.tscn load")

    var scene := packed.instantiate()
    if scene == null:
        fail("main scene instantiate")
        quit(1)
        return
    pass("main scene instantiate")
    root.add_child(scene)

    await process_frame
    await process_frame
    pass("main scene ready")

    for tab in ["farm", "work", "market", "village", "farm"]:
        scene.call("_show_tab", tab)
        await process_frame
        pass("tab " + tab)

    var state = scene.get("state")
    if typeof(state) != TYPE_DICTIONARY:
        fail("state dictionary")
    else:
        pass("state dictionary")
        if not state.has("settings") or not state.has("ui"):
            fail("v0.3 fields")
        else:
            pass("v0.3 fields")

    print("BOOT SMOKE COMPLETE failures=", failures)
    scene.queue_free()
    quit(1 if failures else 0)
