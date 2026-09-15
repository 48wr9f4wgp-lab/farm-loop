extends "res://scripts/ui/main_v28.gd"

const FarmScreenV14Class = preload("res://scripts/ui/screens/farm_screen_v14.gd")
const AmbiencePlayerClass = preload("res://scripts/audio/ambience_player.gd")

var ambience
var _session_started_msec: int = 0
var _session_end_recorded: bool = false

func _ready() -> void:
    _session_started_msec = Time.get_ticks_msec()
    _session_end_recorded = false
    super._ready()

    ambience = AmbiencePlayerClass.new()
    add_child(ambience)
    _sync_ambience()

    state["version"] = "godot-v3-restore-loop-alpha-rc"
    save_service.save(state)
    _header()

func _exit_tree() -> void:
    _record_session_end("exit_tree")

func _build_farm() -> void:
    FarmScreenV14Class.new().build(self)

func _header() -> void:
    super._header()
    _sync_ambience()

func _sync_ambience() -> void:
    if ambience == null or state.is_empty() or rules == null:
        return
    ambience.set_enabled(bool(state.get("settings",{}).get("sound",true)))
    ambience.set_scene(rules.season_key(int(state.get("month",4))),str(state.get("weather","晴れ")))

func _toggle_sound() -> void:
    super._toggle_sound()
    _sync_ambience()

func _commit(result: Dictionary, return_tab: String, facility: String = "") -> void:
    super._commit(result,return_tab,facility)
    if ambience != null:
        ambience.ensure_playing()

func _apply_ftue_transition(transition: Dictionary) -> void:
    var from_step: int = int(transition.get("from_step",-1))
    var advanced: bool = bool(transition.get("advanced",false))
    var completed: bool = bool(transition.get("completed",false))
    super._apply_ftue_transition(transition)
    if not advanced:
        return

    if from_step == 4:
        if feedback != null:
            feedback.pop("土が息を吹き返した｜芽と花が戻りはじめた",4)
            feedback.fly_tokens("loop",8)
        _haptic(3)
    elif completed:
        _haptic(5)

func _switch_save_slot(slot: String, fresh: bool) -> void:
    if not state.is_empty():
        _record_session_end("slot_switch")
    super._switch_save_slot(slot,fresh)
    _session_started_msec = Time.get_ticks_msec()
    _session_end_recorded = false
    _sync_ambience()

func _record_session_end(reason: String) -> void:
    if _session_end_recorded or state.is_empty() or save_service == null:
        return
    _session_end_recorded = true
    var elapsed_seconds := 0.0
    if _session_started_msec > 0:
        elapsed_seconds = maxf(0.0,float(Time.get_ticks_msec() - _session_started_msec) / 1000.0)
    _record_event("session_end",_slice_props({
        "slot":runtime_slot,
        "reason":reason,
        "duration_seconds":elapsed_seconds
    }))
    save_service.save(state)

func _request_snapshot(id: String) -> Dictionary:
    for request in state.get("village_requests",[]):
        if str(request.get("id","")) == id:
            return request.duplicate(true)
    return {}

func _on_request(id: String) -> void:
    var before := _request_snapshot(id)
    var was_done: bool = bool(before.get("done",false))
    super._on_request(id)
    var after := _request_snapshot(id)
    if not was_done and bool(after.get("done",false)):
        _record_event("village_request_completed",_slice_props({
            "request_id":id,
            "villager":str(after.get("villager",before.get("villager",""))),
            "reward":int(after.get("reward",before.get("reward",0))),
            "relation":int(after.get("relation",before.get("relation",0)))
        }))
        save_service.save(state)

func _analytics_export_payload() -> String:
    var payload := {
        "schema":"farm_loop_alpha_telemetry_v1",
        "exported_unix":int(Time.get_unix_time_from_system()),
        "slot":runtime_slot,
        "version":str(state.get("version","")),
        "year":int(state.get("year",1)),
        "month":int(state.get("month",4)),
        "ftue_step":ftue_service.step(state) if ftue_service != null else -1,
        "ftue_active":ftue_service.active(state) if ftue_service != null else false,
        "events":state.get("analytics",{}).get("events",[]).duplicate(true)
    }
    return JSON.stringify(payload,"  ")

func _on_export_analytics() -> void:
    _record_event("telemetry_exported",_slice_props({"slot":runtime_slot}))
    save_service.save(state)
    var payload := _analytics_export_payload()
    DisplayServer.clipboard_set(payload)
    var file := FileAccess.open("user://farm_loop_alpha_telemetry.json",FileAccess.WRITE)
    if file != null:
        file.store_string(payload)
        file.close()
    if feedback != null:
        feedback.pop("テストデータをコピーした",2)

func _build_village() -> void:
    super._build_village()
    if content == null:
        return
    var alpha := _section("Alpha テスト")
    var events: Array = state.get("analytics",{}).get("events",[])
    alpha.add_child(_lead_text("端末内だけで計測中｜イベント %d件。外部送信はまだ行わない。" % events.size()))
    var export_button := _button("テストデータをコピー",Callable(self,"_on_export_analytics"),false,false)
    export_button.custom_minimum_size.y = 50
    alpha.add_child(export_button)
