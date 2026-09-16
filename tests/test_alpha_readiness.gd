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
    _ok(packed != null,"main scene loads for V4 proof readiness")
    if packed == null:
        quit(1)
        return

    var scene = packed.instantiate()
    root.add_child(scene)
    await process_frame
    await process_frame

    _ok(str(scene.get_script().resource_path).ends_with("main_v32.gd"),"proof runtime is main_v32")
    _ok(scene.has_method("_analytics_export_payload"),"local telemetry export remains available")
    _ok(scene.has_method("_record_session_end"),"runtime records session_end")

    var ambience = scene.get("ambience")
    _ok(ambience != null,"procedural satoyama ambience remains installed")
    if ambience != null:
        _ok(ambience.has_method("set_scene"),"ambience follows season and weather")
        _ok(ambience.has_method("ensure_playing"),"ambience can recover after mobile audio unlock")

    var payload_text: String = str(scene.call("_analytics_export_payload"))
    var parsed = JSON.parse_string(payload_text)
    _ok(parsed is Dictionary,"local telemetry export remains valid JSON")
    if parsed is Dictionary:
        _ok(parsed.get("events",null) is Array,"telemetry export contains event array")

    var state: Dictionary = scene.get("state")
    _ok(state.has("circulation_v4"),"V4 proof state is present")
    _ok(int(state.get("schema_version",0)) == 5,"V4 proof uses schema v5")

    var farm_map = scene.get("map")
    _ok(farm_map != null,"V4 proof builds ecological board")
    if farm_map != null:
        _ok(str(farm_map.get_script().resource_path).ends_with("circulation_board_v5.gd"),"V4 proof uses M5 circulation board")
        _ok(int(farm_map.get("visual_pass")) == 13,"V4 board reuses proven practical visual pass 13")
        _ok(str(farm_map.get("visual_target_id")) == "satoyama-practical-final-2026-09-16-v1","practical visual target remains baseline")
        var world_root = farm_map.get("world_root")
        _ok(world_root != null and world_root.get_node_or_null("PracticalFinalVisualTargetV15") != null,"V15 practical visual layer is retained")
        _ok(world_root != null and world_root.get_node_or_null("CirculationBoardV4Marker") != null,"V4 board interaction layer is retained")
        _ok(world_root != null and world_root.get_node_or_null("V4SelectedZoneFocus") != null,"V4 world-space zone focus exists")
        _ok(world_root != null and world_root.get_node_or_null("V4M5ChainPreviewMarker") != null,"M5 chain preview layer is installed")

    scene.call("_record_session_end","contract_test")
    var has_session_end := false
    for event in state.get("analytics",{}).get("events",[]):
        if str(event.get("event","")) == "session_end":
            has_session_end = true
            break
    _ok(has_session_end,"session_end remains persisted into local telemetry")

    print("V4 M5 PROOF READINESS CONTRACT COMPLETE failures=",failures)
    scene.queue_free()
    await process_frame
    quit(1 if failures > 0 else 0)
