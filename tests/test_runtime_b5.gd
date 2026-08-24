extends SceneTree

var failures: int = 0

func _ok(condition: bool, message: String) -> void:
    if condition:
        print("PASS: ",message)
    else:
        failures += 1
        printerr("FAIL: ",message)

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

    var rules = scene.get("rules")
    _ok(rules != null,"runtime rules exist")
    if rules != null and rules.get_script() != null:
        _ok(str(rules.get_script().resource_path).ends_with("game_rules_current.gd"),"runtime boots directly on GameRulesCurrent")

    var save_service = scene.get("save_service")
    _ok(save_service != null,"save service initialized")

    var state = scene.get("state")
    _ok(state is Dictionary,"runtime state exists")
    if state is Dictionary:
        _ok(int(state.get("schema_version",0)) == 4,"runtime uses current save schema")
        _ok(str(state.get("version","")) == "godot-1.6-motion-audio","runtime stamps current release metadata")
        _ok(state.has("daily"),"current product fields initialized")
        _ok(state.has("entertainment") and state["entertainment"].has("route_counts"),"current route fields initialized")

    var sfx = scene.get("sfx")
    _ok(sfx != null,"audio runtime initialized once")
    _ok(scene.get("content") != null,"current shell rendered")

    for tab in ["farm","work","market","village"]:
        scene.call("_show_tab",tab)
        await process_frame
        _ok(scene.get("content") != null and scene.get("content").get_child_count() > 0,"screen renders from current runtime: " + tab)

    print("B5 CURRENT RUNTIME CONTRACT COMPLETE failures=",failures)
    scene.queue_free()
    quit(1 if failures > 0 else 0)
