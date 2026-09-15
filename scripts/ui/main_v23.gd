extends "res://scripts/ui/main_v22.gd"

const FarmScreenV8Class = preload("res://scripts/ui/screens/farm_screen_v8.gd")

func _build_shell() -> void:
    super._build_shell()

    # Keep the whole HUD inside the portrait viewport. On wider/taller iPhones
    # the previous primary row allowed the money chip to exceed the right edge.
    if root_box != null:
        root_box.offset_left = 10
        root_box.offset_right = -10

    if season_chip != null:
        season_chip.add_theme_font_size_override("font_size",13)
        season_chip.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        season_chip.custom_minimum_size.x = 0

    if money_chip != null:
        money_chip.add_theme_font_size_override("font_size",12)
        money_chip.size_flags_horizontal = Control.SIZE_FILL
        money_chip.custom_minimum_size.x = 78
        money_chip.clip_text = true
        var money_style := _chip_style(Color("#fff2c9"))
        money_style.content_margin_left = 7
        money_style.content_margin_right = 7
        money_chip.add_theme_stylebox_override("normal",money_style)

func _build_farm() -> void:
    FarmScreenV8Class.new().build(self)
