class_name FtueService
extends RefCounted

const VERSION := 2
const FINAL_STEP := 9
const STARTER_REQUEST_ID := "mio_eggs"

var data: GameData

func _init(game_data: GameData) -> void:
    data = game_data

func ensure_state(s: Dictionary) -> void:
    if s.has("ftue_v2") and s["ftue_v2"] is Dictionary:
        _repair(s)
        return

    # Existing players must not be blindly thrown back to the beginning.
    # Map the old six-step tutorial into the new proof-of-fun sequence.
    var legacy: int = int(s.get("tutorial_step",0))
    var mapped: int = 0
    if legacy >= 6:
        mapped = FINAL_STEP
    elif legacy == 5:
        mapped = 6
    elif legacy == 4:
        mapped = 5
    elif legacy == 3:
        mapped = 4
    elif legacy == 2:
        mapped = 3
    elif legacy == 1:
        mapped = 1

    var now: float = Time.get_unix_time_from_system()
    s["ftue_v2"] = {
        "version":VERSION,
        "step":mapped,
        "active":mapped < FINAL_STEP,
        "completed":mapped >= FINAL_STEP,
        "started_at":now,
        "step_started_at":now,
        "started_steps":[],
        "completed_steps":[],
        "village_seen":false,
        "starter_request_added":false
    }
    reconcile(s)

func _repair(s: Dictionary) -> void:
    var f: Dictionary = s["ftue_v2"]
    if not f.has("version"): f["version"] = VERSION
    if not f.has("step"): f["step"] = 0
    if not f.has("active"): f["active"] = int(f["step"]) < FINAL_STEP
    if not f.has("completed"): f["completed"] = int(f["step"]) >= FINAL_STEP
    if not f.has("started_at"): f["started_at"] = Time.get_unix_time_from_system()
    if not f.has("step_started_at"): f["step_started_at"] = Time.get_unix_time_from_system()
    if not f.has("started_steps"): f["started_steps"] = []
    if not f.has("completed_steps"): f["completed_steps"] = []
    if not f.has("village_seen"): f["village_seen"] = false
    if not f.has("starter_request_added"): f["starter_request_added"] = false
    s["ftue_v2"] = f
    reconcile(s)

func active(s: Dictionary) -> bool:
    ensure_state(s)
    return bool(s["ftue_v2"].get("active",false))

func step(s: Dictionary) -> int:
    ensure_state(s)
    return int(s["ftue_v2"].get("step",FINAL_STEP))

func reconcile(s: Dictionary) -> void:
    if not s.has("ftue_v2"):
        return
    var f: Dictionary = s["ftue_v2"]
    var current: int = int(f.get("step",0))
    if current >= FINAL_STEP:
        f["step"] = FINAL_STEP
        f["active"] = false
        f["completed"] = true
        s["ftue_v2"] = f
        return

    # Recovery only skips a beat when the state proves it already happened.
    # It never consumes resources or grants rewards.
    if current == 0 and not bool(s.get("ready",{}).get("coop",true)):
        current = 1
    if current == 2 and (int(s.get("compost_queue",0)) > 0 or int(s.get("inventory",{}).get("compost",0)) > 0):
        current = 3
    if current == 3 and int(s.get("inventory",{}).get("compost",0)) > 0:
        current = 4
    if current == 4 and int(s.get("buffs",{}).get("field",0)) > 0:
        current = 5
    if current == 5 and not bool(s.get("ready",{}).get("sansai",true)):
        current = 6

    if current != int(f.get("step",0)):
        f["step"] = current
        f["step_started_at"] = Time.get_unix_time_from_system()
    f["active"] = current < FINAL_STEP
    f["completed"] = current >= FINAL_STEP
    s["ftue_v2"] = f

func objective(s: Dictionary) -> String:
    ensure_state(s)
    if not active(s):
        return ""
    var current: int = step(s)
    if current == 0:
        return "1/9｜鶏舎をタップ → 卵と鶏糞を回収"
    if current == 1:
        return "2/9｜仕事 → 落ち葉・籾殻を集める"
    if current == 2:
        return "3/9｜農場 → 堆肥舎で鶏糞＋落ち葉を仕込む"
    if current == 3:
        return "4/9｜農場 → 今月を終えて堆肥を発酵させる"
    if current == 4:
        return "5/9｜山菜区画 → 完成堆肥を土へ還元"
    if current == 5:
        return "6/9｜山菜区画 → 旬の山菜を収穫"
    if current == 6:
        return "7/9｜仕事 → 沢沿い・ブナ林・尾根から山道を選ぶ"
    if current == 7:
        return "8/9｜村 → 今日のお願いを見て、作る理由を知る"
    if current == 8:
        if _sellable_count(s) <= 0:
            return "9/9｜販売用の品を集める → 山道ならすぐ見つかる"
        return "9/9｜販売 → 売り先を見比べて収穫かごを一括出荷"
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
    elif current == 6:
        matches = facility == "mountain" and str(result.get("route","")).length() > 0
    elif current == 8:
        matches = kind == "sell"

    if not matches:
        return {"advanced":false}
    return _advance(s)

func on_tab(s: Dictionary, tab: String) -> Dictionary:
    ensure_state(s)
    if not active(s) or step(s) != 7 or tab != "village":
        return {"advanced":false}
    ensure_starter_request(s)
    s["ftue_v2"]["village_seen"] = true
    return _advance(s)

func _advance(s: Dictionary) -> Dictionary:
    var f: Dictionary = s["ftue_v2"]
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
    s["ftue_v2"] = f
    if int(f["step"]) == 7:
        ensure_starter_request(s)
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
    var f: Dictionary = s["ftue_v2"]
    var current: int = int(f["step"])
    var started: Array = f.get("started_steps",[])
    if current in started:
        return false
    started.append(current)
    f["started_steps"] = started
    f["step_started_at"] = Time.get_unix_time_from_system()
    s["ftue_v2"] = f
    return true

func event_properties(s: Dictionary, extra: Dictionary = {}) -> Dictionary:
    ensure_state(s)
    var f: Dictionary = s["ftue_v2"]
    var now: float = Time.get_unix_time_from_system()
    var props := {
        "step":int(f.get("step",FINAL_STEP)),
        "elapsed_seconds":maxf(0.0,now-float(f.get("started_at",now))),
        "current_tab":str(s.get("ui",{}).get("last_tab","farm")),
        "year":int(s.get("year",1)),
        "month":int(s.get("month",4)),
        "money":int(s.get("money",0)),
        "loop_score":int(s.get("loop_score",0)),
        "satoyama_rank":_land_rank_from_state(s)
    }
    for key in extra:
        props[key] = extra[key]
    return props

func ensure_starter_request(s: Dictionary) -> void:
    if not s.has("village_requests"):
        s["village_requests"] = []
    var requests: Array = s["village_requests"]
    for existing in requests:
        if str(existing.get("id","")) == STARTER_REQUEST_ID:
            return
    for source in data.get_table("requests"):
        if str(source.get("id","")) == STARTER_REQUEST_ID:
            var starter: Dictionary = source.duplicate(true)
            starter["done"] = false
            requests.push_front(starter)
            s["village_requests"] = requests
            s["ftue_v2"]["starter_request_added"] = true
            return

func request_hint(request: Dictionary) -> String:
    var id: String = str(request.get("id",""))
    if id == "mio_eggs": return "入手先：農場の雪国鶏舎"
    if id in ["mio_spring","mio_udo"]: return "入手先：山菜区画・山の探索"
    if id == "takumi_shiitake": return "入手先：農場の原木林"
    if id == "gen_dry": return "入手先：原木林 → 仕事の加工小屋"
    if id == "gen_honey": return "入手先：夏〜秋の蜂場"
    if id == "gen_pack": return "入手先：山菜収穫 → 仕事の加工小屋"
    return ""

func _sellable_count(s: Dictionary) -> int:
    var total: int = 0
    for key in data.get_table("products"):
        var product: Dictionary = data.get_table("products")[key]
        if bool(product.get("sellable",false)):
            total += int(s.get("inventory",{}).get(key,0))
    return total

func _land_rank_from_state(s: Dictionary) -> int:
    var xp: int = int(s.get("entertainment",{}).get("prosperity_xp",0))
    if xp >= 340: return 5
    if xp >= 210: return 4
    if xp >= 115: return 3
    if xp >= 45: return 2
    return 1
