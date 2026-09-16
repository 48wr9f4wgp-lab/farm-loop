extends "res://scripts/ui/main_v30.gd"

const CirculationStateV4Class = preload("res://scripts/core/circulation_state_v4.gd")
const CirculationRulesV4Class = preload("res://scripts/core/circulation_rules_v4.gd")
const FarmScreenV4PuzzleClass = preload("res://scripts/ui/screens/farm_screen_v4_puzzle.gd")

var v4_screen = FarmScreenV4PuzzleClass.new()

func _ready() -> void:
    super._ready()
    CirculationStateV4Class.ensure_in_state(state)
    state["schema_version"] = 5
    state["version"] = "godot-v4-circulation-puzzle-m4"
    state["ui"]["last_tab"] = "farm"
    _configure_v4_navigation()
    save_service.save(state)
    _show_tab("farm")

func _build_farm() -> void:
    v4_screen.build(self)

func _configure_v4_navigation() -> void:
    for id in nav_buttons:
        var button = nav_buttons[id]
        if button == null:
            continue
        if str(id) in ["work","market","village"]:
            button.visible = false
        elif str(id) == "farm":
            button.text = "里山"
            button.visible = true
        elif str(id) == "settings":
            button.visible = true

func _header() -> void:
    if status_label == null or objective_label == null:
        return
    if state.is_empty() or not state.has("circulation_v4"):
        super._header()
        return

    var board: Dictionary = state["circulation_v4"]
    var month := int(board.get("month",4))
    var season := str(board.get("season",CirculationRulesV4Class.season_for_month(month)))
    status_label.text = "%d年%d月・%s　%s　｜里山回復 %d%%　｜手入れ %d/3" % [
        int(board.get("year",1)),
        month,
        CirculationRulesV4Class.season_name(season),
        str(board.get("weather","晴れ")),
        int(board.get("recovery_score",0)),
        int(board.get("action_points",0))
    ]

    var pending: Array = board.get("pending_actions",[])
    var ap := int(board.get("action_points",0))
    if pending.is_empty():
        objective_label.text = "最初にどこから手を入れる？　山菜区画か沢を直接タップ"
    elif ap > 0:
        objective_label.text = "あと%d手｜別の場所とどうつながるか考える" % ap
    else:
        objective_label.text = "3手使った｜今月を終えて、里山の反応を見る"

func _sync_ambience() -> void:
    if ambience == null or state.is_empty():
        return
    ambience.set_enabled(bool(state.get("settings",{}).get("sound",true)))
    if state.has("circulation_v4"):
        var board: Dictionary = state["circulation_v4"]
        ambience.set_scene(
            str(board.get("season","spring")),
            str(board.get("weather","晴れ"))
        )
    elif rules != null:
        ambience.set_scene(rules.season_key(int(state.get("month",4))),str(state.get("weather","晴れ")))
