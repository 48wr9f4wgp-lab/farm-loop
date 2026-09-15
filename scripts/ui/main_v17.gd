extends "res://scripts/ui/main_v16.gd"

const FarmScreenV2Class = preload("res://scripts/ui/screens/farm_screen_v2.gd")

func _build_farm() -> void:
    FarmScreenV2Class.new().build(self)
