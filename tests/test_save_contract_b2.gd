extends SceneTree

var failures: int = 0

func _ok(condition: bool, message: String) -> void:
    if condition:
        print("PASS: ", message)
    else:
        failures += 1
        printerr("FAIL: ", message)

func _cleanup() -> void:
    for path in [
        "user://farm_loop_save.json",
        "user://farm_loop_save.backup.json",
        "user://farm_loop_save.tmp.json",
        "user://farm_loop_ftue_test_save.json",
        "user://farm_loop_ftue_test_save.backup.json",
        "user://farm_loop_ftue_test_save.tmp.json"
    ]:
        if FileAccess.file_exists(path):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

func _defaults() -> Dictionary:
    return {
        "schema_version": 5,
        "version": "godot-v4-circulation-puzzle",
        "year": 1,
        "month": 4,
        "weather": "晴れ",
        "money": 0,
        "projects": {},
        "compost_queue": 0,
        "relation": {"mio":0,"takumi":0,"gen":0},
        "village_requests": [],
        "discovered": ["eggs"],
        "analytics": {"session_actions":0},
        "circulation_v4": CirculationRulesV4.new_state(1,4,"晴れ"),
    }

func _init() -> void:
    _cleanup()
    var service := SaveService.new()
    var defaults := _defaults()

    var first := defaults.duplicate(true)
    first["money"] = 12345
    first["circulation_v4"]["zones"]["sansai"]["soil"] = 2
    _ok(service.save(first), "primary save succeeds")
    var first_loaded := service.load_or_default(defaults)
    _ok(int(first_loaded.get("money",0)) == 12345, "primary save round-trips")
    _ok(int(first_loaded.get("schema_version",0)) == 5, "current save schema is v5")
    _ok(str(first_loaded.get("version","")) == "godot-v4-circulation-puzzle", "current release metadata survives load")
    _ok(int(first_loaded.get("circulation_v4",{}).get("zones",{}).get("sansai",{}).get("soil",0)) == 2, "circulation progress round-trips")

    var second := first.duplicate(true)
    second["money"] = 54321
    _ok(service.save(second), "second save succeeds and creates backup")

    var test_service := SaveService.new("ftue_test")
    var test_state := defaults.duplicate(true)
    test_state["money"] = 777
    test_state["circulation_v4"]["action_points"] = 1
    _ok(test_service.save(test_state), "isolated FTUE test slot saves")
    _ok(int(test_service.load_or_default(defaults).get("money",0)) == 777, "FTUE test slot round-trips independently")
    _ok(int(test_service.load_or_default(defaults).get("circulation_v4",{}).get("action_points",0)) == 1, "FTUE V4 board remains isolated")
    _ok(int(service.load_or_default(defaults).get("money",0)) == 54321, "FTUE test slot never overwrites main save")

    var corrupt := FileAccess.open("user://farm_loop_save.json", FileAccess.WRITE)
    _ok(corrupt != null, "primary save can be opened for corruption fixture")
    if corrupt != null:
        corrupt.store_string("{\"checksum\":\"tampered\",\"payload\":{\"money\":999999}}")
        corrupt.close()
    var recovered := service.load_or_default(defaults)
    _ok(int(recovered.get("money",0)) == 12345, "checksum failure recovers previous backup")

    var legacy := {
        "schema_version": 1,
        "version": "godot-0.1-legacy",
        "year": 2,
        "month": 9,
        "weather": "雨",
        "money": 777,
        "projects": {"snowRoof":true},
        "compost_queue": 2,
        "relation": {"mio":4,"takumi":1,"gen":0},
        "village_requests": [],
        "discovered": ["eggs","shiitake"],
        "analytics": {"session_actions":9},
    }
    var migrated := service.migrate(legacy, defaults)
    _ok(int(migrated.get("schema_version",0)) == 5, "legacy save migrates to schema v5")
    _ok(str(migrated.get("version","")) == "godot-0.1-legacy", "migration preserves source release metadata")
    _ok(int(migrated.get("money",0)) == 777, "legacy economy remains untouched")
    _ok(bool(migrated.get("projects",{}).get("snowRoof",false)), "legacy project state survives migration")
    _ok(int(migrated.get("compost_queue",0)) == 2, "legacy compost queue survives migration")
    _ok(int(migrated.get("relation",{}).get("mio",0)) == 4, "legacy relationship data survives migration")
    _ok(int(migrated.get("analytics",{}).get("session_actions",0)) == 9, "legacy analytics field survives migration")
    var migrated_v4: Dictionary = migrated.get("circulation_v4",{})
    _ok(int(migrated_v4.get("board_version",0)) == 4, "legacy save gains V4 circulation block")
    _ok(int(migrated_v4.get("year",0)) == 2 and int(migrated_v4.get("month",0)) == 9, "V4 board starts from legacy calendar")
    _ok(str(migrated_v4.get("season","")) == "autumn", "V4 migration derives season from legacy month")
    _ok(str(migrated_v4.get("weather","")) == "雨", "V4 migration preserves legacy weather")
    _ok(int(migrated_v4.get("action_points",0)) == 3, "V4 migration starts with three actions")

    var partial := defaults.duplicate(true)
    partial["circulation_v4"] = {
        "board_version":4,
        "year":3,
        "month":12,
        "action_points":2,
        "zones":{"sansai":{"soil":3}}
    }
    var repaired := service.migrate(partial,defaults)
    var repaired_v4: Dictionary = repaired["circulation_v4"]
    _ok(int(repaired_v4["zones"]["sansai"].get("soil",0)) == 3, "migration preserves existing V4 progress")
    _ok(repaired_v4["zones"].has("stream") and repaired_v4["zones"].has("meadow"), "migration repairs missing V4 zones")
    _ok(int(repaired_v4.get("action_points",0)) == 2, "migration preserves valid remaining AP")

    _cleanup()
    print("B2 SAVE CONTRACT V5 COMPLETE failures=", failures)
    quit(1 if failures > 0 else 0)
