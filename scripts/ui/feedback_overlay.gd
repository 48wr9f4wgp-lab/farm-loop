class_name FeedbackOverlay
extends Control

var reduced_motion := false

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE

func set_reduced_motion(enabled: bool) -> void:
    reduced_motion = enabled

func pop(text: String, tier: int = 1) -> void:
    var label := Label.new()
    label.text = text
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    label.add_theme_font_size_override("font_size", 15 if tier < 4 else 19)
    label.add_theme_color_override("font_color", Color.WHITE)
    var style := StyleBoxFlat.new()
    style.bg_color = Color("#193b2d") if tier < 4 else Color("#9b6d28")
    style.corner_radius_top_left = 16
    style.corner_radius_top_right = 16
    style.corner_radius_bottom_left = 16
    style.corner_radius_bottom_right = 16
    style.content_margin_left = 14
    style.content_margin_right = 14
    style.content_margin_top = 9
    style.content_margin_bottom = 9
    label.add_theme_stylebox_override("normal", style)
    label.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
    label.position = Vector2(-135, -142)
    label.size = Vector2(270, 48)
    add_child(label)
    if reduced_motion:
        await get_tree().create_timer(0.8).timeout
        if is_instance_valid(label):
            label.queue_free()
        return
    label.modulate.a = 0.0
    label.position.y += 18.0
    var tw := create_tween()
    tw.set_trans(Tween.TRANS_QUAD)
    tw.set_ease(Tween.EASE_OUT)
    tw.tween_property(label, "modulate:a", 1.0, 0.12)
    tw.parallel().tween_property(label, "position:y", label.position.y-18.0, 0.18)
    tw.tween_interval(0.65 + float(tier)*0.06)
    tw.tween_property(label, "modulate:a", 0.0, 0.18)
    tw.finished.connect(label.queue_free)
