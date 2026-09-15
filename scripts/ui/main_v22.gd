extends "res://scripts/ui/main_v21.gd"

const FarmScreenV7Class = preload("res://scripts/ui/screens/farm_screen_v7.gd")

func _build_farm() -> void:
    FarmScreenV7Class.new().build(self)
