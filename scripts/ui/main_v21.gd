extends "res://scripts/ui/main_v20.gd"

const FarmScreenV6Class = preload("res://scripts/ui/screens/farm_screen_v6.gd")

func _build_farm() -> void:
    FarmScreenV6Class.new().build(self)
