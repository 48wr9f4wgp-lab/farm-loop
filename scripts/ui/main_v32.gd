extends "res://scripts/ui/main_v31.gd"

const FarmScreenV4PuzzleM5Class = preload("res://scripts/ui/screens/farm_screen_v4_puzzle_m5.gd")

var v4_m5_screen = FarmScreenV4PuzzleM5Class.new()

func _ready() -> void:
    super._ready()
    state["version"] = "godot-v4-circulation-puzzle-m5"
    save_service.save(state)
    _show_tab("farm")

func _build_farm() -> void:
    v4_m5_screen.build(self)
