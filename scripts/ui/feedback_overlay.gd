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

func fly_tokens(kind: String, count: int = 6) -> void:
    if reduced_motion:
        return
    var start := get_viewport_rect().size * Vector2(0.52,0.70)
    var target := get_viewport_rect().size * Vector2(0.82,0.07)
    var glyph := "＋"
    var base_color := Color("#7db861")
    if kind == "sell":
        glyph = "¥"
        base_color = Color("#e1b84d")
    elif kind in ["mission","major","upgrade"]:
        glyph = "◆"
        base_color = Color("#e6c76a")
    for i in range(clampi(count,3,10)):
        var token := Label.new()
        token.text = glyph
        token.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        token.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
        token.add_theme_font_size_override("font_size", 13 + i%3)
        token.add_theme_color_override("font_color", base_color.lightened(float(i%3)*0.08))
        token.size = Vector2(28,28)
        token.pivot_offset = token.size * 0.5
        token.position = start + Vector2(float((i*19)%44)-22.0,float((i*13)%30)-15.0)
        add_child(token)
        var mid := token.position.lerp(target,0.48) + Vector2(float((i%3)-1)*35.0,-55.0-float(i%2)*18.0)
        var tw := create_tween()
        tw.set_trans(Tween.TRANS_QUAD)
        tw.set_ease(Tween.EASE_OUT)
        tw.tween_property(token,"position",mid,0.20+float(i)*0.012)
        tw.set_ease(Tween.EASE_IN)
        tw.tween_property(token,"position",target,0.20)
        tw.parallel().tween_property(token,"scale",Vector2(0.62,0.62),0.20)
        tw.tween_property(token,"modulate:a",0.0,0.08)
        tw.finished.connect(token.queue_free)

func season_transition(season_name: String) -> void:
    var veil := ColorRect.new()
    veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
    veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    veil.color = Color("#f4f0df")
    veil.modulate.a = 0.0
    add_child(veil)

    var card := Label.new()
    card.text = "%sが来た" % season_name
    card.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    card.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    card.add_theme_font_size_override("font_size",24)
    card.add_theme_color_override("font_color",Color("#244a36"))
    var style := StyleBoxFlat.new()
    style.bg_color = Color("#fffaf0")
    style.border_width_left = 1
    style.border_width_right = 1
    style.border_width_top = 1
    style.border_width_bottom = 1
    style.border_color = Color("#d6bd78")
    style.corner_radius_top_left = 18
    style.corner_radius_top_right = 18
    style.corner_radius_bottom_left = 18
    style.corner_radius_bottom_right = 18
    card.add_theme_stylebox_override("normal",style)
    card.set_anchors_preset(Control.PRESET_CENTER)
    card.position = Vector2(-120,-42)
    card.size = Vector2(240,84)
    card.pivot_offset = card.size*0.5
    add_child(card)

    if reduced_motion:
        veil.modulate.a = 0.32
        await get_tree().create_timer(0.65).timeout
        veil.queue_free()
        card.queue_free()
        return

    card.scale = Vector2(0.86,0.86)
    card.modulate.a = 0.0
    var tw := create_tween()
    tw.tween_property(veil,"modulate:a",0.42,0.16)
    tw.parallel().tween_property(card,"modulate:a",1.0,0.16)
    tw.parallel().tween_property(card,"scale",Vector2(1.03,1.03),0.22)
    tw.tween_property(card,"scale",Vector2.ONE,0.10)
    tw.tween_interval(0.55)
    tw.tween_property(card,"modulate:a",0.0,0.20)
    tw.parallel().tween_property(veil,"modulate:a",0.0,0.20)
    tw.finished.connect(func() -> void:
        if is_instance_valid(card): card.queue_free()
        if is_instance_valid(veil): veil.queue_free()
    )

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
