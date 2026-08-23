extends SceneTree

const GameDataClass = preload("res://scripts/core/game_data.gd")
const GameStateClass = preload("res://scripts/core/game_state.gd")
const RulesV07Class = preload("res://scripts/core/game_rules_v07.gd")

var failures: int = 0

func _ok(condition: bool, message: String) -> void:
    if condition:
        print("PASS: ",message)
    else:
        failures += 1
        printerr("FAIL: ",message)

func _init() -> void:
    var data = GameDataClass.new()
    var rules = RulesV07Class.new(data)
    var state: Dictionary = GameStateClass.create(data)
    rules.ensure_product_fields(state)

    state["inventory"]["eggs"] = 4
    state["inventory"]["taranome"] = 2
    var before_money: int = int(state["money"])
    var sold: Dictionary = rules.sell_basket(state,"roadside")
    _ok(bool(sold.get("ok",false)),"basket sale succeeds")
    _ok(int(state["inventory"]["eggs"]) == 0,"basket sale clears eggs")
    _ok(int(state["inventory"]["taranome"]) == 0,"basket sale clears sansai")
    _ok(int(state["money"]) > before_money,"basket sale adds money")
    _ok(str(sold.get("feedback","")) == "sell","basket sale emits sell feedback")

    var empty: Dictionary = rules.sell_basket(state,"roadside")
    _ok(not bool(empty.get("ok",true)),"empty basket cannot sell")

    print("V0.7 PRODUCT UI TESTS COMPLETE failures=",failures)
    quit(1 if failures > 0 else 0)
