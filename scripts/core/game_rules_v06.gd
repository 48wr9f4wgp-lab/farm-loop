class_name GameRulesV06
extends "res://scripts/core/game_rules_v05.gd"

const DAILY_HARVEST_TARGET := 2
const DAILY_EXPLORE_TARGET := 1
const DAILY_SELL_TARGET := 1

func ensure_product_fields(s: Dictionary) -> void:
    ensure_entertainment_fields(s)
    if not s.has("daily"):
        s["daily"] = {}
    var d: Dictionary = s["daily"]
    var today: String = Time.get_date_string_from_system()
    if str(d.get("date","")) != today:
        var total: int = int(d.get("total_completed",0))
        d = {
            "date":today,
            "harvest":0,
            "explore":0,
            "sell":0,
            "claimed":false,
            "total_completed":total
        }
    if not d.has("harvest"): d["harvest"] = 0
    if not d.has("explore"): d["explore"] = 0
    if not d.has("sell"): d["sell"] = 0
    if not d.has("claimed"): d["claimed"] = false
    if not d.has("total_completed"): d["total_completed"] = 0
    s["daily"] = d

func daily_summary(s: Dictionary) -> Dictionary:
    ensure_product_fields(s)
    var d: Dictionary = s["daily"]
    return {
        "harvest":mini(int(d["harvest"]),DAILY_HARVEST_TARGET),
        "harvest_target":DAILY_HARVEST_TARGET,
        "explore":mini(int(d["explore"]),DAILY_EXPLORE_TARGET),
        "explore_target":DAILY_EXPLORE_TARGET,
        "sell":mini(int(d["sell"]),DAILY_SELL_TARGET),
        "sell_target":DAILY_SELL_TARGET,
        "claimed":bool(d["claimed"]),
        "total_completed":int(d["total_completed"])
    }

func _daily_complete(d: Dictionary) -> bool:
    return int(d["harvest"]) >= DAILY_HARVEST_TARGET and int(d["explore"]) >= DAILY_EXPLORE_TARGET and int(d["sell"]) >= DAILY_SELL_TARGET

func track_daily_action(s: Dictionary, kind: String, facility: String = "") -> Dictionary:
    ensure_product_fields(s)
    var d: Dictionary = s["daily"]
    if kind == "collect" and facility != "mountain":
        d["harvest"] = int(d["harvest"]) + 1
    if facility == "mountain":
        d["explore"] = int(d["explore"]) + 1
    if kind == "sell":
        d["sell"] = int(d["sell"]) + 1

    if _daily_complete(d) and not bool(d["claimed"]):
        d["claimed"] = true
        d["total_completed"] = int(d["total_completed"]) + 1
        var rank: int = land_rank(s)
        var bonus: int = 2200 + rank * 550
        s["money"] += bonus
        s["reputation"] += 1
        s["loop_score"] = mini(100,int(s["loop_score"])+5)
        var growth: Dictionary = _add_prosperity(s,16)
        add_log(s,"里山手帳を達成！ +¥%d" % bonus)
        return {"completed_now":true,"bonus":bonus,"rank_up":bool(growth["rank_up"])}
    return {"completed_now":false}
