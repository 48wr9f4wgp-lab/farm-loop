class_name FarmMapV09
extends "res://scripts/ui/farm_map.gd"

func _draw() -> void:
    var s: Vector2 = size
    if s.x <= 0.0 or s.y <= 0.0:
        return
    _draw_environment(s)
    _draw_terrain_details(s)
    _draw_ambient_life(s)
    _draw_weather(s)
