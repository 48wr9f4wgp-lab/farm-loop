extends SceneTree

const Rules = preload("res://scripts/core/circulation_rules_v4.gd")

var failures := 0

func _ok(condition: bool, message: String) -> void:
    if condition:
        print("PASS: ",message)
    else:
        failures += 1
        printerr("FAIL: ",message)

func _commit(state: Dictionary, intervention: String, zone: String) -> Dictionary:
    var result: Dictionary = Rules.commit_intervention(state,intervention,zone)
    _ok(bool(result.get("ok",false)),"commit succeeds: %s -> %s" % [intervention,zone])
    return result.get("state",state)

func _init() -> void:
    var initial: Dictionary = Rules.new_state()
    _ok(int(initial.get("board_version",0)) == 4,"V4 board version is initialized")
    _ok(int(initial.get("action_points",0)) == 3,"each month starts with exactly 3 AP")
    _ok(initial.get("zones",{}).has("sansai") and initial.get("zones",{}).has("stream") and initial.get("zones",{}).has("meadow"),"proof board contains core ecological zones")

    # Invalid targeting must not consume an action.
    var invalid: Dictionary = Rules.commit_intervention(initial,"restore_stream","sansai")
    _ok(not bool(invalid.get("ok",true)),"invalid intervention target is rejected")
    _ok(int(invalid.get("state",{}).get("action_points",0)) == 3,"invalid target does not consume AP")

    # Preview is deterministic and must never mutate the original board.
    var preview: Dictionary = Rules.preview_intervention(initial,"restore_stream","stream")
    _ok(bool(preview.get("ok",false)),"valid intervention can be previewed")
    _ok(int(initial.get("action_points",0)) == 3,"preview does not mutate original AP")
    _ok(int(initial["zones"]["stream"].get("water",0)) == 0,"preview does not mutate original zone state")
    _ok(int(preview.get("predicted_chain_count",0)) >= 3,"stream preview predicts connected ecological effects")

    # Route A: balanced loop — compost + stream + bloom.
    var route_a := Rules.new_state()
    route_a = _commit(route_a,"compost","sansai")
    route_a = _commit(route_a,"restore_stream","stream")
    route_a = _commit(route_a,"flowering_shrub","meadow")
    _ok(int(route_a.get("action_points",-1)) == 0,"three interventions consume the monthly AP budget")

    var blocked_fourth: Dictionary = Rules.commit_intervention(route_a,"compost","meadow")
    _ok(not bool(blocked_fourth.get("ok",true)),"fourth intervention is blocked at 0 AP")

    var resolved_a: Dictionary = Rules.resolve_month(route_a,true)
    var state_a: Dictionary = resolved_a["state"]
    _ok(int(state_a.get("month",0)) == 5,"month resolution advances April to May")
    _ok(int(state_a.get("action_points",0)) == 3,"new month restores 3 AP")
    _ok(int(state_a["zones"]["sansai"].get("recovery",0)) >= 2,"balanced route restores sansai through growth + pollinator chain")
    _ok(int(state_a["zones"]["meadow"].get("bloom",0)) >= 1,"balanced route preserves the flowering meadow choice")
    _ok(int(resolved_a.get("chain_count",0)) >= 5,"balanced route produces a multi-step month-end chain")

    # Route B: production-heavy loop — water + compost in two land zones.
    var route_b := Rules.new_state()
    route_b = _commit(route_b,"restore_stream","stream")
    route_b = _commit(route_b,"compost","sansai")
    route_b = _commit(route_b,"compost","meadow")
    var resolved_b: Dictionary = Rules.resolve_month(route_b,true)
    var state_b: Dictionary = resolved_b["state"]
    _ok(int(state_b["zones"]["sansai"].get("recovery",0)) >= 1,"production route restores sansai")
    _ok(int(state_b["zones"]["meadow"].get("recovery",0)) >= 1,"production route restores meadow through soil + water")
    _ok(int(state_b["zones"]["meadow"].get("bloom",0)) == 0,"production route remains distinct from bloom route")
    _ok(int(state_a.get("recovery_score",0)) != int(state_b.get("recovery_score",0)) or state_a["zones"]["meadow"] != state_b["zones"]["meadow"],"two viable openings produce meaningfully different board states")

    # A weak choice pattern may be inefficient, but it must never brick the run.
    var weak := Rules.new_state()
    weak = _commit(weak,"flowering_shrub","meadow")
    weak = _commit(weak,"flowering_shrub","meadow")
    weak = _commit(weak,"flowering_shrub","meadow")
    var weak_resolved: Dictionary = Rules.resolve_month(weak,true)
    var weak_state: Dictionary = weak_resolved["state"]
    _ok(int(weak_state.get("action_points",0)) == 3,"inefficient month still reaches a fresh next month")
    _ok(Rules.has_future_move(weak_state),"inefficient play cannot brick future progression")
    _ok(Rules.can_commit(weak_state,"restore_stream","stream"),"player can repair a weak month by restoring the stream next month")

    # Month-end must retain explainable causal events rather than an opaque score jump.
    var event_types: Array = []
    for event in resolved_a.get("events",[]):
        event_types.append(str(event.get("type","")))
    _ok(event_types.has("stream_recovered"),"resolution explains stream recovery")
    _ok(event_types.has("water_reached"),"resolution explains water connection")
    _ok(event_types.has("growth"),"resolution explains plant growth")
    _ok(event_types.has("pollinators_return"),"resolution explains pollinator return")
    _ok(event_types.has("pollinator_boost"),"resolution explains second-order ecological synergy")

    print("CIRCULATION RULES V4 M1 COMPLETE failures=",failures)
    quit(1 if failures > 0 else 0)
