extends "res://scripts/ui/main_v19.gd"

const FarmScreenV5Class = preload("res://scripts/ui/screens/farm_screen_v5.gd")

func _build_farm() -> void:
    FarmScreenV5Class.new().build(self)
