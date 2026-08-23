extends SceneTree

const GameDataClass = preload("res://scripts/core/game_data.gd")
const GameStateClass = preload("res://scripts/core/game_state.gd")
const RulesV06Class = preload("res://scripts/core/game_rules_v06.gd")

var failures: int = 0

func _ok(condition: bool, message: String) -> void:
    if condition:
        print("PASS: ",message)
    else:
        failures += 1
        printerr("FAIL: ",message)

func _init() -> void:
    var data = GameDataClass.new()
    var rules = RulesV06Class.new(data)
    var state: Dictionary = GameStateClass.create(data)
    rules.ensure_product_fields(state)

    var daily: Dictionary = rules.daily_summary(state)
    _ok(int(daily["harvest"]) == 0,"daily harvest starts at zero")
    _ok(int(daily["explore"]) == 0,"daily explore starts at zero")
    _ok(int(daily["sell"]) == 0,"daily sell starts at zero")
    _ok(not bool(daily["claimed"]),"daily reward starts unclaimed")

    rules.track_daily_action(state,"collect","coop")
    rules.track_daily_action(state,"collect","sansai")
    rules.track_daily_action(state,"major","mountain")
    var before_money: int = int(state["money"])
    var finish: Dictionary = rules.track_daily_action(state,"sell","")
    _ok(bool(finish.get("completed_now",false)),"daily notebook completes after three goals")
    _ok(int(state["money"]) > before_money,"daily notebook awards money")
    daily = rules.daily_summary(state)
    _ok(bool(daily["claimed"]),"daily notebook reward is claimed once")
    _ok(int(daily["total_completed"]) == 1,"daily completion total increments")

    var second: Dictionary = rules.track_daily_action(state,"sell","")
    _ok(not bool(second.get("completed_now",false)),"daily reward cannot be claimed twice")

    print("V0.6 PRODUCT TESTS COMPLETE failures=",failures)
    quit(1 if failures > 0 else 0)
