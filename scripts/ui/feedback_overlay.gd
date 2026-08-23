class_name FeedbackOverlay
extends Control

var reduced_motion := false

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE

func set_reduced_motion(enabled: bool) -> void:
    reduced_motion = enabled

func pop(text: String, tier: int = 1) -> void:
    if tier >= 3 and not reduced_motion:
        _reward_burst(tier)
    if tier >= 4 and not reduced_motion:
        _major_flash()

    var label := Label.new()
    label.text = text
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    label.add_theme_font_size_override("font_size", 15 if tier < 4 else 19)
    label.add_theme_color_override("font_color", Color.WHITE)

    var style := StyleBoxFlat.new()
    style.bg_color = Color("#193b2d") if tier < 3 else (Color("#6f5728") if tier == 3 else Color("#9b6d28"))
    style.border_width_left = 1
    style.border_width_right = 1
    style.border_width_top = 1
    style.border_width_bottom = 1
    style.border_color = Color(1.0,0.88,0.55,0.45) if tier >= 3 else Color(1.0,1.0,1.0,0.12)
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
    label.pivot_offset = label.size * 0.5
    add_child(label)

    if reduced_motion:
        await get_tree().create_timer(0.8).timeout
        if is_instance_valid(label):
            label.queue_free()
        return

    label.modulate.a = 0.0
    label.position.y += 18.0
    label.scale = Vector2(0.94,0.94) if tier >= 3 else Vector2.ONE
    var tw := create_tween()
    tw.set_trans(Tween.TRANS_QUAD)
    tw.set_ease(Tween.EASE_OUT)
    tw.tween_property(label, "modulate:a", 1.0, 0.10)
    tw.parallel().tween_property(label, "position:y", label.position.y-18.0, 0.18)
    if tier >= 3:
        tw.parallel().tween_property(label, "scale", Vector2(1.04,1.04), 0.14)
        tw.tween_property(label, "scale", Vector2.ONE, 0.10)
    tw.tween_interval(0.58 + float(tier)*0.07)
    tw.tween_property(label, "modulate:a", 0.0, 0.18)
    tw.finished.connect(label.queue_free)

func _reward_burst(tier: int) -> void:
    var center: Vector2 = get_viewport_rect().size * Vector2(0.5,0.72)
    var count: int = 8 if tier == 3 else 14
    var colors := [Color("#e1b84d"),Color("#f4dd89"),Color("#7eb35e"),Color("#fff8e9")]
    for i in range(count):
        var bit := ColorRect.new()
        bit.mouse_filter = Control.MOUSE_FILTER_IGNORE
        bit.color = colors[i % colors.size()]
        var d: float = 4.0 + float(i%3)
        bit.size = Vector2(d,d)
        bit.pivot_offset = bit.size * 0.5
        bit.position = center - bit.size*0.5
        bit.rotation = float(i)*0.47
        add_child(bit)

        var angle: float = TAU * float(i) / float(count) - PI*0.5
        var distance: float = 46.0 + float((i*17)%30) + float(tier-3)*14.0
        var target: Vector2 = bit.position + Vector2(cos(angle),sin(angle))*distance + Vector2(0,22)
        var tw := create_tween()
        tw.set_trans(Tween.TRANS_QUAD)
        tw.set_ease(Tween.EASE_OUT)
        tw.tween_property(bit,"position",target,0.32+float(i%3)*0.035)
        tw.parallel().tween_property(bit,"rotation",bit.rotation+2.2,0.34)
        tw.tween_property(bit,"modulate:a",0.0,0.18)
        tw.finished.connect(bit.queue_free)

func _major_flash() -> void:
    var flash := ColorRect.new()
    flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
    flash.color = Color(1.0,0.91,0.55,0.13)
    flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(flash)
    var tw := create_tween()
    tw.tween_property(flash,"modulate:a",0.0,0.24)
    tw.finished.connect(flash.queue_free)
