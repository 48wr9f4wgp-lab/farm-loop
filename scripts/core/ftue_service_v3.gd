class_name FtueServiceV3
extends RefCounted

const VERSION := 3
const FINAL_STEP := 6

var data: GameData

func _init(game_data: GameData) -> void:
    data = game_data

func ensure_state(s: Dictionary) -> void:
    _ensure_restoration_state(s)
    if s.has("ftue_v3") and s["ftue_v3"] is Dictionary:
        _repair(s)
        return

    var mapped: int = 0
    var legacy_v2: Dictionary = s.get("ftue_v2",{}) if s.get("ftue_v2",{}) is Dictionary else {}
    if not legacy_v2.is_empty():
        var legacy_step: int = int(legacy_v2.get("step",0))
        if bool(legacy_v2.get("completed",false)) or legacy_step >= 6:
            mapped = FINAL_STEP
        else:
            mapped = clampi(legacy_step,0,5)
    elif int(s.get("tutorial_step",0)) >= 6:
        mapped = FINAL_STEP

    var now: float = Time.get_unix_time_from_system()
    s["ftue_v3"] = {
        "version":VERSION,
        "step":mapped,
        "active":mapped < FINAL_STEP,
        "completed":mapped >= FINAL_STEP,
        "started_at":now,
        "step_started_at":now,
        "started_steps":[],
        "completed_steps":[]
    }

    if mapped >= FINAL_STEP:
        var r: Dictionary = s["restoration_v3"]
        if int(r.get("first_patch_stage",0)) < 2 and int(s.get("loop_score",0)) > 0:
            r["first_patch_stage"] = 2
            r["patches_restored"] = maxi(1,int(r.get("patches_restored",0)))
        s["restoration_v3"] = r

func _ensure_restoration_state(s: Dictionary) -> void:
    if not s.has("restoration_v3") or not (s["restoration_v3"] is Dictionary):
        s["restoration_v3"] = {
            "first_patch_stage":0,
            "patches_restored":0,
            "proof_mode":true
        }
        return
    var r: Dictionary = s["restoration_v3"]
    if not r.has("first_patch_stage"): r["first_patch_stage"] = 0
    if not r.has("patches_restored"): r["patches_restored"] = 0
    if not r.has("proof_mode"): r["proof_mode"] = true
    s["restoration_v3"] = r

func _repair(s: Dictionary) -> void:
    var f: Dictionary = s["ftue_v3"]
    if not f.has("version"): f["version"] = VERSION
    if not f.has("step"): f["step"] = 0
    if not f.has("active"): f["active"] = int(f["step"]) < FINAL_STEP
    if not f.has("completed"): f["completed"] = int(f["step"]) >= FINAL_STEP
    if not f.has("started_at"): f["started_at"] = Time.get_unix_time_from_system()
    if not f.has("step_started_at"): f["step_started_at"] = Time.get_unix_time_from_system()
    if not f.has("started_steps"): f["started_steps"] = []
    if not f.has("completed_steps"): f["completed_steps"] = []
    f["step"] = clampi(int(f["step"]),0,FINAL_STEP)
    f["active"] = int(f["step"]) < FINAL_STEP
    f["completed"] = int(f["step"]) >= FINAL_STEP
    s["ftue_v3"] = f
    _ensure_restoration_state(s)

func active(s: Dictionary) -> bool:
    ensure_state(s)
    return bool(s["ftue_v3"].get("active",false))

func step(s: Dictionary) -> int:
    ensure_state(s)
    return int(s["ftue_v3"].get("step",FINAL_STEP))

func restoration_stage(s: Dictionary) -> int:
    ensure_state(s)
    return clampi(int(s["restoration_v3"].get("first_patch_stage",0)),0,2)

func proof_mode(s: Dictionary) -> bool:
    ensure_state(s)
    return bool(s["restoration_v3"].get("proof_mode",true))

func reconcile(s: Dictionary) -> void:
    ensure_state(s)
    var f: Dictionary = s["ftue_v3"]
    var current: int = int(f.get("step",0))
    if current >= FINAL_STEP:
        f["step"] = FINAL_STEP
        f["active"] = false
        f["completed"] = true
        s["ftue_v3"] = f
        return

    # Boot/load recovery only. Live actions advance through on_action so
    # analytics and payoff feedback are not skipped.
    if current == 0 and not bool(s.get("ready",{}).get("coop",true)):
        current = 1
    if current == 1 and int(s.get("inventory",{}).get("leaves",0)) >= 2:
        current = 2
    if current == 2 and (int(s.get("compost_queue",0)) > 0 or int(s.get("inventory",{}).get("compost",0)) > 0):
        current = 3
    if current == 3 and int(s.get("inventory",{}).get("compost",0)) > 0:
        current = 4
    if current == 4 and int(s.get("buffs",{}).get("field",0)) > 0:
        _set_restoration_stage(s,1)
        current = 5
    if current == 5 and not bool(s.get("ready",{}).get("sansai",true)):
        _set_restoration_stage(s,2)
        current = FINAL_STEP

    if current != int(f.get("step",0)):
        f["step"] = current
        f["step_started_at"] = Time.get_unix_time_from_system()
    f["active"] = current < FINAL_STEP
    f["completed"] = current >= FINAL_STEP
    s["ftue_v3"] = f

func objective(s: Dictionary) -> String:
    ensure_state(s)
    if not active(s):
        return ""
    var current: int = step(s)
    if current == 0:
        return "1/6｜鶏舎をタップ → 卵と鶏糞を回収"
    if current == 1:
        return "2/6｜仕事 → 落ち葉・籾殻を集める"
    if current == 2:
        return "3/6｜堆肥舎 → 鶏糞＋落ち葉を仕込む"
    if current == 3:
        return "4/6｜今月を終える → 堆肥を完成させる"
    if current == 4:
        return "5/6｜山菜区画 → 完成堆肥を土へ還して里山を蘇らせる"
    if current == 5:
        return "6/6｜蘇った山菜区画 → 戻ってきた恵みを収穫"
    return ""

func on_action(s: Dictionary, kind: String, facility: String, result: Dictionary) -> Dictionary:
    ensure_state(s)
    if not bool(result.get("ok",false)) or not active(s):
        return {"advanced":false}

    var current: int = step(s)
    var matches: bool = false
    if current == 0:
        matches = kind == "collect" and facility == "coop"
    elif current == 1:
        matches = kind == "work" and facility == "materials"
    elif current == 2:
        matches = kind == "work" and facility == "compost"
    elif current == 3:
        matches = kind in ["month","hazard"]
    elif current == 4:
        matches = kind == "loop" and facility == "sansai"
    elif current == 5:
        matches = kind == "collect" and facility == "sansai"

    if not matches:
        return {"advanced":false}

    if current == 4:
        _set_restoration_stage(s,1)
    elif current == 5:
        _set_restoration_stage(s,2)
    return _advance(s)

func on_tab(_s: Dictionary, _tab: String) -> Dictionary:
    # V3 never advances by visiting Village/Market/Work. Only restoration
    # actions can complete the proof loop.
    return {"advanced":false}

func _set_restoration_stage(s: Dictionary, value: int) -> void:
    _ensure_restoration_state(s)
    var r: Dictionary = s["restoration_v3"]
    var next_stage: int = clampi(value,0,2)
    r["first_patch_stage"] = maxi(int(r.get("first_patch_stage",0)),next_stage)
    if next_stage >= 1:
        r["patches_restored"] = maxi(1,int(r.get("patches_restored",0)))
    s["restoration_v3"] = r

func _advance(s: Dictionary) -> Dictionary:
    var f: Dictionary = s["ftue_v3"]
    var from_step: int = int(f["step"])
    var now: float = Time.get_unix_time_from_system()
    var elapsed_step: float = maxf(0.0,now-float(f.get("step_started_at",now)))
    var completed_steps: Array = f.get("completed_steps",[])
    if from_step not in completed_steps:
        completed_steps.append(from_step)
    f["completed_steps"] = completed_steps
    f["step"] = mini(FINAL_STEP,from_step+1)
    f["step_started_at"] = now
    var completed_now: bool = int(f["step"]) >= FINAL_STEP
    if completed_now:
        f["active"] = false
        f["completed"] = true
        f["completed_at"] = now
    s["ftue_v3"] = f
    return {
        "advanced":true,
        "from_step":from_step,
        "to_step":int(f["step"]),
        "step_elapsed_seconds":elapsed_step,
        "completed":completed_now
    }

func mark_step_started(s: Dictionary) -> bool:
    ensure_state(s)
    if not active(s):
        return false
    var f: Dictionary = s["ftue_v3"]
    var current: int = int(f["step"])
    var started: Array = f.get("started_steps",[])
    if current in started:
        return false
    started.append(current)
    f["started_steps"] = started
    f["step_started_at"] = Time.get_unix_time_from_system()
    s["ftue_v3"] = f
    return true

func event_properties(s: Dictionary, extra: Dictionary = {}) -> Dictionary:
    ensure_state(s)
    var f: Dictionary = s["ftue_v3"]
    var now: float = Time.get_unix_time_from_system()
    var props := {
        "ftue_version":VERSION,
        "step":int(f.get("step",FINAL_STEP)),
        "elapsed_seconds":maxf(0.0,now-float(f.get("started_at",now))),
        "current_tab":str(s.get("ui",{}).get("last_tab","farm")),
        "year":int(s.get("year",1)),
        "month":int(s.get("month",4)),
        "money":int(s.get("money",0)),
        "loop_score":int(s.get("loop_score",0)),
        "restoration_stage":restoration_stage(s),
        "satoyama_rank":_land_rank_from_state(s)
    }
    for key in extra:
        props[key] = extra[key]
    return props

# Compatibility helper for legacy Village free-play cards. Village is no longer
# a V3 FTUE beat, but keeping hints avoids a needless presentation regression.
func request_hint(request: Dictionary) -> String:
    var id: String = str(request.get("id",""))
    if id == "mio_eggs": return "入手先：農場の雪国鶏舎"
    if id in ["mio_spring","mio_udo"]: return "入手先：山菜区画・山の探索"
    if id == "takumi_shiitake": return "入手先：農場の原木林"
    if id == "gen_dry": return "入手先：原木林 → 仕事の加工小屋"
    if id == "gen_honey": return "入手先：夏〜秋の蜂場"
    if id == "gen_pack": return "入手先：山菜収穫 → 仕事の加工小屋"
    return ""

func _land_rank_from_state(s: Dictionary) -> int:
    var xp: int = int(s.get("entertainment",{}).get("prosperity_xp",0))
    if xp >= 340: return 5
    if xp >= 210: return 4
    if xp >= 115: return 3
    if xp >= 45: return 2
    return 1
