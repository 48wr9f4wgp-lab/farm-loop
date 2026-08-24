extends "res://scripts/ui/main_v15.gd"

const FacilityActionOverlayV16Class = preload("res://scripts/ui/facility_action_overlay_v16.gd")

func _ready() -> void:
    super._ready()
    state["version"] = "godot-1.6-motion-audio"
    save_service.save(state)
    _header()
    _show_tab(current_tab)

func _show_tab(tab: String) -> void:
    super._show_tab(tab)
    if content == null or not is_node_ready():
        return
    var reduce: bool = bool(state.get("settings",{}).get("reduced_motion",false))
    if reduce:
        content.modulate.a = 1.0
        return
    content.modulate.a = 0.38
    var tw := create_tween()
    tw.set_trans(Tween.TRANS_QUAD)
    tw.set_ease(Tween.EASE_OUT)
    tw.tween_property(content,"modulate:a",1.0,0.14)

func _build_farm() -> void:
    super._build_farm()
    if map == null:
        return
    var action_fx = FacilityActionOverlayV16Class.new()
    action_fx.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    action_fx.mouse_filter = Control.MOUSE_FILTER_IGNORE
    map.add_child(action_fx)
