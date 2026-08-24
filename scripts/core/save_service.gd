class_name SaveService
extends RefCounted

const SAVE_PATH := "user://farm_loop_save.json"
const BACKUP_PATH := "user://farm_loop_save.backup.json"
const TEMP_PATH := "user://farm_loop_save.tmp.json"
const SCHEMA_VERSION := 4

func _canonical_payload_text(payload: Dictionary) -> String:
    # JSON round-trip normalizes values the same way they will be represented
    # after loading from disk (notably JSON numeric types), while sort_keys=true
    # keeps dictionary ordering deterministic for checksum purposes.
    var first_pass := JSON.stringify(payload, "", true, false)
    var normalized: Variant = JSON.parse_string(first_pass)
    if typeof(normalized) != TYPE_DICTIONARY:
        return first_pass
    return JSON.stringify(normalized, "", true, false)

func _hash(payload: Dictionary) -> String:
    var text := _canonical_payload_text(payload)
    var h: int = 2166136261
    for byte in text.to_utf8_buffer():
        h = int((h ^ int(byte)) * 16777619) & 0xffffffff
    return "%08x" % h

func _envelope(payload: Dictionary) -> Dictionary:
    return {
        "schema_version": SCHEMA_VERSION,
        "checksum": _hash(payload),
        "payload": payload,
    }

func _read_envelope(path: String) -> Dictionary:
    if not FileAccess.file_exists(path):
        return {}
    var f := FileAccess.open(path, FileAccess.READ)
    if f == null:
        return {}
    var parsed: Variant = JSON.parse_string(f.get_as_text())
    if typeof(parsed) != TYPE_DICTIONARY:
        return {}
    var env: Dictionary = parsed
    if not env.has("payload") or not env.has("checksum"):
        return {}
    var payload: Dictionary = env["payload"]
    if _hash(payload) != str(env["checksum"]):
        return {}
    return payload

func load_or_default(default_state: Dictionary) -> Dictionary:
    var loaded := _read_envelope(SAVE_PATH)
    if not loaded.is_empty():
        return migrate(loaded, default_state)
    loaded = _read_envelope(BACKUP_PATH)
    if not loaded.is_empty():
        return migrate(loaded, default_state)
    return default_state.duplicate(true)

func save(payload: Dictionary) -> bool:
    var env := _envelope(payload)
    var current_global := ProjectSettings.globalize_path(SAVE_PATH)
    var backup_global := ProjectSettings.globalize_path(BACKUP_PATH)
    if FileAccess.file_exists(SAVE_PATH):
        DirAccess.copy_absolute(current_global, backup_global)
    var tmp := FileAccess.open(TEMP_PATH, FileAccess.WRITE)
    if tmp == null:
        return false
    tmp.store_string(JSON.stringify(env, "", true, false))
    tmp.close()
    var verify := _read_envelope(TEMP_PATH)
    if verify.is_empty():
        DirAccess.remove_absolute(ProjectSettings.globalize_path(TEMP_PATH))
        return false
    if FileAccess.file_exists(SAVE_PATH):
        var remove_err := DirAccess.remove_absolute(current_global)
        if remove_err != OK:
            return false
    var err := DirAccess.rename_absolute(ProjectSettings.globalize_path(TEMP_PATH), current_global)
    return err == OK

func migrate(raw: Dictionary, defaults: Dictionary) -> Dictionary:
    var out := defaults.duplicate(true)
    _merge_recursive(out, raw)
    var version := int(raw.get("schema_version", 1))
    if version < 2:
        out["projects"] = raw.get("projects", {})
        out["compost_queue"] = raw.get("compost_queue", 0)
    if version < 3:
        out["relation"] = raw.get("relation", {"mio":0,"takumi":0,"gen":0})
        out["village_requests"] = raw.get("village_requests", [])
        out["discovered"] = raw.get("discovered", ["eggs","taranome","udo","kogomi","shiitake"])
    if version < 4:
        out["analytics"] = raw.get("analytics", {"session_actions":0})
    out["schema_version"] = SCHEMA_VERSION
    # Preserve the release metadata that actually produced the save. The active
    # application layer may stamp its current release after a successful boot,
    # but migration itself must never invent an unrelated historical version.
    out["version"] = str(raw.get("version", defaults.get("version", "unknown")))
    return out

func _merge_recursive(target: Dictionary, source: Dictionary) -> void:
    for key in source:
        if target.has(key) and typeof(target[key]) == TYPE_DICTIONARY and typeof(source[key]) == TYPE_DICTIONARY:
            _merge_recursive(target[key], source[key])
        else:
            target[key] = source[key]
