extends "res://scripts/ui/main_v11.gd"

const RulesV12Class = preload("res://scripts/core/game_rules_v12.gd")
const WorkScreenClass = preload("res://scripts/ui/screens/work_screen.gd")

func _ready() -> void:
    super._ready()
    rules = RulesV12Class.new(data)
    rules.ensure_route_fields(state)
    state["version"] = "godot-1.2-route-adventure"
    save_service.save(state)
    _header()
    _show_tab(current_tab)

func _build_work() -> void:
    WorkScreenClass.new().build(self)

func _on_route_explore(route_id: String) -> void:
    if not rules.has_method("explore_route"):
        return
    _commit(rules.explore_route(state,route_id),"work","mountain_" + route_id)
