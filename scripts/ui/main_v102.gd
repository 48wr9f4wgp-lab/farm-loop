extends "res://scripts/ui/main_v101.gd"

func _ready() -> void:
    get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
    get_tree().root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
    get_tree().root.content_scale_stretch = Window.CONTENT_SCALE_STRETCH_FRACTIONAL
    super._ready()
    state["version"] = "godot-1.0.2-iphone-pwa"
    save_service.save(state)

func _daily_row(label_text: String, value: int, target: int) -> HBoxContainer:
    var row := HBoxContainer.new()
    row.add_theme_constant_override("separation",8)

    var label := Label.new()
    label.text = label_text
    label.add_theme_font_size_override("font_size",13)
    label.add_theme_color_override("font_color",INK)
    label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    row.add_child(label)

    var done := Label.new()
    done.text = "%d / %d" % [mini(value,target),target]
    done.add_theme_font_size_override("font_size",13)
    done.add_theme_color_override("font_color",GREEN_DARK if value >= target else MUTED)
    row.add_child(done)
    return row

func _build_shell() -> void:
    super._build_shell()
    for id in nav_buttons:
        var b: Button = nav_buttons[id]
        b.custom_minimum_size.y = maxf(b.custom_minimum_size.y,46.0)

func _build_farm() -> void:
    super._build_farm()
    if map != null:
        map.custom_minimum_size.y = maxf(map.custom_minimum_size.y,385.0)
