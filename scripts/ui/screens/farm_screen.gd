class_name FarmScreen
extends RefCounted

const FarmMapV09Class = preload("res://scripts/ui/farm_map_v09.gd")
const ProductMapOverlayV09Class = preload("res://scripts/ui/product_map_overlay_v09.gd")
const FarmPolishOverlayV15Class = preload("res://scripts/ui/farm_polish_overlay_v15.gd")
const FacilityActionOverlayV16Class = preload("res://scripts/ui/facility_action_overlay_v16.gd")

const GREEN := Color("#356b4c")
const GREEN_DARK := Color("#234c36")
const INK := Color("#193126")
const MUTED := Color("#6d786f")
const GOLD := Color("#b78332")

func build(host) -> void:
    host.rules.ensure_product_fields(host.state)
    host.rules.ensure_entertainment_fields(host.state)
    _build_quick_action(host)
    _build_map(host)
    _build_notebook(host)
    _build_mountain(host)
    _build_chain(host)
    _build_circulation(host)
    _build_stock(host)
    host._refresh_selected_panel()

func _build_quick_action(host) -> void:
    var panel := PanelContainer.new()
    var style: StyleBoxFlat = host._panel_style(Color("#fffdf8"),15)
    style.content_margin_top = 9
    style.content_margin_bottom = 9
    style.content_margin_left = 11
    style.content_margin_right = 11
    style.shadow_size = 2
    panel.add_theme_stylebox_override("panel",style)
    host.content.add_child(panel)

    var box := VBoxContainer.new()
    box.add_theme_constant_override("separation",5)
    panel.add_child(box)

    var top := HBoxContainer.new()
    top.add_theme_constant_override("separation",8)
    box.add_child(top)

    host.selected_title_label = Label.new()
    host.selected_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    host.selected_title_label.add_theme_font_size_override("font_size",14)
    host.selected_title_label.add_theme_color_override("font_color",INK)
    top.add_child(host.selected_title_label)

    host.quick_ready_label = Label.new()
    host.quick_ready_label.add_theme_font_size_override("font_size",10)
    host.quick_ready_label.add_theme_color_override("font_color",GREEN)
    host.quick_ready_label.add_theme_stylebox_override("normal",host._chip_style(Color("#e3efd9")))
    top.add_child(host.quick_ready_label)

    host.selected_desc_label = Label.new()
    host.selected_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    host.selected_desc_label.add_theme_font_size_override("font_size",11)
    host.selected_desc_label.add_theme_color_override("font_color",MUTED)
    host.selected_desc_label.visible = false
    box.add_child(host.selected_desc_label)

    host.selected_action_button = host._button("",Callable(host,"_on_selected_action"),true,false)
    host.selected_action_button.custom_minimum_size.y = 52
    host.selected_action_button.add_theme_font_size_override("font_size",14)
    box.add_child(host.selected_action_button)

    host.quick_secondary_button = host._button("完成堆肥を山菜へ還元",Callable(host,"_on_apply_compost"),false,true)
    host.quick_secondary_button.custom_minimum_size.y = 40
    box.add_child(host.quick_secondary_button)

func _build_map(host) -> void:
    var farm_map = FarmMapV09Class.new()
    var viewport_h: float = host.get_viewport_rect().size.y
    farm_map.custom_minimum_size = Vector2(0,clampf(viewport_h * 0.44,385.0,420.0))
    farm_map.set_state(
        host.rules.season_key(int(host.state["month"])),
        str(host.state["weather"]),
        host.state["ready"],
        host.selected_facility,
        bool(host.state["settings"].get("reduced_motion",false))
    )
    farm_map.player_pos = Vector2(0.50,0.84)
    farm_map.target_pos = farm_map.player_pos
    farm_map.facility_selected.connect(Callable(host,"_on_map_select"))
    farm_map.player_arrived.connect(Callable(host,"_on_map_arrive"))
    host.content.add_child(farm_map)
    host.map = farm_map

    var progress: Dictionary = host.rules.land_progress(host.state)
    var art = ProductMapOverlayV09Class.new()
    art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    art.mouse_filter = Control.MOUSE_FILTER_IGNORE
    art.set_product_state(
        host.rules.season_key(int(host.state["month"])),
        int(progress["rank"]),
        bool(host.state["settings"].get("reduced_motion",false))
    )
    farm_map.add_child(art)

    var guidance = FarmPolishOverlayV15Class.new()
    guidance.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    guidance.mouse_filter = Control.MOUSE_FILTER_IGNORE
    farm_map.add_child(guidance)

    var action_fx = FacilityActionOverlayV16Class.new()
    action_fx.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    action_fx.mouse_filter = Control.MOUSE_FILTER_IGNORE
    farm_map.add_child(action_fx)

func _build_notebook(host) -> void:
    var notebook: VBoxContainer = host._section("里山手帳")
    var daily: Dictionary = host.rules.daily_summary(host.state)
    var title := Label.new()
    title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    title.add_theme_font_size_override("font_size",14)
    title.add_theme_color_override("font_color",GREEN_DARK)
    title.text = "今日の3つを終えると、里山ボーナス。"
    notebook.add_child(title)
    notebook.add_child(host._daily_row("収穫",int(daily["harvest"]),int(daily["harvest_target"])))
    notebook.add_child(host._daily_row("山を探索",int(daily["explore"]),int(daily["explore_target"])))
    notebook.add_child(host._daily_row("販売",int(daily["sell"]),int(daily["sell_target"])))
    var result := Label.new()
    result.add_theme_font_size_override("font_size",12)
    result.add_theme_color_override("font_color",GOLD if bool(daily["claimed"]) else MUTED)
    result.text = "本日達成済み｜累計 %d回" % int(daily["total_completed"]) if bool(daily["claimed"]) else "未達成｜自由に遊びながら埋まる"
    notebook.add_child(result)

func _build_mountain(host) -> void:
    var progress: Dictionary = host.rules.land_progress(host.state)
    var mountain: VBoxContainer = host._section("山の探索")
    var summary := Label.new()
    summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    summary.add_theme_color_override("font_color",GREEN_DARK)
    summary.text = "里山ランク %d｜%s　成長 %d / %d\n今月の探索 %d回　珍品 %d種" % [
        int(progress["rank"]),str(progress["name"]),int(progress["current"]),int(progress["next"]),
        int(host.state["entertainment"]["explores_this_month"]),host.state["entertainment"]["rare_finds"].size()
    ]
    mountain.add_child(summary)
    var bar := ProgressBar.new()
    bar.max_value = 100
    bar.value = int(round(float(progress["ratio"])*100.0))
    bar.show_percentage = false
    bar.custom_minimum_size = Vector2(0,12)
    mountain.add_child(bar)
    var explore_text: String = "山へ探索に行く"
    if int(host.state["entertainment"]["explores_this_month"]) >= 2:
        explore_text = "もう一度探索（追加探索は控えめ報酬）"
    var explore_button: Button = host._button(explore_text,Callable(host,"_on_explore"),true,false)
    mountain.add_child(explore_button)

func _build_chain(host) -> void:
    var chain: VBoxContainer = host._section("循環チェイン")
    var stage: int = int(host.state["entertainment"]["chain_stage"])
    var label := Label.new()
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    label.text = "現在 %d / 6　完成 %d回\n鶏 → 堆肥 → 月送り → 還元 → 山菜 → 販売" % [stage,int(host.state["entertainment"]["chains_completed"])]
    chain.add_child(label)
    var bar := ProgressBar.new()
    bar.max_value = 6
    bar.value = stage
    bar.show_percentage = false
    bar.custom_minimum_size = Vector2(0,12)
    chain.add_child(bar)

func _build_circulation(host) -> void:
    var loop: VBoxContainer = host._section("循環ループ")
    var label := Label.new()
    label.text = "鶏糞 %d　堆肥 %d　落ち葉/籾殻 %d　受粉 %d" % [
        int(host.state["inventory"]["manure"]),int(host.state["inventory"]["compost"]),
        int(host.state["inventory"]["leaves"]),int(host.state["buffs"]["pollination"])
    ]
    loop.add_child(label)
    var progress := ProgressBar.new()
    progress.max_value = 100
    progress.value = int(host.state["loop_score"])
    progress.show_percentage = false
    progress.custom_minimum_size = Vector2(0,13)
    loop.add_child(progress)
    var next_month: Button = host._button("今月を終える",Callable(host,"_on_next_month"),false,false)
    loop.add_child(next_month)

func _build_stock(host) -> void:
    var stock: VBoxContainer = host._section("倉庫")
    var text := Label.new()
    text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    var parts := PackedStringArray()
    for key in host.state["inventory"]:
        if int(host.state["inventory"][key]) > 0 and host.data.get_table("products").has(key):
            parts.append("%s %d" % [str(host.data.get_table("products")[key]["name"]),int(host.state["inventory"][key])])
    text.text = " / ".join(parts) if parts.size() > 0 else "在庫なし"
    stock.add_child(text)
