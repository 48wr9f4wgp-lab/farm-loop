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

    _ok(str(scene.get_script().resource_path).ends_with("main_v31.gd"),"runtime is V4 circulation shell")

    var rules = scene.get("rules")
    _ok(rules != null,"legacy runtime rules remain available")
    if rules != null and rules.get_script() != null:
        _ok(str(rules.get_script().resource_path).ends_with("game_rules_current.gd"),"legacy systems still use consolidated GameRulesCurrent")

    var save_service = scene.get("save_service")
    _ok(save_service != null,"save service initialized")

    var state = scene.get("state")
    _ok(state is Dictionary,"runtime state exists")
    if state is Dictionary:
        _ok(int(state.get("schema_version",0)) == 5,"runtime uses save schema v5")
        _ok(str(state.get("version","")) == "godot-v4-circulation-puzzle-m4","runtime stamps V4 circulation metadata")
        _ok(state.has("circulation_v4"),"runtime initializes circulation V4 state")
        var board: Dictionary = state.get("circulation_v4",{})
        _ok(int(board.get("board_version",0)) == 4,"runtime circulation board version is 4")
        _ok(int(board.get("action_points",0)) >= 0 and int(board.get("action_points",0)) <= 3,"runtime AP remains within monthly budget")
        _ok(state.has("ftue_v3"),"legacy FTUE v3 state remains available for rollback")
        _ok(state.has("restoration_v3"),"legacy restoration state remains available for rollback")
        _ok(state.has("daily"),"legacy product fields remain initialized")
        _ok(state.has("entertainment") and state["entertainment"].has("route_counts"),"legacy route fields remain initialized for rollback")

    var sfx = scene.get("sfx")
    _ok(sfx != null,"audio runtime initialized once")
    var ambience = scene.get("ambience")
    _ok(ambience != null,"ambient audio runtime initialized once")
    _ok(scene.get("content") != null,"current shell rendered")

    # Hidden legacy tabs remain callable for rollback/regression even though the
    # V4 proof navigation exposes only the satoyama and settings surfaces.
    for tab in ["farm","work","market","village"]:
        scene.call("_show_tab",tab)
        await process_frame
        _ok(scene.get("content") != null and scene.get("content").get_child_count() > 0,"screen renders from current runtime: " + tab)

    scene.call("_show_tab","farm")
    await process_frame
    var farm_map = scene.get("map")
    _ok(farm_map != null and str(farm_map.get_script().resource_path).ends_with("circulation_board_v4.gd"),"farm runtime renders V4 ecological board")

    print("B5 CURRENT RUNTIME V4 CONTRACT COMPLETE failures=",failures)
    scene.queue_free()
    await process_frame
    quit(1 if failures > 0 else 0)
