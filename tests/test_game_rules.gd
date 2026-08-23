extends SceneTree

const GameDataClass = preload("res://scripts/core/game_data.gd")
const GameStateClass = preload("res://scripts/core/game_state.gd")
const GameRulesClass = preload("res://scripts/core/game_rules.gd")

var failures := 0
func expect_true(value: bool, label: String) -> void:
    if not value:
        failures += 1; printerr("FAIL: ",label)
    else: print("PASS: ",label)

func _initialize() -> void:
    var data = GameDataClass.new(); var rules = GameRulesClass.new(data); var s = GameStateClass.create(data)
    expect_true(rules.harvest(s,"coop")["ok"],"coop harvest")
    expect_true(s["inventory"]["manure"] >= 4,"manure created")
    expect_true(rules.harvest(s,"compost")["ok"],"compost queued")
    rules.next_month(s)
    expect_true(s["inventory"]["compost"] >= 1,"compost completed next month")
    s["month"] = 4; s["ready"]["sansai"] = true
    expect_true(rules.apply_compost(s)["ok"],"compost applied")
    expect_true(rules.harvest(s,"sansai")["ok"],"sansai harvest")
    expect_true(s["inventory"]["taranome"] > 0,"taranome gained")
    var before := s["money"]
    expect_true(rules.sell_all(s,"taranome","roadside")["ok"],"sell taranome")
    expect_true(s["money"] > before,"money increases")
    print("TESTS COMPLETE failures=",failures)
    quit(1 if failures else 0)
