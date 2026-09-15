extends "res://scripts/ui/main_v27.gd"

const FarmScreenV13Class = preload("res://scripts/ui/screens/farm_screen_v13.gd")

func _build_farm() -> void:
    FarmScreenV13Class.new().build(self)
