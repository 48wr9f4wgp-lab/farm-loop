extends "res://scripts/ui/main_v14.gd"

const FarmPolishOverlayV15Class = preload("res://scripts/ui/farm_polish_overlay_v15.gd")

func _ready() -> void:
    super._ready()
    state["version"] = "godot-1.5-farm-final-pass"
    save_service.save(state)
    _header()
    _show_tab(current_tab)

func _build_farm() -> void:
    super._build_farm()
    if map == null:
        return
    map.custom_minimum_size.y = maxf(385.0,map.custom_minimum_size.y)
    var polish = FarmPolishOverlayV15Class.new()
    polish.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    polish.mouse_filter = Control.MOUSE_FILTER_IGNORE
    map.add_child(polish)
    if selected_action_button != null:
        selected_action_button.custom_minimum_size.y = maxf(52.0,selected_action_button.custom_minimum_size.y)
