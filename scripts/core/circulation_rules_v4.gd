class_name CirculationRulesV4
extends RefCounted

const MAX_ACTION_POINTS := 3
const MAX_ZONE_VALUE := 3

const INTERVENTION_COMPOST := "compost"
const INTERVENTION_RESTORE_STREAM := "restore_stream"
const INTERVENTION_FLOWERING_SHRUB := "flowering_shrub"

const ACTIVE_ZONES := ["sansai","stream","meadow","coop"]
const ADJACENCY := {
    "sansai": ["stream","meadow"],
    "stream": ["sansai","meadow"],
    "meadow": ["sansai","stream","coop"],
    "coop": ["meadow"]
}

static func season_for_month(month: int) -> String:
    if month in [3,4,5]:
        return "spring"
    if month in [6,7,8]:
        return "summer"
    if month in [9,10,11]:
        return "autumn"
    return "winter"

static func season_name(season: String) -> String:
    return {
        "spring":"春",
        "summer":"夏",
        "autumn":"秋",
        "winter":"冬"
    }.get(season,"春")

static func zone_name(zone_id: String) -> String:
    return {
        "sansai":"山菜区画",
        "stream":"沢",
        "meadow":"草地",
        "coop":"鶏舎まわり"
    }.get(zone_id,"里山")

static func intervention_name(intervention: String) -> String:
    return {
        INTERVENTION_COMPOST:"堆肥を入れる",
        INTERVENTION_RESTORE_STREAM:"沢を整える",
        INTERVENTION_FLOWERING_SHRUB:"花木を植える"
    }.get(intervention,"手入れする")

static func new_state(year: int = 1, month: int = 4, weather: String = "晴れ") -> Dictionary:
    return {
        "board_version": 4,
        "year": maxi(1,year),
        "month": clampi(month,1,12),
        "season": season_for_month(clampi(month,1,12)),
        "weather": weather if not weather.is_empty() else "晴れ",
        "action_points": MAX_ACTION_POINTS,
        "zones": {
            "sansai": _zone(),
            "stream": _zone(),
            "meadow": _zone(),
            "coop": {
                "soil": 0,
                "water": 0,
                "bloom": 0,
                "habitat": 0,
                "recovery": 1
            }
        },
        "unlocked_interventions": [
            INTERVENTION_COMPOST,
            INTERVENTION_RESTORE_STREAM,
            INTERVENTION_FLOWERING_SHRUB
        ],
        "pending_actions": [],
        "last_resolution": [],
        "recovery_score": 0
    }

static func _zone() -> Dictionary:
    return {
        "soil": 0,
        "water": 0,
        "bloom": 0,
        "habitat": 0,
        "recovery": 0
    }

static func valid_targets(state: Dictionary, intervention: String) -> Array:
    if not state.get("unlocked_interventions",[]).has(intervention):
        return []
    match intervention:
        INTERVENTION_COMPOST:
            return ["sansai","meadow"]
        INTERVENTION_RESTORE_STREAM:
            return ["stream"]
        INTERVENTION_FLOWERING_SHRUB:
            return ["meadow"]
        _:
            return []

static func available_interventions(state: Dictionary, target_zone: String) -> Array:
    var result: Array = []
    for intervention in state.get("unlocked_interventions",[]):
        if valid_targets(state,str(intervention)).has(target_zone):
            result.append(str(intervention))
    return result

static func can_commit(state: Dictionary, intervention: String, target_zone: String) -> bool:
    if int(state.get("action_points",0)) <= 0:
        return false
    return valid_targets(state,intervention).has(target_zone)

static func commit_intervention(state: Dictionary, intervention: String, target_zone: String) -> Dictionary:
    var result := state.duplicate(true)
    if not can_commit(result,intervention,target_zone):
        return {
            "ok": false,
            "state": result,
            "reason": "invalid_intervention_or_target"
        }

    var zones: Dictionary = result["zones"]
    var zone: Dictionary = zones[target_zone]
    var direct_effects: Array = []

    match intervention:
        INTERVENTION_COMPOST:
            var before_soil := int(zone.get("soil",0))
            zone["soil"] = mini(MAX_ZONE_VALUE,before_soil + 1)
            direct_effects.append({
                "type":"soil",
                "zone":target_zone,
                "before":before_soil,
                "after":int(zone["soil"])
            })
        INTERVENTION_RESTORE_STREAM:
            var before_water := int(zone.get("water",0))
            zone["water"] = mini(MAX_ZONE_VALUE,before_water + 1)
            direct_effects.append({
                "type":"water_source",
                "zone":target_zone,
                "before":before_water,
                "after":int(zone["water"])
            })
        INTERVENTION_FLOWERING_SHRUB:
            var before_bloom := int(zone.get("bloom",0))
            zone["bloom"] = mini(MAX_ZONE_VALUE,before_bloom + 1)
            direct_effects.append({
                "type":"bloom",
                "zone":target_zone,
                "before":before_bloom,
                "after":int(zone["bloom"])
            })

    zones[target_zone] = zone
    result["zones"] = zones
    result["action_points"] = maxi(0,int(result["action_points"]) - 1)

    var pending: Array = result.get("pending_actions",[]).duplicate(true)
    pending.append({
        "intervention":intervention,
        "target_zone":target_zone,
        "direct_effects":direct_effects
    })
    result["pending_actions"] = pending

    return {
        "ok": true,
        "state": result,
        "direct_effects": direct_effects
    }

static func preview_intervention(state: Dictionary, intervention: String, target_zone: String) -> Dictionary:
    if not can_commit(state,intervention,target_zone):
        return {
            "ok": false,
            "reason":"invalid_intervention_or_target",
            "predicted_events":[],
            "predicted_chain_count":0
        }

    var committed: Dictionary = commit_intervention(state,intervention,target_zone)
    var simulated: Dictionary = resolve_month(committed["state"],false)
    var events: Array = simulated.get("events",[])
    return {
        "ok": true,
        "direct_effects": committed.get("direct_effects",[]),
        "predicted_events": events,
        "predicted_chain_count": _count_chain_events(events),
        "predicted_recovery_score": int(simulated["state"].get("recovery_score",0))
    }

static func resolve_month(state: Dictionary, advance_calendar: bool = true) -> Dictionary:
    var result := state.duplicate(true)
    var zones: Dictionary = result["zones"]
    var events: Array = []

    # 1. Water: a restored stream supports its authored neighboring land zones.
    var stream: Dictionary = zones["stream"]
    var stream_strength := int(stream.get("water",0))
    if stream_strength > 0:
        var old_stream_recovery := int(stream.get("recovery",0))
        stream["recovery"] = maxi(old_stream_recovery,mini(MAX_ZONE_VALUE,stream_strength))
        zones["stream"] = stream
        if int(stream["recovery"]) > old_stream_recovery:
            events.append({"type":"stream_recovered","zone":"stream","amount":int(stream["recovery"]) - old_stream_recovery})

        for target in ["sansai","meadow"]:
            var target_zone: Dictionary = zones[target]
            var before_water := int(target_zone.get("water",0))
            var delivered := mini(2,stream_strength)
            target_zone["water"] = maxi(before_water,delivered)
            zones[target] = target_zone
            if int(target_zone["water"]) > before_water:
                events.append({"type":"water_reached","from":"stream","zone":target,"amount":int(target_zone["water"]) - before_water})

    # 2. Growth: fertile soil only converts to recovery when water is connected.
    for target in ["sansai","meadow"]:
        var land: Dictionary = zones[target]
        var soil := int(land.get("soil",0))
        var water := int(land.get("water",0))
        if soil > 0 and water > 0:
            var before_recovery := int(land.get("recovery",0))
            var growth := mini(2,mini(soil,water))
            land["recovery"] = mini(MAX_ZONE_VALUE,maxi(before_recovery,growth))
            zones[target] = land
            if int(land["recovery"]) > before_recovery:
                events.append({"type":"growth","zone":target,"amount":int(land["recovery"]) - before_recovery})

    # 3. Bloom: flowering meadow becomes functional once water is present.
    var meadow: Dictionary = zones["meadow"]
    if int(meadow.get("bloom",0)) > 0 and int(meadow.get("water",0)) > 0:
        var before_meadow_recovery := int(meadow.get("recovery",0))
        meadow["recovery"] = mini(MAX_ZONE_VALUE,maxi(before_meadow_recovery,1))
        zones["meadow"] = meadow
        events.append({"type":"pollinators_return","zone":"meadow","amount":1})

        # Pollinators create a second-order payoff only if productive sansai has already returned.
        var sansai: Dictionary = zones["sansai"]
        if int(sansai.get("recovery",0)) > 0:
            var before_sansai_recovery := int(sansai.get("recovery",0))
            sansai["recovery"] = mini(MAX_ZONE_VALUE,before_sansai_recovery + 1)
            zones["sansai"] = sansai
            if int(sansai["recovery"]) > before_sansai_recovery:
                events.append({"type":"pollinator_boost","from":"meadow","zone":"sansai","amount":1})

    result["zones"] = zones
    result["last_resolution"] = events.duplicate(true)
    result["recovery_score"] = recovery_score(result)
    result["pending_actions"] = []

    if advance_calendar:
        result["action_points"] = MAX_ACTION_POINTS
        var next_month := int(result.get("month",4)) + 1
        var next_year := int(result.get("year",1))
        if next_month > 12:
            next_month = 1
            next_year += 1
        result["month"] = next_month
        result["year"] = next_year
        result["season"] = season_for_month(next_month)

    return {
        "state":result,
        "events":events,
        "chain_count":_count_chain_events(events)
    }

static func recovery_score(state: Dictionary) -> int:
    var zones: Dictionary = state.get("zones",{})
    var total := 0
    var count := 0
    for id in ["sansai","stream","meadow"]:
        if zones.has(id):
            total += int(zones[id].get("recovery",0))
            count += 1
    if count == 0:
        return 0
    return int(round((float(total) / float(count * MAX_ZONE_VALUE)) * 100.0))

static func has_future_move(state: Dictionary) -> bool:
    var probe := state.duplicate(true)
    if int(probe.get("action_points",0)) <= 0:
        probe["action_points"] = MAX_ACTION_POINTS
    for intervention in probe.get("unlocked_interventions",[]):
        if not valid_targets(probe,str(intervention)).is_empty():
            return true
    return false

static func _count_chain_events(events: Array) -> int:
    var count := 0
    for event in events:
        var event_type := str(event.get("type",""))
        if event_type in ["water_reached","growth","pollinators_return","pollinator_boost","stream_recovered"]:
            count += 1
    return count
