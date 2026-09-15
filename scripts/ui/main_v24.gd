extends "res://scripts/ui/main_v23.gd"

const FarmScreenV9Class = preload("res://scripts/ui/screens/farm_screen_v9.gd")

func _build_shell() -> void:
    super._build_shell()

    # Physical iPhone showed the primary HUD row too close to the right edge.
    # Keep a deliberate right gutter and allow the season label to shrink.
    if root_box != null:
        root_box.offset_left = 12
        root_box.offset_right = -24

    if season_chip != null:
        season_chip.add_theme_font_size_override("font_size",12)
        season_chip.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        season_chip.custom_minimum_size.x = 0
        season_chip.clip_text = true
        season_chip.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS

    if money_chip != null:
        money_chip.add_theme_font_size_override("font_size",11)
        money_chip.size_flags_horizontal = Control.SIZE_SHRINK_END
        money_chip.custom_minimum_size.x = 66
        money_chip.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        money_chip.clip_text = true
        var money_style := _chip_style(Color("#fff2c9"))
        money_style.content_margin_left = 5
        money_style.content_margin_right = 5
        money_style.content_margin_top = 7
        money_style.content_margin_bottom = 7
        money_chip.add_theme_stylebox_override("normal",money_style)

    if season_chip != null and season_chip.get_parent() is Control:
        var primary := season_chip.get_parent() as Control
        primary.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        primary.clip_contents = true

func _build_farm() -> void:
    FarmScreenV9Class.new().build(self)
