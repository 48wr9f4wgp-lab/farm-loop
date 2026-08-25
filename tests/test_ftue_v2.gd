extends SceneTree

const GameDataClass = preload("res://scripts/core/game_data.gd")
const GameStateClass = preload("res://scripts/core/game_state.gd")
const RulesClass = preload("res://scripts/core/game_rules_current.gd")
const FtueClass = preload("res://scripts/core/ftue_service.gd")

var failures: int = 0

func _ok(condition: bool, message: String) -> void:
    if condition:
        print("PASS: ",message)
    else:
        failures += 1
        printerr("FAIL: ",message)

func _advance_action(ftue, state: Dictionary, result: Dictionary, facility: String, expected_from: int, expected_to: int) -> void:
    _ok(bool(result.get("ok",false)),"FTUE gameplay action succeeds at step %d" % expected_from)
    _ok(ftue.step(state) == expected_from,"FTUE does not auto-skip before action contract %d" % expected_from)
    var transition: Dictionary = ftue.on_action(state,str(result.get("feedback","")),facility,result)
    _ok(bool(transition.get("advanced",false)),"FTUE action advances step %d" % expected_from)
    _ok(int(transition.get("from_step",-1)) == expected_from,"FTUE transition records source step %d" % expected_from)
    _ok(ftue.step(state) == expected_to,"FTUE reaches step %d" % expected_to)

func _init() -> void:
    var data = GameDataClass.new()
    var rules = RulesClass.new(data)
    rules.rng.seed = 24681357
    var state: Dictionary = GameStateClass.create(data)
    rules.ensure_product_fields(state)
    rules.ensure_route_fields(state)
    rules.ensure_requests(state)

    var ftue = FtueClass.new(data)
    ftue.ensure_state(state)
    ftue.reconcile(state)

    _ok(ftue.active(state),"fresh save enters FTUE v2")
    _ok(ftue.step(state) == 0,"fresh save starts at FTUE step 0")
    _ok("鶏舎" in ftue.objective(state),"first objective points to chicken coop")

    var coop: Dictionary = rules.harvest(state,"coop")
    _advance_action(ftue,state,coop,"coop",0,1)
    _ok(int(state["inventory"].get("manure",0)) >= 4,"coop creates enough manure for compost")

    var materials: Dictionary = rules.gather_leaves(state)
    _advance_action(ftue,state,materials,"materials",1,2)
    _ok(int(state["inventory"].get("leaves",0)) >= 2,"material beat leaves enough compost input")

    var compost_start: Dictionary = rules.harvest(state,"compost")
    _ok(int(state.get("compost_queue",0)) > 0,"compost action queues fermentation")
    _ok(ftue.step(state) == 2,"live compost state does not auto-reconcile before action")
    _advance_action(ftue,state,compost_start,"compost",2,3)

    var month: Dictionary = rules.next_month(state)
    _ok(int(state["inventory"].get("compost",0)) > 0,"month advance finishes compost")
    _ok(int(state["month"]) == 5,"FTUE month beat advances April to May")
    _advance_action(ftue,state,month,"",3,4)

    var compost_use: Dictionary = rules.apply_compost(state)
    _advance_action(ftue,state,compost_use,"sansai",4,5)
    _ok(int(state["buffs"].get("field",0)) > 0,"compost use visibly buffs field")

    var sansai: Dictionary = rules.harvest(state,"sansai")
    _advance_action(ftue,state,sansai,"sansai",5,6)
    _ok(not bool(state["ready"].get("sansai",true)),"sansai beat consumes monthly readiness")

    var mountain: Dictionary = rules.explore_route(state,"stream")
    _ok(str(mountain.get("route","")) == "stream","mountain result records chosen route")
    _advance_action(ftue,state,mountain,"mountain",6,7)

    var has_starter: bool = false
    var starter: Dictionary = {}
    for request in state["village_requests"]:
        if str(request.get("id","")) == "mio_eggs":
            has_starter = true
            starter = request
            break
    _ok(has_starter,"village beat guarantees starter egg request")
    _ok("雪国鶏舎" in ftue.request_hint(starter),"starter request explains where to get eggs")

    var village_transition: Dictionary = ftue.on_tab(state,"village")
    _ok(bool(village_transition.get("advanced",false)),"viewing village advances FTUE")
    _ok(ftue.step(state) == 8,"village beat reaches final sale step")
    _ok(bool(state["ftue_v2"].get("village_seen",false)),"village view is recorded")

    var preview: Dictionary = rules.basket_preview(state,"roadside")
    _ok(int(preview.get("items",0)) > 0,"final FTUE beat always has sellable stock")
    var sale: Dictionary = rules.sell_basket(state,"roadside")
    _advance_action(ftue,state,sale,"",8,9)
    _ok(bool(state["ftue_v2"].get("completed",false)),"FTUE marks completion")
    _ok(not ftue.active(state),"FTUE unlocks free play after first full loop")
    _ok(state["ftue_v2"].get("completed_steps",[]).size() == 9,"all nine FTUE beats are recorded")

    var legacy: Dictionary = GameStateClass.create(data)
    legacy["tutorial_step"] = 6
    var legacy_ftue = FtueClass.new(data)
    legacy_ftue.ensure_state(legacy)
    legacy_ftue.reconcile(legacy)
    _ok(legacy_ftue.step(legacy) == 9 and not legacy_ftue.active(legacy),"completed legacy tutorial is not restarted")

    var recovery: Dictionary = GameStateClass.create(data)
    var recovery_ftue = FtueClass.new(data)
    recovery_ftue.ensure_state(recovery)
    recovery["ftue_v2"]["step"] = 2
    recovery["compost_queue"] = 1
    recovery_ftue.reconcile(recovery)
    _ok(recovery_ftue.step(recovery) == 3,"boot recovery can skip a proven completed beat")

    print("VERTICAL SLICE FTUE V2 CONTRACT COMPLETE failures=",failures)
    quit(1 if failures > 0 else 0)
