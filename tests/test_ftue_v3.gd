extends SceneTree

const GameDataClass = preload("res://scripts/core/game_data.gd")
const GameStateClass = preload("res://scripts/core/game_state.gd")
const RulesClass = preload("res://scripts/core/game_rules_current.gd")
const FtueV3Class = preload("res://scripts/core/ftue_service_v3.gd")

var failures: int = 0

func _ok(condition: bool, message: String) -> void:
    if condition:
        print("PASS: ",message)
    else:
        failures += 1
        printerr("FAIL: ",message)

func _advance_action(ftue, state: Dictionary, result: Dictionary, facility: String, expected_from: int, expected_to: int) -> void:
    _ok(bool(result.get("ok",false)),"V3 gameplay action succeeds at step %d" % expected_from)
    _ok(ftue.step(state) == expected_from,"V3 does not auto-skip before action %d" % expected_from)
    var transition: Dictionary = ftue.on_action(state,str(result.get("feedback","")),facility,result)
    _ok(bool(transition.get("advanced",false)),"V3 action advances step %d" % expected_from)
    _ok(int(transition.get("from_step",-1)) == expected_from,"V3 transition records source step %d" % expected_from)
    _ok(ftue.step(state) == expected_to,"V3 reaches step %d" % expected_to)

func _init() -> void:
    var data = GameDataClass.new()
    var rules = RulesClass.new(data)
    rules.rng.seed = 24681357
    var state: Dictionary = GameStateClass.create(data)
    rules.ensure_product_fields(state)
    rules.ensure_route_fields(state)
    rules.ensure_requests(state)

    var ftue = FtueV3Class.new(data)
    ftue.ensure_state(state)
    ftue.reconcile(state)

    _ok(ftue.active(state),"fresh save enters FTUE v3")
    _ok(ftue.step(state) == 0,"fresh save starts at V3 step 0")
    _ok(ftue.restoration_stage(state) == 0,"fresh restoration patch starts damaged")
    _ok("鶏舎" in ftue.objective(state),"V3 first objective points to coop")
    _ok(bool(state["restoration_v3"].get("proof_mode",false)),"restore proof mode is enabled")

    var coop: Dictionary = rules.harvest(state,"coop")
    _advance_action(ftue,state,coop,"coop",0,1)
    _ok(int(state["inventory"].get("manure",0)) >= 4,"coop creates enough manure for restore loop")

    var materials: Dictionary = rules.gather_leaves(state)
    _advance_action(ftue,state,materials,"materials",1,2)
    _ok(int(state["inventory"].get("leaves",0)) >= 2,"organic matter is available for compost")

    var compost_start: Dictionary = rules.harvest(state,"compost")
    _ok(int(state.get("compost_queue",0)) > 0,"compost queues fermentation")
    _advance_action(ftue,state,compost_start,"compost",2,3)

    var month: Dictionary = rules.next_month(state)
    _ok(int(state["inventory"].get("compost",0)) > 0,"month advance finishes compost")
    _advance_action(ftue,state,month,"",3,4)

    var compost_use: Dictionary = rules.apply_compost(state)
    _advance_action(ftue,state,compost_use,"sansai",4,5)
    _ok(ftue.restoration_stage(state) == 1,"returning compost visibly marks patch restored")
    _ok(int(state["restoration_v3"].get("patches_restored",0)) >= 1,"restored patch count advances")

    var village_visit: Dictionary = ftue.on_tab(state,"village")
    _ok(not bool(village_visit.get("advanced",false)),"village is not a V3 proof beat")
    _ok(ftue.step(state) == 5,"visiting village cannot skip the restoration payoff")

    var sansai: Dictionary = rules.harvest(state,"sansai")
    _advance_action(ftue,state,sansai,"sansai",5,6)
    _ok(ftue.restoration_stage(state) == 2,"harvest upgrades restored patch to thriving stage")
    _ok(bool(state["ftue_v3"].get("completed",false)),"V3 FTUE marks completion after restoration harvest")
    _ok(not ftue.active(state),"V3 unlocks free play after restore loop")
    _ok(state["ftue_v3"].get("completed_steps",[]).size() == 6,"all six V3 action beats are recorded")

    var legacy: Dictionary = GameStateClass.create(data)
    legacy["ftue_v2"] = {"step":9,"active":false,"completed":true}
    legacy["loop_score"] = 25
    var legacy_ftue = FtueV3Class.new(data)
    legacy_ftue.ensure_state(legacy)
    legacy_ftue.reconcile(legacy)
    _ok(legacy_ftue.step(legacy) == 6 and not legacy_ftue.active(legacy),"completed V2 save is not forced through V3 FTUE")
    _ok(legacy_ftue.restoration_stage(legacy) == 2,"completed V2 save receives compatible restored-land state")

    var recovery: Dictionary = GameStateClass.create(data)
    var recovery_ftue = FtueV3Class.new(data)
    recovery_ftue.ensure_state(recovery)
    recovery["ftue_v3"]["step"] = 4
    recovery["buffs"]["field"] = 1
    recovery_ftue.reconcile(recovery)
    _ok(recovery_ftue.step(recovery) == 5,"boot recovery recognizes already-applied compost")
    _ok(recovery_ftue.restoration_stage(recovery) == 1,"boot recovery repairs restoration visual state")

    print("VERTICAL SLICE FTUE V3 RESTORE CONTRACT COMPLETE failures=",failures)
    quit(1 if failures > 0 else 0)
