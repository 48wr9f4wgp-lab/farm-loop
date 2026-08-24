extends "res://scripts/ui/main_v12.gd"

const RulesV13Class = preload("res://scripts/core/game_rules_v13.gd")
const MarketScreenClass = preload("res://scripts/ui/screens/market_screen.gd")

var market_screen

func _ready() -> void:
    super._ready()
    rules = RulesV13Class.new(data)
    rules.ensure_route_fields(state)
    state["version"] = "godot-1.3-market-product"
    save_service.save(state)
    _header()
    _show_tab(current_tab)

func _build_market() -> void:
    if market_screen == null:
        market_screen = MarketScreenClass.new()
    market_screen.build(self)
