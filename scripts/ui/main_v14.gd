extends "res://scripts/ui/main_v13.gd"

const CurrentRulesClass = preload("res://scripts/core/game_rules_current.gd")
const VillageScreenClass = preload("res://scripts/ui/screens/village_screen.gd")

func _ready() -> void:
    super._ready()
    rules = CurrentRulesClass.new(data)
    rules.ensure_route_fields(state)
    rules.ensure_requests(state)
    state["version"] = "godot-1.4-village-product"
    save_service.save(state)
    _header()
    _show_tab(current_tab)

func _build_village() -> void:
    VillageScreenClass.new().build(self)
