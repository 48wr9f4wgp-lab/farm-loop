extends "res://scripts/ui/main_v18.gd"

const FarmScreenV4Class = preload("res://scripts/ui/screens/farm_screen_v4.gd")

func _build_farm() -> void:
    FarmScreenV4Class.new().build(self)
