extends "res://scripts/ui/main_v17.gd"

const FarmScreenV3Class = preload("res://scripts/ui/screens/farm_screen_v3.gd")

func _build_farm() -> void:
    FarmScreenV3Class.new().build(self)
