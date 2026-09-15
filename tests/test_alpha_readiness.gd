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
    _ok(packed != null,"main scene loads for alpha readiness")
    if packed == null:
        quit(1)
        return

    var scene = packed.instantiate()
    root.add_child(scene)
    await process_frame
    await process_frame

    _ok(str(scene.get_script().resource_path).ends_with("main_v29.gd"),"alpha candidate runtime is main_v29")
    _ok(scene.has_method("_analytics_export_payload"),"runtime exposes local telemetry export payload")
    _ok(scene.has_method("_record_session_end"),"runtime records session_end")
    _ok(scene.has_method("_on_request"),"runtime owns village request completion hook")

    var ambience = scene.get("ambience")
    _ok(ambience != null,"procedural satoyama ambience is installed")
    if ambience != null:
        _ok(ambience.has_method("set_scene"),"ambience follows season and weather")
        _ok(ambience.has_method("ensure_playing"),"ambience can recover after mobile audio unlock")

    var payload_text: String = str(scene.call("_analytics_export_payload"))
    var parsed = JSON.parse_string(payload_text)
    _ok(parsed is Dictionary,"local telemetry export is valid JSON")
    if parsed is Dictionary:
        _ok(str(parsed.get("schema","")) == "farm_loop_alpha_telemetry_v1","telemetry export schema is versioned")
        _ok(parsed.get("events",null) is Array,"telemetry export contains event array")
        var events: Array = parsed.get("events",[])
        var has_session_start := false
        for event in events:
            if str(event.get("event","")) == "session_start":
                has_session_start = true
                break
        _ok(has_session_start,"alpha telemetry contains session_start")

    var farm_map = scene.get("map")
    _ok(farm_map != null,"alpha candidate builds farm hero")
    if farm_map != null:
        _ok(str(farm_map.get_script().resource_path).ends_with("farm_diorama_v14.gd"),"alpha candidate uses V14 diorama")
        _ok(int(farm_map.get("visual_pass")) == 12,"alpha candidate is on visual pass 12")

    scene.call("_record_session_end","contract_test")
    var state: Dictionary = scene.get("state")
    var has_session_end := false
    for event in state.get("analytics",{}).get("events",[]):
        if str(event.get("event","")) == "session_end":
            has_session_end = true
            break
    _ok(has_session_end,"session_end is persisted into local telemetry")

    print("EXTERNAL ALPHA READINESS CONTRACT COMPLETE failures=",failures)
    scene.queue_free()
    await process_frame
    quit(1 if failures > 0 else 0)
