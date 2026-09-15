extends "res://scripts/ui/main_v25.gd"

const FarmScreenV11Class = preload("res://scripts/ui/screens/farm_screen_v11.gd")

func _build_farm() -> void:
    FarmScreenV11Class.new().build(self)
