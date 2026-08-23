extends SceneTree

const GameDataClass = preload("res://scripts/core/game_data.gd")
const GameStateClass = preload("res://scripts/core/game_state.gd")
const RulesV05Class = preload("res://scripts/core/game_rules_v05.gd")

var failures: int = 0

func _ok(condition: bool, message: String) -> void:
    if condition:
        print("PASS: ",message)
    else:
        failures += 1
        printerr("FAIL: ",message)

func _init() -> void:
    var data = GameDataClass.new()
    var rules = RulesV05Class.new(data)
    var state: Dictionary = GameStateClass.create(data)
    rules.ensure_entertainment_fields(state)

    _ok(rules.land_rank(state) == 1,"initial satoyama rank")
    var before_xp: int = int(state["entertainment"]["prosperity_xp"])
    var explore: Dictionary = rules.explore_mountain(state)
    _ok(bool(explore.get("ok",false)),"mountain exploration succeeds")
    _ok(int(state["entertainment"]["explores_this_month"]) == 1,"exploration counter increments")
    _ok(int(state["entertainment"]["prosperity_xp"]) > before_xp,"exploration grows satoyama")

    var sequence := [
        ["collect","coop"],
        ["work","compost"],
        ["month",""],
        ["loop","sansai"],
        ["collect","sansai"],
        ["sell",""]
    ]
    var final_result: Dictionary = {}
    for step in sequence:
        final_result = rules.register_loop_action(state,str(step[0]),str(step[1]))
    _ok(bool(final_result.get("complete",false)),"six-step ecology chain completes")
    _ok(int(state["entertainment"]["chains_completed"]) == 1,"completed chain counted")
    _ok(int(state["entertainment"]["chain_stage"]) == 0,"chain resets after completion")
    _ok(int(final_result.get("bonus",0)) > 0,"chain awards bonus")

    state["entertainment"]["explores_this_month"] = 2
    rules.next_month(state)
    _ok(int(state["entertainment"]["explores_this_month"]) == 0,"monthly exploration allowance resets")

    print("V0.5 ENTERTAINMENT TESTS COMPLETE failures=",failures)
    quit(1 if failures > 0 else 0)
