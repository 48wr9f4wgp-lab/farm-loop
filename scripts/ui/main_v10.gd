extends "res://scripts/ui/main_v09.gd"

var _v10_boot_guard: bool = true
var brand_meta_label: Label

func _ready() -> void:
    _v10_boot_guard = true
    super._ready()
    _v10_boot_guard = false
    state["version"] = "godot-1.0-product-wave4"
    save_service.save(state)
    _show_tab(current_tab)

func _show_tab(tab: String) -> void:
    if _v10_boot_guard:
        return
    super._show_tab(tab)

func _clear() -> void:
    quick_ready_label = null
    quick_secondary_button = null
    super._clear()

func _build_shell() -> void:
    super._build_shell()
    root_box.offset_left = 11
    root_box.offset_right = -11
    root_box.offset_top = 9
    root_box.add_theme_constant_override("separation",5)

    if root_box.get_child_count() > 0:
        var head = root_box.get_child(0)
        if head is HBoxContainer and head.get_child_count() > 0:
            var brand = head.get_child(0)
            if brand is VBoxContainer and brand.get_child_count() > 1:
                var title = brand.get_child(0)
                if title is Label:
                    title.add_theme_font_size_override("font_size",24)
                var subtitle = brand.get_child(1)
                if subtitle is Label:
                    brand_meta_label = subtitle
                    subtitle.add_theme_font_size_override("font_size",8)
                    subtitle.add_theme_color_override("font_color",Color("#6f7e72"))

    if root_box.get_child_count() > 2:
        var secondary = root_box.get_child(2)
        if secondary is Control:
            secondary.visible = false

    if season_chip != null:
        season_chip.add_theme_font_size_override("font_size",13)
    if money_chip != null:
        money_chip.add_theme_font_size_override("font_size",13)
    if objective_label != null:
        objective_label.add_theme_font_size_override("font_size",11)
        var objective_style := _panel_style(Color("#f5f8ec"),13)
        objective_style.border_width_left = 3
        objective_style.border_color = Color("#7fa45e")
        objective_style.content_margin_left = 10
        objective_style.content_margin_right = 9
        objective_style.content_margin_top = 7
        objective_style.content_margin_bottom = 7
        objective_style.shadow_size = 1
        objective_label.add_theme_stylebox_override("normal",objective_style)

    for id in nav_buttons:
        var b: Button = nav_buttons[id]
        b.custom_minimum_size.y = 42
        b.add_theme_font_size_override("font_size",13)

func _header() -> void:
    super._header()
    if brand_meta_label != null:
        brand_meta_label.text = "YUKISATO  •  Lv%d  •  評判%d  •  循環%d" % [
            int(state["level"]),int(state["reputation"]),int(state["loop_score"])
        ]
    if objective_label != null:
        objective_label.text = _compact_objective(_clean_objective(_next_objective()))

func _compact_objective(text_value: String) -> String:
    var text := text_value.replace("はじめての循環 ","循環 ")
    text = text.replace("｜","  ›  ")
    if text.length() > 46:
        text = text.left(45) + "…"
    return text

func _build_farm() -> void:
    super._build_farm()
    if map == null:
        return

    map.custom_minimum_size.y = 385

    var quick_panel: PanelContainer = null
    if selected_action_button != null and selected_action_button.get_parent() != null:
        var box = selected_action_button.get_parent()
        if box.get_parent() is PanelContainer:
            quick_panel = box.get_parent() as PanelContainer

    if quick_panel != null:
        var quick_box = quick_panel.get_child(0)
        if quick_box is VBoxContainer:
            quick_box.add_theme_constant_override("separation",5)
        var style := _panel_style(Color("#fffdf8"),15)
        style.content_margin_top = 9
        style.content_margin_bottom = 9
        style.content_margin_left = 11
        style.content_margin_right = 11
        style.shadow_size = 2
        quick_panel.add_theme_stylebox_override("panel",style)
        content.move_child(quick_panel,0)
        content.move_child(map,1)

    if selected_desc_label != null:
        selected_desc_label.visible = false
    if selected_title_label != null:
        selected_title_label.add_theme_font_size_override("font_size",14)
    if quick_ready_label != null:
        quick_ready_label.add_theme_font_size_override("font_size",10)
    if selected_action_button != null:
        selected_action_button.custom_minimum_size.y = 46
        selected_action_button.add_theme_font_size_override("font_size",14)
    if quick_secondary_button != null:
        quick_secondary_button.custom_minimum_size.y = 40

    _refresh_selected_panel()

func _build_work() -> void:
    var hero := _section("今日の山仕事")
    hero.add_child(_lead_text("手を動かすほど、農場の次の収穫につながる。待ち時間なしで進められる。"))
    hero.add_child(_button("落ち葉・籾殻を集める",_on_gather_leaves,true,false))

    var logs := HBoxContainer.new()
    logs.add_theme_constant_override("separation",5)
    hero.add_child(logs)
    for kind in ["shiitake","nameko","hiratake"]:
        var b := _button("%s原木" % str(data.get_table("products")[kind]["name"]),_on_inoculate.bind(kind),false,true)
        b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        logs.add_child(b)

    var recipes := _section("加工小屋")
    recipes.add_child(_lead_text("収穫物をひと手間かけて、価値の高い商品へ。"))
    for r in data.get_table("recipes"):
        var rb := _button("%s　¥%d" % [str(r["name"]),int(r["cost"])],_on_craft.bind(str(r["id"])),false,true)
        recipes.add_child(rb)

    var growth := _section("里の成長")
    growth.add_child(_lead_text("よく使う場所から強くする。設備は収穫効率と選択肢を増やす。"))
    for key in data.get_table("facilities"):
        var f: Dictionary = data.get_table("facilities")[key]
        growth.add_child(_button("%s　Lv%d → 強化" % [str(f["name"]),int(state["facility_levels"][key])],_on_upgrade.bind(key),false,true))

    var safety := _section("里山整備")
    for p in data.get_table("projects"):
        var installed: bool = bool(state["projects"].get(p["id"],false))
        var suffix := "　導入済" if installed else "　¥%d" % int(p["cost"])
        var pb := _button("%s%s" % [str(p["name"]),suffix],_on_buy_project.bind(str(p["id"])),false,true)
        pb.disabled = installed
        safety.add_child(pb)

func _build_market() -> void:
    var total_items: int = _sellable_stock()
    var estimate: int = _basket_estimate(selected_channel)

    var hero := _section("今日の出荷")
    var value := Label.new()
    value.text = "¥%d" % estimate
    value.add_theme_font_size_override("font_size",28)
    value.add_theme_color_override("font_color",Color("#8a621c"))
    hero.add_child(value)
    hero.add_child(_lead_text("販売できる収穫物 %d点｜選んだ売り先でまとめて出荷" % total_items))
    var sell_all := _button("まとめて出荷する",_on_sell_basket,true,false)
    sell_all.disabled = total_items <= 0
    hero.add_child(sell_all)

    var channels := _section("売り先")
    var row := HBoxContainer.new()
    row.add_theme_constant_override("separation",5)
    channels.add_child(row)
    for key in data.get_table("channels"):
        if int(state["level"]) >= int(data.get_table("channels")[key]["unlock"]):
            var active: bool = key == selected_channel
            var b := _button(str(data.get_table("channels")[key]["name"]),_on_channel.bind(key),active,true)
            b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
            row.add_child(b)

    var items := _section("収穫かご")
    var found: bool = false
    for key in data.get_table("products"):
        var p: Dictionary = data.get_table("products")[key]
        var count: int = int(state["inventory"].get(key,0))
        if bool(p.get("sellable",false)) and count > 0:
            found = true
            var price: int = int(rules.quote_price(state,key,selected_channel))
            items.add_child(_button("%s ×%d　¥%d" % [str(p["name"]),count,price*count],_on_sell.bind(key),false,true))
    if not found:
        items.add_child(_lead_text("かごは空。農場や山で収穫すると、ここに並ぶ。"))

func _build_village() -> void:
    var requests := _section("村のお願い")
    if state["village_requests"].is_empty():
        rules.ensure_requests(state)
    var open_count: int = 0
    for r in state["village_requests"]:
        if not bool(r.get("done",false)):
            open_count += 1
    requests.add_child(_lead_text("残り %d件｜応えるほど人とのつながりと評判が育つ。" % open_count))
    for r in state["village_requests"]:
        var done: bool = bool(r.get("done",false))
        var suffix := "　✓ 完了" if done else "　報酬 ¥%d" % int(r["reward"])
        var rb := _button("%s%s" % [str(r["label"]),suffix],_on_request.bind(str(r["id"])),not done,true)
        rb.disabled = done
        requests.add_child(rb)

    var people := _section("雪里の人々")
    for key in data.get_table("villagers"):
        var v: Dictionary = data.get_table("villagers")[key]
        var relation: int = int(state["relation"][key])
        var row := VBoxContainer.new()
        row.add_theme_constant_override("separation",2)
        var who := Label.new()
        who.text = "%s　%s" % [str(v["name"]),str(v["role"])]
        who.add_theme_font_size_override("font_size",13)
        who.add_theme_color_override("font_color",INK)
        row.add_child(who)
        var trust := Label.new()
        trust.text = "信頼 %d｜%s" % [relation,str(rules.relation_tier(relation))]
        trust.add_theme_font_size_override("font_size",11)
        trust.add_theme_color_override("font_color",MUTED)
        row.add_child(trust)
        people.add_child(row)

    if state.has("entertainment"):
        var finds := _section("雪里の珍品")
        var rare: Array = state["entertainment"].get("rare_finds",[])
        finds.add_child(_lead_text("まだ発見なし。山の探索で見つかる。" if rare.is_empty() else "発見 %d種｜%s" % [rare.size(),"・".join(PackedStringArray(rare))]))

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
        var sound := _button("効果音 %s" % ("ON" if bool(state["settings"].get("sound",true)) else "OFF"),_toggle_sound,false,true)
        settings.add_child(sound)

func _lead_text(text_value: String) -> Label:
    var label := Label.new()
    label.text = text_value
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    label.add_theme_font_size_override("font_size",11)
    label.add_theme_color_override("font_color",MUTED)
    return label

func _basket_estimate(channel: String) -> int:
    var total: int = 0
    for key in data.get_table("products"):
        var p: Dictionary = data.get_table("products")[key]
        var count: int = int(state["inventory"].get(key,0))
        if bool(p.get("sellable",false)) and count > 0:
            total += int(rules.quote_price(state,key,channel)) * count
    return total
