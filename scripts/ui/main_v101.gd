extends "res://scripts/ui/main_v10.gd"

func _ready() -> void:
    super._ready()
    state["version"] = "godot-1.0.1-pwa-polish"
    save_service.save(state)

func _build_shell() -> void:
    super._build_shell()
    for id in nav_buttons:
        var b: Button = nav_buttons[id]
        b.custom_minimum_size.y = 46

func _build_farm() -> void:
    super._build_farm()
    if selected_action_button != null:
        selected_action_button.custom_minimum_size.y = 50
    if map != null:
        var h: float = get_viewport_rect().size.y
        map.custom_minimum_size.y = clampf(h * 0.44,385.0,420.0)

func _daily_row(label_text: String, value: int, target: int) -> HBoxContainer:
    var row := HBoxContainer.new()
    row.custom_minimum_size.y = 24
    var label := Label.new()
    label.text = label_text
    label.add_theme_font_size_override("font_size",13)
    label.add_theme_color_override("font_color",INK)
    label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    row.add_child(label)
    var done := Label.new()
    done.text = "%d / %d" % [mini(value,target),target]
    done.add_theme_font_size_override("font_size",13)
    done.add_theme_color_override("font_color",GREEN if value >= target else MUTED)
    row.add_child(done)
    return row
