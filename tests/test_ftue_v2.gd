extends SceneTree

const GameDataClass = preload("res://scripts/core/game_data.gd")
const GameStateClass = preload("res://scripts/core/game_state.gd")
const FtueClass = preload("res://scripts/core/ftue_service.gd")

var failures: int = 0

func _ok(condition: bool, message: String) -> void:
    if condition:
        print("PASS: ",message)
    else:
        failures += 1
        printerr("FAIL: ",message)

func _good(feedback: String = "work", route: String = "") -> Dictionary:
    var out := {"ok":true,"feedback":feedback,"tier":2,"msg":"ok"}
    if not route.is_empty(): out["route"] = route
    return out

func _init() -> void:
    var data = GameDataClass.new()
    var ftue = FtueClass.new(data)
    var state: Dictionary = GameStateClass.create(data)

    ftue.ensure_state(state)
    _ok(ftue.active(state),"fresh player enters FTUE v2")
    _ok(ftue.step(state) == 0,"fresh FTUE starts at coop")
    _ok("鶏舎" in ftue.objective(state),"first objective is concrete coop action")

    var tr: Dictionary = ftue.on_action(state,"collect","coop",_good("collect"))
    _ok(bool(tr.get("advanced",false)) and ftue.step(state) == 1,"coop advances to materials")
    _ok(not bool(ftue.on_action(state,"work","",_good()).get("advanced",false)),"unrelated work cannot skip materials")

    tr = ftue.on_action(state,"work","materials",_good("work"))
    _ok(bool(tr.get("advanced",false)) and ftue.step(state) == 2,"materials advance to compost")
    tr = ftue.on_action(state,"work","compost",_good("work"))
    _ok(bool(tr.get("advanced",false)) and ftue.step(state) == 3,"compost advances to month transition")
    tr = ftue.on_action(state,"month","",_good("month"))
    _ok(bool(tr.get("advanced",false)) and ftue.step(state) == 4,"month advances to compost return")
    tr = ftue.on_action(state,"loop","sansai",_good("loop"))
    _ok(bool(tr.get("advanced",false)) and ftue.step(state) == 5,"compost return advances to sansai")
    tr = ftue.on_action(state,"collect","sansai",_good("collect"))
    _ok(bool(tr.get("advanced",false)) and ftue.step(state) == 6,"sansai advances to mountain choice")

    tr = ftue.on_action(state,"collect","mountain",_good("collect","stream"))
    _ok(bool(tr.get("advanced",false)) and ftue.step(state) == 7,"route choice advances to village purpose")
    var starter_found: bool = false
    for request in state["village_requests"]:
        if str(request.get("id","")) == "mio_eggs": starter_found = true
    _ok(starter_found,"FTUE guarantees understandable starter village request")

    tr = ftue.on_tab(state,"village")
    _ok(bool(tr.get("advanced",false)) and ftue.step(state) == 8,"village view advances to market payoff")
    _ok("販売" in ftue.objective(state),"final guided beat points to market")

    tr = ftue.on_action(state,"sell","",_good("sell"))
    _ok(bool(tr.get("advanced",false)) and bool(tr.get("completed",false)),"market sale completes guided FTUE")
    _ok(not ftue.active(state) and ftue.step(state) == 9,"post-sale play is free-form")

    var existing: Dictionary = GameStateClass.create(data)
    existing["tutorial_step"] = 6
    ftue.ensure_state(existing)
    _ok(not ftue.active(existing),"completed legacy player is not forced through FTUE again")

    var mid: Dictionary = GameStateClass.create(data)
    mid["tutorial_step"] = 2
    ftue.ensure_state(mid)
    _ok(ftue.step(mid) == 3,"legacy mid-tutorial maps safely into current sequence")

    print("FTUE V2 CONTRACT COMPLETE failures=",failures)
    quit(1 if failures > 0 else 0)
