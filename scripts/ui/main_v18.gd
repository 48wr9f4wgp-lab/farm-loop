extends "res://scripts/ui/main_v17.gd"

const FarmScreenV3Class = preload("res://scripts/ui/screens/farm_screen_v3.gd")

func _build_shell() -> void:
    super._build_shell()
    # Standalone iPhone Web runs under the status bar because viewport-fit=cover.
    # Reserve a deliberate top safe zone so the YUKISATO brand never collides
    # with the clock / Dynamic Island area.
    if root_box != null:
        root_box.offset_top = 38
        root_box.offset_bottom = -12
    if root_box != null and root_box.get_child_count() > 0:
        var head = root_box.get_child(0)
        if head is HBoxContainer and head.get_child_count() > 0:
            var brand = head.get_child(0)
            if brand is VBoxContainer and brand.get_child_count() > 1:
                var title = brand.get_child(0)
                if title is Label:
                    title.add_theme_font_size_override("font_size",29)
                var subtitle = brand.get_child(1)
                if subtitle is Label:
                    subtitle.text = "YUKISATO"
                    subtitle.add_theme_font_size_override("font_size",9)

func _build_farm() -> void:
    FarmScreenV3Class.new().build(self)
