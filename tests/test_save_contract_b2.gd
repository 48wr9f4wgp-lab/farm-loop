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
        "user://farm_loop_save.tmp.json"
    ]:
        if FileAccess.file_exists(path):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

func _defaults() -> Dictionary:
    return {
        "schema_version": 4,
        "version": "godot-1.6-motion-audio",
        "money": 0,
        "projects": {},
        "compost_queue": 0,
        "relation": {"mio":0,"takumi":0,"gen":0},
        "village_requests": [],
        "discovered": ["eggs"],
        "analytics": {"session_actions":0},
    }

func _init() -> void:
    _cleanup()
    var service := SaveService.new()
    var defaults := _defaults()

    var first := defaults.duplicate(true)
    first["money"] = 12345
    _ok(service.save(first), "primary save succeeds")
    var first_loaded := service.load_or_default(defaults)
    _ok(int(first_loaded.get("money",0)) == 12345, "primary save round-trips")
    _ok(int(first_loaded.get("schema_version",0)) == 4, "current save schema remains v4")
    _ok(str(first_loaded.get("version","")) == "godot-1.6-motion-audio", "current release metadata survives load")

    var second := first.duplicate(true)
    second["money"] = 54321
    _ok(service.save(second), "second save succeeds and creates backup")

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
        "money": 777,
        "projects": {"snowRoof":true},
        "compost_queue": 2,
        "relation": {"mio":4,"takumi":1,"gen":0},
        "village_requests": [],
        "discovered": ["eggs","shiitake"],
        "analytics": {"session_actions":9},
    }
    var migrated := service.migrate(legacy, defaults)
    _ok(int(migrated.get("schema_version",0)) == 4, "legacy save migrates to schema v4")
    _ok(str(migrated.get("version","")) == "godot-0.1-legacy", "migration preserves source release metadata")
    _ok(bool(migrated.get("projects",{}).get("snowRoof",false)), "legacy project state survives migration")
    _ok(int(migrated.get("compost_queue",0)) == 2, "legacy compost queue survives migration")
    _ok(int(migrated.get("relation",{}).get("mio",0)) == 4, "legacy relationship data survives migration")
    _ok(int(migrated.get("analytics",{}).get("session_actions",0)) == 9, "legacy analytics field survives migration")

    _cleanup()
    print("B2 SAVE CONTRACT TESTS COMPLETE failures=", failures)
    quit(1 if failures > 0 else 0)
