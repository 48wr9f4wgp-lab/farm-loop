extends "res://scripts/ui/main_v05.gd"

const RulesV06Class = preload("res://scripts/core/game_rules_v06.gd")
const ProductMapOverlayClass = preload("res://scripts/ui/product_map_overlay_v06.gd")

var season_chip: Label
var money_chip: Label
var level_chip: Label
var reputation_chip: Label
var loop_chip: Label
var top_scroll: ScrollContainer

func _ready() -> void:
    super._ready()
    rules = RulesV06Class.new(data)
    rules.ensure_product_fields(state)
    state["version"] = "godot-0.6-productization"
    save_service.save(state)
    _header()
    _show_tab(current_tab)

func _panel_style(color := PANEL, radius := 18) -> StyleBoxFlat:
    var style := StyleBoxFlat.new()
    style.bg_color = color
    style.border_width_left = 1
    style.border_width_right = 1
    style.border_width_top = 1
    style.border_width_bottom = 1
    style.border_color = Color("#d9ddcf")
    style.corner_radius_top_left = radius
    style.corner_radius_top_right = radius
    style.corner_radius_bottom_left = radius
    style.corner_radius_bottom_right = radius
    style.content_margin_left = 14
    style.content_margin_right = 14
    style.content_margin_top = 12
    style.content_margin_bottom = 12
    style.shadow_color = Color(0.10,0.20,0.14,0.10)
    style.shadow_size = 4
    style.shadow_offset = Vector2(0,2)
    return style

func _button(text: String, callback: Callable, accent := false, compact := false) -> Button:
    var b := Button.new()
    b.text = text
    b.custom_minimum_size = Vector2(0,46 if compact else 56)
    b.focus_mode = Control.FOCUS_NONE
    b.add_theme_font_size_override("font_size",14)
    b.add_theme_color_override("font_color",Color("#fffdf7") if accent else INK)
    b.add_theme_color_override("font_hover_color",Color.WHITE if accent else GREEN_DARK)
    b.add_theme_stylebox_override("normal",_product_button_style(GREEN if accent else Color("#fffdf8"),accent))
    b.add_theme_stylebox_override("hover",_product_button_style((GREEN if accent else Color("#ffffff")).lightened(0.04),accent))
    b.add_theme_stylebox_override("pressed",_product_button_style(GREEN_DARK if accent else Color("#e5eadf"),accent))
    b.pressed.connect(callback)
    return b

func _product_button_style(color: Color, accent: bool) -> StyleBoxFlat:
    var style := StyleBoxFlat.new()
    style.bg_color = color
    style.corner_radius_top_left = 15
    style.corner_radius_top_right = 15
    style.corner_radius_bottom_left = 15
    style.corner_radius_bottom_right = 15
    style.border_width_left = 1
    style.border_width_right = 1
    style.border_width_top = 1
    style.border_width_bottom = 1
    style.border_color = Color("#315e46") if accent else Color("#d9ddcf")
    style.content_margin_left = 12
    style.content_margin_right = 12
    style.content_margin_top = 10
    style.content_margin_bottom = 10
    style.shadow_color = Color(0.09,0.17,0.12,0.14 if accent else 0.07)
    style.shadow_size = 3
    style.shadow_offset = Vector2(0,2)
    return style

func _chip_style(color: Color) -> StyleBoxFlat:
    var style := StyleBoxFlat.new()
    style.bg_color = color
    style.corner_radius_top_left = 13
    style.corner_radius_top_right = 13
    style.corner_radius_bottom_left = 13
    style.corner_radius_bottom_right = 13
    style.content_margin_left = 10
    style.content_margin_right = 10
    style.content_margin_top = 7
    style.content_margin_bottom = 7
    return style

func _build_shell() -> void:
    var bg := ColorRect.new()
    bg.color = Color("#e8eee4")
    bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(bg)

    var glow := ColorRect.new()
    glow.color = Color(1.0,0.97,0.84,0.18)
    glow.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
    glow.custom_minimum_size = Vector2(0,150)
    add_child(glow)

    root_box = VBoxContainer.new()
    root_box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    root_box.offset_left = 12
    root_box.offset_right = -12
    root_box.offset_top = 12
    root_box.offset_bottom = -8
    root_box.add_theme_constant_override("separation",8)
    add_child(root_box)

    var head := HBoxContainer.new()
    head.add_theme_constant_override("separation",8)
    root_box.add_child(head)
    var brand := VBoxContainer.new()
    brand.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    brand.add_theme_constant_override("separation",-2)
    head.add_child(brand)
    var title := Label.new()
    title.text = "雪里"
    title.add_theme_font_size_override("font_size",27)
    title.add_theme_color_override("font_color",INK)
    brand.add_child(title)
    var subtitle := Label.new()
    subtitle.text = "FARM LOOP"
    subtitle.add_theme_font_size_override("font_size",9)
    subtitle.add_theme_color_override("font_color",MUTED)
    brand.add_child(subtitle)
    var version := Label.new()
    version.text = ""
    version.visible = false
    head.add_child(version)

    var primary := HBoxContainer.new()
    primary.add_theme_constant_override("separation",6)
    root_box.add_child(primary)
    season_chip = _make_chip("",Color("#dfead8"),GREEN_DARK,true)
    season_chip.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    primary.add_child(season_chip)
    money_chip = _make_chip("",Color("#fff2c9"),Color("#6d4b13"),true)
    primary.add_child(money_chip)

    var secondary := HBoxContainer.new()
    secondary.add_theme_constant_override("separation",5)
    root_box.add_child(secondary)
    level_chip = _make_chip("",Color("#f8f5ea"),INK,false)
    reputation_chip = _make_chip("",Color("#f8f5ea"),INK,false)
    loop_chip = _make_chip("",Color("#f8f5ea"),INK,false)
    for chip in [level_chip,reputation_chip,loop_chip]:
        chip.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        secondary.add_child(chip)

    status_label = Label.new()
    status_label.visible = false
    root_box.add_child(status_label)

    objective_label = Label.new()
    objective_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    objective_label.add_theme_font_size_override("font_size",13)
    objective_label.add_theme_color_override("font_color",GREEN_DARK)
    var objective_style := _panel_style(Color("#f5f8ec"),15)
    objective_style.border_width_left = 4
    objective_style.border_color = Color("#7fa45e")
    objective_style.shadow_size = 1
    objective_label.add_theme_stylebox_override("normal",objective_style)
    root_box.add_child(objective_label)

    top_scroll = ScrollContainer.new()
    top_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    top_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    top_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
    top_scroll.clip_contents = true
    root_box.add_child(top_scroll)

    content = VBoxContainer.new()
    content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    content.add_theme_constant_override("separation",10)
    top_scroll.add_child(content)

    var nav_panel := PanelContainer.new()
    nav_panel.add_theme_stylebox_override("panel",_panel_style(Color("#f8f7ef"),18))
    root_box.add_child(nav_panel)
    var nav := HBoxContainer.new()
    nav.add_theme_constant_override("separation",5)
    nav_panel.add_child(nav)
    for pair in [["農場","farm"],["仕事","work"],["販売","market"],["村","village"]]:
        var b := _button(pair[0],_show_tab.bind(pair[1]),false,true)
        b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        nav.add_child(b)
        nav_buttons[pair[1]] = b

    feedback = FeedbackClass.new()
    feedback.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    feedback.set_reduced_motion(bool(state["settings"].get("reduced_motion",false)))
    add_child(feedback)

func _make_chip(text_value: String, color: Color, text_color: Color, strong: bool) -> Label:
    var label := Label.new()
    label.text = text_value
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.add_theme_font_size_override("font_size",14 if strong else 12)
    label.add_theme_color_override("font_color",text_color)
    label.add_theme_stylebox_override("normal",_chip_style(color))
    return label

func _section(title_text: String) -> VBoxContainer:
    var display_name := _section_display_name(title_text)
    var panel := PanelContainer.new()
    panel.add_theme_stylebox_override("panel",_panel_style(Color("#fffdf6"),18))
    content.add_child(panel)
    var v := VBoxContainer.new()
    v.add_theme_constant_override("separation",8)
    panel.add_child(v)
    var h := HBoxContainer.new()
    v.add_child(h)
    var marker := ColorRect.new()
    marker.color = Color("#7fa45e")
    marker.custom_minimum_size = Vector2(4,20)
    h.add_child(marker)
    var title := Label.new()
    title.text = display_name
    title.add_theme_font_size_override("font_size",16)
    title.add_theme_color_override("font_color",INK)
    title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    h.add_child(title)
    return v

func _section_display_name(raw: String) -> String:
    var names := {
        "施設アクション":"今いる場所",
        "循環ループ":"里山の循環",
        "倉庫":"収穫かご",
        "循環資材・原木":"山仕事",
        "加工":"加工小屋",
        "設備強化":"里の成長",
        "雪国・鳥獣・防疫":"里山整備",
        "販路":"売り先",
        "村の人":"雪里の人々",
        "今月の依頼":"村のお願い",
        "里山図鑑":"里山図鑑",
        "設定":"設定",
        "記録":"里山日記",
        "山の探索":"山の探索",
        "循環チェイン":"循環チェイン",
        "雪里の珍品":"雪里の珍品"
    }
    if names.has(raw):
        return str(names[raw])
    if raw.ends_with("へ出荷"):
        return raw
    return raw

func _header() -> void:
    status_label.text = ""
    if season_chip != null:
        season_chip.text = "%d年 %d月・%s　%s" % [state["year"],state["month"],rules.season_name(state["month"]),state["weather"]]
    if money_chip != null:
        money_chip.text = "¥%d" % int(state["money"])
    if level_chip != null:
        level_chip.text = "Lv %d" % int(state["level"])
    if reputation_chip != null:
        reputation_chip.text = "評判 %d" % int(state["reputation"])
    if loop_chip != null:
        loop_chip.text = "循環 %d" % int(state["loop_score"])
    if objective_label != null:
        objective_label.text = "次の一手｜%s" % _clean_objective(_next_objective())

func _clean_objective(text_value: String) -> String:
    var result := text_value
    for prefix in ["次の目標：","遊びの目標｜"]:
        if result.begins_with(prefix):
            result = result.trim_prefix(prefix)
    return result

func _show_tab(tab: String) -> void:
    super._show_tab(tab)
    for id in nav_buttons:
        var active: bool = id == tab
        var b: Button = nav_buttons[id]
        b.add_theme_color_override("font_color",Color("#fffdf7") if active else INK)
        b.add_theme_stylebox_override("normal",_product_button_style(GREEN if active else Color("#fffdf8"),active))
    if top_scroll != null:
        top_scroll.scroll_vertical = 0

func _build_farm() -> void:
    super._build_farm()
    rules.ensure_product_fields(state)
    if map != null:
        map.custom_minimum_size = Vector2(0,410)
        var progress: Dictionary = rules.land_progress(state)
        var polish = ProductMapOverlayClass.new()
        polish.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
        polish.set_product_state(rules.season_key(int(state["month"])),int(progress["rank"]),bool(state["settings"].get("reduced_motion",false)))
        map.add_child(polish)

    var notebook := _section("里山手帳")
    var daily: Dictionary = rules.daily_summary(state)
    var title := Label.new()
    title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    title.add_theme_font_size_override("font_size",14)
    title.add_theme_color_override("font_color",GREEN_DARK)
    title.text = "今日の3つを終えると、里山ボーナス。"
    notebook.add_child(title)
    notebook.add_child(_daily_row("収穫",int(daily["harvest"]),int(daily["harvest_target"])))
    notebook.add_child(_daily_row("山を探索",int(daily["explore"]),int(daily["explore_target"])))
    notebook.add_child(_daily_row("販売",int(daily["sell"]),int(daily["sell_target"])))
    var result := Label.new()
    result.add_theme_font_size_override("font_size",12)
    result.add_theme_color_override("font_color",GOLD if bool(daily["claimed"]) else MUTED)
    result.text = "本日達成済み｜累計 %d回" % int(daily["total_completed"]) if bool(daily["claimed"]) else "未達成｜自由に遊びながら埋まる"
    notebook.add_child(result)

    _move_section_after_map("里山手帳",1)
    _move_section_after_map("山の探索",2)
    _move_section_after_map("循環チェイン",3)

func _daily_row(label_text: String, value: int, target: int) -> HBoxContainer:
    var row := HBoxContainer.new()
    var label := Label.new()
    label.text = label_text
    label.add_theme_font_size_override("font_size",13)
    label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    row.add_child(label)
    var done := Label.new()
    done.text = "%d / %d" % [mini(value,target),target]
    done.add_theme_font_size_override("font_size",13)
    done.add_theme_color_override("font_color",GREEN if value >= target else MUTED)
    row.add_child(done)
    return row

func _move_section_after_map(title_text: String, target_index: int) -> void:
    var panel := _find_section_panel(title_text)
    if panel != null:
        content.move_child(panel,mini(target_index,content.get_child_count()-1))

func _find_section_panel(title_text: String) -> Control:
    for child in content.get_children():
        if child is PanelContainer and child.get_child_count() > 0:
            var box = child.get_child(0)
            if box is VBoxContainer and box.get_child_count() > 0:
                var heading = box.get_child(0)
                if heading is HBoxContainer and heading.get_child_count() > 1:
                    var label = heading.get_child(1)
                    if label is Label and label.text == title_text:
                        return child
    return null

func _commit(result: Dictionary, return_tab: String, facility: String = "") -> void:
    var daily: Dictionary = {}
    if bool(result.get("ok",false)) and rules.has_method("track_daily_action"):
        daily = rules.track_daily_action(state,str(result.get("feedback","work")),facility)
    super._commit(result,return_tab,facility)
    if bool(daily.get("completed_now",false)):
        save_service.save(state)
        if feedback != null:
            var suffix := " + 里山ランクUP" if bool(daily.get("rank_up",false)) else ""
            feedback.pop("里山手帳 完成！ +¥%d%s" % [daily.get("bonus",0),suffix],5)
            feedback.fly_tokens("major",12)
        if sfx != null:
            sfx.play_kind("major",5)
        _haptic(5)

func _on_explore() -> void:
    if not rules.has_method("explore_mountain"):
        return
    _commit(rules.explore_mountain(state),"farm","mountain")
