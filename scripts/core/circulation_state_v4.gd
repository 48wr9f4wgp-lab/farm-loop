class_name CirculationStateV4
extends RefCounted

const Rules = preload("res://scripts/core/circulation_rules_v4.gd")

static func create_for_legacy(legacy_state: Dictionary) -> Dictionary:
    return Rules.new_state(
        int(legacy_state.get("year",1)),
        int(legacy_state.get("month",4)),
        str(legacy_state.get("weather","晴れ"))
    )

static func ensure_in_state(state: Dictionary) -> void:
    var defaults: Dictionary = create_for_legacy(state)
    if not state.has("circulation_v4") or typeof(state["circulation_v4"]) != TYPE_DICTIONARY:
        state["circulation_v4"] = defaults
        return

    var block: Dictionary = state["circulation_v4"]
    _merge_missing(block,defaults)
    block["board_version"] = 4
    block["year"] = maxi(1,int(block.get("year",defaults["year"])))
    block["month"] = clampi(int(block.get("month",defaults["month"])),1,12)
    block["season"] = Rules.season_for_month(int(block["month"]))
    if str(block.get("weather","")).is_empty():
        block["weather"] = str(defaults["weather"])
    block["action_points"] = clampi(int(block.get("action_points",Rules.MAX_ACTION_POINTS)),0,Rules.MAX_ACTION_POINTS)
    if typeof(block.get("pending_actions",[])) != TYPE_ARRAY:
        block["pending_actions"] = []
    if typeof(block.get("last_resolution",[])) != TYPE_ARRAY:
        block["last_resolution"] = []
    block["recovery_score"] = Rules.recovery_score(block)
    state["circulation_v4"] = block

static func fresh_for_test() -> Dictionary:
    return Rules.new_state(1,4,"晴れ")

static func _merge_missing(target: Dictionary, defaults: Dictionary) -> void:
    for key in defaults:
        if not target.has(key):
            target[key] = defaults[key].duplicate(true) if typeof(defaults[key]) in [TYPE_DICTIONARY,TYPE_ARRAY] else defaults[key]
        elif typeof(target[key]) == TYPE_DICTIONARY and typeof(defaults[key]) == TYPE_DICTIONARY:
            _merge_missing(target[key],defaults[key])
