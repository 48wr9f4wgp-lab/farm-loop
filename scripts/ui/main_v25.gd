extends "res://scripts/ui/main_v24.gd"

const FarmScreenV10Class = preload("res://scripts/ui/screens/farm_screen_v10.gd")

func _build_farm() -> void:
    FarmScreenV10Class.new().build(self)
