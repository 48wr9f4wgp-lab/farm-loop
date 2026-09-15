extends "res://scripts/ui/main_v26.gd"

const FarmScreenV12Class = preload("res://scripts/ui/screens/farm_screen_v12.gd")

func _build_farm() -> void:
    FarmScreenV12Class.new().build(self)
