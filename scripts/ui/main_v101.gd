extends "res://scripts/ui/main_v10.gd"

func _build_farm() -> void:
    super._build_farm()
    if selected_action_button != null:
        selected_action_button.custom_minimum_size.y = 50
