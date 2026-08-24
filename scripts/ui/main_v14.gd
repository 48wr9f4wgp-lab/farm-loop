extends "res://scripts/ui/main_v13.gd"

const CurrentRulesClass = preload("res://scripts/core/game_rules_current.gd")

func _ready() -> void:
    super._ready()
    rules = CurrentRulesClass.new(data)
    rules.ensure_route_fields(state)
    rules.ensure_requests(state)
    state["version"] = "godot-1.4-village-product"
    save_service.save(state)
    _header()
    _show_tab(current_tab)

func _build_village() -> void:
    if state["village_requests"].is_empty():
        rules.ensure_requests(state)

    var open_count: int = 0
    for request in state["village_requests"]:
        if not bool(request.get("done",false)):
            open_count += 1
    var ready_count: int = rules.ready_request_count(state)

    var hero := _section("今日の村")
    var headline := HBoxContainer.new()
    headline.add_theme_constant_override("separation",8)
    hero.add_child(headline)

    var left := VBoxContainer.new()
    left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    left.add_theme_constant_override("separation",1)
    headline.add_child(left)

    var title := Label.new()
    title.text = "届けると、人とのつながりが育つ"
    title.add_theme_font_size_override("font_size",16)
    title.add_theme_color_override("font_color",GREEN_DARK)
    left.add_child(title)

    var sub := Label.new()
    sub.text = "依頼 %d件｜今すぐ納品 %d件" % [open_count,ready_count]
    sub.add_theme_font_size_override("font_size",11)
    sub.add_theme_color_override("font_color",MUTED)
    left.add_child(sub)

    var ready_chip := Label.new()
    ready_chip.text = "納品OK %d" % ready_count
    ready_chip.add_theme_font_size_override("font_size",10)
    ready_chip.add_theme_color_override("font_color",GREEN_DARK if ready_count > 0 else MUTED)
    ready_chip.add_theme_stylebox_override("normal",_chip_style(Color("#e3efd9") if ready_count > 0 else Color("#edf0ea")))
    headline.add_child(ready_chip)

    if state["village_requests"].is_empty():
        hero.add_child(_lead_text("今月のお願いはまだない。月が進むと新しい依頼が届く。"))
    else:
        for request in state["village_requests"]:
            hero.add_child(_request_card(request))

    var people := _section("雪里の人々")
    people.add_child(_lead_text("依頼を届けるほど関係が深まり、雪里の住人になっていく。"))
    for key in data.get_table("villagers"):
        people.add_child(_person_card(key))

    if state.has("entertainment"):
        var finds := _section("雪里の珍品")
        var rare: Array = state["entertainment"].get("rare_finds",[])
        if rare.is_empty():
            finds.add_child(_lead_text("まだ発見なし。仕事タブから山へ入ると珍品に出会える。"))
        else:
            var rare_text := Label.new()
            rare_text.text = "発見 %d種\n%s" % [rare.size(),"・".join(PackedStringArray(rare))]
            rare_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
            rare_text.add_theme_font_size_override("font_size",11)
            rare_text.add_theme_color_override("font_color",GREEN_DARK)
            finds.add_child(rare_text)

    var codex := _section("里山図鑑")
    var names := PackedStringArray()
    for key in state["discovered"]:
        if data.get_table("products").has(key):
            names.append(str(data.get_table("products")[key]["name"]))
    codex.add_child(_lead_text("登録 %d種｜%s" % [state["discovered"].size(),"・".join(names)]))

    var settings := _section("設定")
    var settings_row := HBoxContainer.new()
    settings_row.add_theme_constant_override("separation",5)
    settings.add_child(settings_row)
    var haptic := _button("触覚 %s" % ("ON" if bool(state["settings"]["haptics"]) else "OFF"),_toggle_haptics,false,true)
    var motion := _button("演出軽減 %s" % ("ON" if bool(state["settings"]["reduced_motion"]) else "OFF"),_toggle_motion,false,true)
    haptic.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    motion.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    settings_row.add_child(haptic)
    settings_row.add_child(motion)
    if state["settings"].has("sound"):
        settings.add_child(_button("効果音 %s" % ("ON" if bool(state["settings"].get("sound",true)) else "OFF"),_toggle_sound,false,true))

func _request_card(request: Dictionary) -> PanelContainer:
    var card := PanelContainer.new()
    var card_style := _panel_style(Color("#f8f4e8"),13)
    card_style.content_margin_top = 9
    card_style.content_margin_bottom = 9
    card_style.content_margin_left = 10
    card_style.content_margin_right = 10
    card.add_theme_stylebox_override("panel",card_style)

    var box := VBoxContainer.new()
    box.add_theme_constant_override("separation",5)
    card.add_child(box)

    var villager_id: String = str(request.get("villager",""))
    var villager: Dictionary = data.get_table("villagers").get(villager_id,{})
    var status: Dictionary = rules.request_status(state,request)

    var top := HBoxContainer.new()
    top.add_theme_constant_override("separation",7)
    box.add_child(top)

    var avatar := Label.new()
    avatar.text = str(villager.get("name","里")).left(1)
    avatar.custom_minimum_size = Vector2(34,34)
    avatar.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    avatar.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    avatar.add_theme_font_size_override("font_size",16)
    avatar.add_theme_color_override("font_color",Color.WHITE)
    avatar.add_theme_stylebox_override("normal",_chip_style(GREEN))
    top.add_child(avatar)

    var who := VBoxContainer.new()
    who.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    who.add_theme_constant_override("separation",0)
    top.add_child(who)

    var name_label := Label.new()
    name_label.text = "%s｜%s" % [str(villager.get("name","村人")),str(villager.get("role","雪里の人"))]
    name_label.add_theme_font_size_override("font_size",12)
    name_label.add_theme_color_override("font_color",INK)
    who.add_child(name_label)

    var request_label := Label.new()
    request_label.text = str(request.get("label","お願い"))
    request_label.add_theme_font_size_override("font_size",15)
    request_label.add_theme_color_override("font_color",GREEN_DARK)
    who.add_child(request_label)

    var status_chip := Label.new()
    if bool(status["done"]):
        status_chip.text = "完了"
    elif bool(status["ready"]):
        status_chip.text = "納品OK"
    else:
        status_chip.text = "準備中"
    status_chip.add_theme_font_size_override("font_size",10)
    status_chip.add_theme_color_override("font_color",GREEN_DARK if bool(status["ready"]) else MUTED)
    status_chip.add_theme_stylebox_override("normal",_chip_style(Color("#e3efd9") if bool(status["ready"]) else Color("#edf0ea")))
    top.add_child(status_chip)

    var need := Label.new()
    need.text = "必要：%s" % str(status["need"])
    need.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    need.add_theme_font_size_override("font_size",11)
    need.add_theme_color_override("font_color",INK)
    box.add_child(need)

    if not bool(status["ready"]) and not bool(status["done"]) and not str(status["missing"]).is_empty():
        var missing := Label.new()
        missing.text = str(status["missing"])
        missing.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        missing.add_theme_font_size_override("font_size",10)
        missing.add_theme_color_override("font_color",Color("#9a6432"))
        box.add_child(missing)

    var reward := Label.new()
    reward.text = "報酬 ¥%d　＋関係%d" % [int(request.get("reward",0)),int(request.get("relation",0))]
    reward.add_theme_font_size_override("font_size",11)
    reward.add_theme_color_override("font_color",Color("#8a621c"))
    box.add_child(reward)

    var button := _button("%sへ納品" % str(villager.get("name","村人")),_on_request.bind(str(request.get("id",""))),bool(status["ready"]),false)
    button.custom_minimum_size.y = 50
    button.disabled = not bool(status["ready"])
    if bool(status["done"]):
        button.text = "納品済み"
    box.add_child(button)
    return card

func _person_card(villager_id: String) -> PanelContainer:
    var villager: Dictionary = data.get_table("villagers")[villager_id]
    var points: int = int(state["relation"].get(villager_id,0))
    var progress: Dictionary = rules.relation_progress(points)

    var card := PanelContainer.new()
    card.add_theme_stylebox_override("panel",_panel_style(Color("#fffdf8"),12))
    var box := VBoxContainer.new()
    box.add_theme_constant_override("separation",3)
    card.add_child(box)

    var top := HBoxContainer.new()
    top.add_theme_constant_override("separation",6)
    box.add_child(top)
    var who := Label.new()
    who.text = "%s　%s" % [str(villager["name"]),str(villager["role"])]
    who.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    who.add_theme_font_size_override("font_size",13)
    who.add_theme_color_override("font_color",INK)
    top.add_child(who)
    var tier := Label.new()
    tier.text = str(progress["tier"])
    tier.add_theme_font_size_override("font_size",10)
    tier.add_theme_color_override("font_color",GREEN_DARK)
    top.add_child(tier)

    var focus := Label.new()
    focus.text = "得意：%s｜関係 %d" % [str(villager.get("focus","里山")),points]
    focus.add_theme_font_size_override("font_size",10)
    focus.add_theme_color_override("font_color",MUTED)
    box.add_child(focus)

    var bar := ProgressBar.new()
    bar.max_value = 1.0
    bar.value = float(progress["ratio"])
    bar.show_percentage = false
    bar.custom_minimum_size.y = 8
    box.add_child(bar)

    var next := Label.new()
    next.text = "MAX" if str(progress["next"]) == "MAX" else "次：%s　%d/%d" % [str(progress["next"]),int(progress["current"]),int(progress["target"])]
    next.add_theme_font_size_override("font_size",9)
    next.add_theme_color_override("font_color",MUTED)
    box.add_child(next)
    return card
