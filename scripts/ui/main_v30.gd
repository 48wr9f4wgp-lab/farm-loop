extends "res://scripts/ui/main_v29.gd"

const FarmScreenV15Class = preload("res://scripts/ui/screens/farm_screen_v15.gd")

func _build_farm() -> void:
    FarmScreenV15Class.new().build(self)
