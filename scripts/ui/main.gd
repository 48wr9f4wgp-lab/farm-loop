extends Control

const GameDataClass = preload("res://scripts/core/game_data.gd")
const GameStateClass = preload("res://scripts/core/game_state.gd")
const GameRulesClass = preload("res://scripts/core/game_rules.gd")
const SaveServiceClass = preload("res://scripts/core/save_service.gd")
const FarmMapClass = preload("res://scripts/ui/farm_map.gd")
const FeedbackClass = preload("res://scripts/ui/feedback_overlay.gd")

var data
var rules
var save_service
var state: Dictionary

var root_box: VBoxContainer
var content: VBoxContainer
var status_label: Label
var objective_label: Label
var feedback
var map
var selected_channel := "roadside"
var selected_facility := "coop"
var current_tab := "farm"
var nav_buttons := {}
var selected_title_label: Label
var selected_desc_label: Label
var selected_action_button: Button

const BG := Color("#e9efe7")
const PANEL := Color("#fffaf0")
const GREEN := Color("#356b4c")
const GREEN_DARK := Color("#234c36")
const INK := Color("#193126")
const MUTED := Color("#6d786f")
const GOLD := Color("#b78332")
const LINE := Color("#ded8cb")

func _ready() -> void:
    data = GameDataClass.new()
    rules = GameRulesClass.new(data)
    save_service = SaveServiceClass.new()
    state = save_service.load_or_default(GameStateClass.create(data))
    _ensure_v03_fields()
    rules.ensure_requests(state)
    _build_shell()
    selected_facility = str(state["ui"].get("selected_facility","coop"))
    current_tab = str(state["ui"].get("last_tab","farm"))
    _show_tab(current_tab)

func _ensure_v03_fields() -> void:
    if not state.has("settings"):
        state["settings"] = {"haptics":true,"reduced_motion":false}
    if not state.has("ui"):
        state["ui"] = {"selected_facility":"coop","last_tab":"farm"}
    if not state.has("analytics"):
        state["analytics"] = {"session_actions":0,"events":[]}
    if not state["analytics"].has("events"):
        state["analytics"]["events"] = []
    state["version"] = "godot-0.3.2-mobile-ci"

func _panel_style(color := PANEL, radius := 16) -> StyleBoxFlat:
    var style := StyleBoxFlat.new()
    style.bg_color = color
    style.border_width_left = 1
    style.border_width_right = 1
    style.border_width_top = 1
    style.border_width_bottom = 1
    style.border_color = LINE
    style.corner_radius_top_left = radius
    style.corner_radius_top_right = radius
    style.corner_radius_bottom_left = radius
    style.corner_radius_bottom_right = radius
    style.content_margin_left = 12
    style.content_margin_right = 12
    style.content_margin_top = 10
    style.content_margin_bottom = 10
    return style

func _button(text: String, callback: Callable, accent := false, compact := false) -> Button:
    var b := Button.new()
    b.text = text
    b.custom_minimum_size = Vector2(0, 42 if compact else 50)
    b.add_theme_font_size_override("font_size", 13)
    b.add_theme_color_override("font_color", Color.WHITE if accent else INK)
    b.add_theme_stylebox_override("normal", _panel_style(GREEN if accent else Color("#ffffff"), 12))
    b.add_theme_stylebox_override("hover", _panel_style((GREEN if accent else Color.WHITE).lightened(0.05), 12))
    b.add_theme_stylebox_override("pressed", _panel_style((GREEN_DARK if accent else Color("#e9eee8")), 12))
    b.pressed.connect(callback)
    return b

func _build_shell() -> void:
    var bg := ColorRect.new()
    bg.color = BG
    bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(bg)

    root_box = VBoxContainer.new()
    root_box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    root_box.offset_left = 10
    root_box.offset_right = -10
    root_box.offset_top = 10
    root_box.offset_bottom = -8
    root_box.add_theme_constant_override("separation", 7)
    add_child(root_box)

    var head := HBoxContainer.new()
    root_box.add_child(head)
    var title := Label.new()
    title.text = "FARM LOOP"
    title.add_theme_font_size_override("font_size", 25)
    title.add_theme_color_override("font_color", INK)
    title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    head.add_child(title)
    var version := Label.new()
    version.text = "GODOT 0.3.2"
    version.add_theme_font_size_override("font_size", 9)
    version.add_theme_color_override("font_color", MUTED)
    head.add_child(version)

    status_label = Label.new()
    status_label.add_theme_font_size_override("font_size", 11)
    status_label.add_theme_color_override("font_color", MUTED)
    root_box.add_child(status_label)

    objective_label = Label.new()
    objective_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    objective_label.add_theme_font_size_override("font_size", 12)
    objective_label.add_theme_color_override("font_color", GREEN_DARK)
    objective_label.add_theme_stylebox_override("normal", _panel_style(Color("#e5efe2"), 12))
    root_box.add_child(objective_label)

    var scroll := ScrollContainer.new()
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    root_box.add_child(scroll)

    content = VBoxContainer.new()
    content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    content.add_theme_constant_override("separation", 8)
    scroll.add_child(content)

    var nav := HBoxContainer.new()
    nav.add_theme_constant_override("separation", 5)
    root_box.add_child(nav)
    for pair in [["農場","farm"],["仕事","work"],["販売","market"],["村","village"]]:
        var b := _button(pair[0], _show_tab.bind(pair[1]), false, true)
        b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        nav.add_child(b)
        nav_buttons[pair[1]] = b

    feedback = FeedbackClass.new()
    feedback.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    feedback.set_reduced_motion(bool(state["settings"].get("reduced_motion",false)))
    add_child(feedback)

func _clear() -> void:
    map = null
    selected_title_label = null
    selected_desc_label = null
    selected_action_button = null
    for child in content.get_children():
        child.queue_free()

func _header() -> void:
    status_label.text = "%d年%d月・%s　¥%d　評判%d　循環%d　Lv%d" % [
        state["year"],state["month"],rules.season_name(state["month"]),state["money"],
        state["reputation"],state["loop_score"],state["level"]
    ]
    objective_label.text = _next_objective()

func _next_objective() -> String:
    if int(state["counters"].get("harvest",0)) == 0 and bool(state["ready"].get("coop",false)):
        return "次の目標：鶏舎をタップ → 主人公を歩かせて卵と鶏糞を回収"
    if int(state["inventory"].get("manure",0)) >= 4 and int(state["inventory"].get("leaves",0)) >= 2:
        return "次の目標：堆肥舎で鶏糞＋落ち葉を仕込み、循環をつなぐ"
    if int(state["inventory"].get("compost",0)) > 0:
        return "次の目標：完成堆肥を山菜区画へ還元"
    if bool(state["ready"].get("sansai",false)):
        return "次の目標：旬の山菜を収穫"
    if _sellable_stock() > 0:
        return "次の目標：販売タブで収穫物を出荷"
    return "次の目標：今月を終え、季節・天候・依頼の変化を見る"

func _sellable_stock() -> int:
    var total := 0
    for key in data.get_table("products"):
        var p: Dictionary = data.get_table("products")[key]
        if bool(p.get("sellable",false)):
            total += int(state["inventory"].get(key,0))
    return total

func _show_tab(tab: String) -> void:
    current_tab = tab
    state["ui"]["last_tab"] = tab
    _clear()
    _header()
    for id in nav_buttons:
        nav_buttons[id].add_theme_color_override("font_color", GREEN_DARK if id == tab else INK)
    if tab == "farm":
        _build_farm()
    elif tab == "work":
        _build_work()
    elif tab == "market":
        _build_market()
    else:
        _build_village()

func _section(title_text: String) -> VBoxContainer:
    var panel := PanelContainer.new()
    panel.add_theme_stylebox_override("panel", _panel_style())
    content.add_child(panel)
    var v := VBoxContainer.new()
    v.add_theme_constant_override("separation", 6)
    panel.add_child(v)
    var h := Label.new()
    h.text = title_text
    h.add_theme_font_size_override("font_size", 17)
    h.add_theme_color_override("font_color", INK)
    v.add_child(h)
    return v

func _build_farm() -> void:
    map = FarmMapClass.new()
    map.custom_minimum_size = Vector2(0, 355)
    map.set_state(
        rules.season_key(int(state["month"])),
        str(state["weather"]),
        state["ready"],
        selected_facility,
        bool(state["settings"].get("reduced_motion",false))
    )
    map.facility_selected.connect(_on_map_select)
    map.player_arrived.connect(_on_map_arrive)
    content.add_child(map)

    var selected := _section("施設アクション")
    selected_title_label = Label.new()
    selected_title_label.add_theme_font_size_override("font_size", 15)
    selected_title_label.add_theme_color_override("font_color", GREEN_DARK)
    selected.add_child(selected_title_label)
    selected_desc_label = Label.new()
    selected_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    selected_desc_label.add_theme_color_override("font_color", MUTED)
    selected.add_child(selected_desc_label)
    selected_action_button = _button("", _on_selected_action, true)
    selected.add_child(selected_action_button)
    selected.add_child(_button("完成堆肥を山菜へ還元", _on_apply_compost))
    _refresh_selected_panel()

    var loop := _section("循環ループ")
    var l := Label.new()
    l.text = "鶏糞 %d　堆肥 %d　落ち葉/籾殻 %d　受粉 %d" % [
        state["inventory"]["manure"],state["inventory"]["compost"],state["inventory"]["leaves"],state["buffs"]["pollination"]
    ]
    loop.add_child(l)
    var progress := ProgressBar.new()
    progress.max_value = 100
    progress.value = int(state["loop_score"])
    progress.show_percentage = false
    progress.custom_minimum_size = Vector2(0,13)
    loop.add_child(progress)
    loop.add_child(_button("今月を終える", _on_next_month, false))

    var stock := _section("倉庫")
    var text := Label.new()
    text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    var parts := PackedStringArray()
    for key in state["inventory"]:
        if int(state["inventory"][key]) > 0 and data.get_table("products").has(key):
            parts.append("%s %d" % [data.get_table("products")[key]["name"],state["inventory"][key]])
    text.text = " / ".join(parts) if parts.size() > 0 else "在庫なし"
    stock.add_child(text)

func _refresh_selected_panel() -> void:
    if selected_title_label == null or selected_desc_label == null or selected_action_button == null:
        return
    selected_title_label.text = "選択中｜%s" % _facility_name(selected_facility)
    selected_desc_label.text = _facility_description(selected_facility)
    selected_action_button.text = _facility_action_label(selected_facility)

func _facility_name(id: String) -> String:
    var names := {"coop":"雪国鶏舎","compost":"堆肥舎","sansai":"山菜区画","mushroom":"原木林","bee":"蜂場"}
    return str(names.get(id,"里山"))

func _facility_description(id: String) -> String:
    if id == "coop":
        return "採卵と鶏糞回収。鶏糞は落ち葉・籾殻と混ぜて堆肥へ。"
    if id == "compost":
        return "鶏糞4＋落ち葉/籾殻2を仕込む。完成は翌月。"
    if id == "sansai":
        return "季節に合う山菜を収穫。堆肥と蜂の受粉で収量が上がる。"
    if id == "mushroom":
        return "原木の年齢・健康・季節から発生量が決まる。"
    if id == "bee":
        return "夏〜秋に採蜜。採蜜後は山菜へ受粉ボーナス。"
    return ""

func _facility_action_label(id: String) -> String:
    if id == "compost":
        return "堆肥を仕込む"
    if id == "bee":
        return "採蜜する"
    return "%sで作業する" % _facility_name(id)

func _on_map_select(id: String) -> void:
    selected_facility = id
    state["ui"]["selected_facility"] = id
    _record_event("facility_selected",{"facility":id})
    _refresh_selected_panel()
    objective_label.text = "移動中：%sへ向かっています" % _facility_name(id)

func _on_map_arrive(id: String) -> void:
    selected_facility = id
    _refresh_selected_panel()
    objective_label.text = "到着：%sで作業できる" % _facility_name(id)
    if feedback:
        feedback.pop("%sに到着" % _facility_name(id),1)

func _on_selected_action() -> void:
    if map:
        map.play_action_feedback(selected_facility)
    _commit(rules.harvest(state,selected_facility),"farm",selected_facility)

func _build_work() -> void:
    var resource := _section("循環資材・原木")
    resource.add_child(_button("落ち葉・籾殻を集める",_on_gather_leaves,true))
    for kind in ["shiitake","nameko","hiratake"]:
        resource.add_child(_button("%s原木を植菌" % data.get_table("products")[kind]["name"],_on_inoculate.bind(kind)))

    var recipes := _section("加工")
    for r in data.get_table("recipes"):
        recipes.add_child(_button("%s　加工費¥%d" % [r["name"],r["cost"]],_on_craft.bind(r["id"])))

    var upgrades := _section("設備強化")
    for key in data.get_table("facilities"):
        var f: Dictionary = data.get_table("facilities")[key]
        upgrades.add_child(_button("%s Lv%d" % [f["name"],state["facility_levels"][key]],_on_upgrade.bind(key)))

    var projects := _section("雪国・鳥獣・防疫")
    for p in data.get_table("projects"):
        var suffix := " 導入済" if bool(state["projects"].get(p["id"],false)) else " ¥%d" % p["cost"]
        projects.add_child(_button("%s%s" % [p["name"],suffix],_on_buy_project.bind(p["id"])))

func _build_market() -> void:
    var channels := _section("販路")
    var row := HBoxContainer.new()
    channels.add_child(row)
    for key in data.get_table("channels"):
        if int(state["level"]) >= int(data.get_table("channels")[key]["unlock"]):
            var b := _button(data.get_table("channels")[key]["name"],_on_channel.bind(key),key==selected_channel,true)
            b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
            row.add_child(b)

    var items := _section("%sへ出荷" % data.get_table("channels")[selected_channel]["name"])
    var found := false
    for key in data.get_table("products"):
        var p: Dictionary = data.get_table("products")[key]
        if bool(p.get("sellable",false)) and int(state["inventory"].get(key,0)) > 0:
            found = true
            var price: int = int(rules.quote_price(state,key,selected_channel))
            items.add_child(_button("%s ×%d　@¥%d" % [p["name"],state["inventory"][key],price],_on_sell.bind(key),true))
    if not found:
        var empty := Label.new()
        empty.text = "販売できる在庫がない。農場で収穫しよう。"
        empty.add_theme_color_override("font_color",MUTED)
        items.add_child(empty)

func _build_village() -> void:
    var people := _section("村の人")
    for key in data.get_table("villagers"):
        var v: Dictionary = data.get_table("villagers")[key]
        var l := Label.new()
        l.text = "%s｜%s　信頼 %d（%s）" % [v["name"],v["role"],state["relation"][key],rules.relation_tier(state["relation"][key])]
        l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        people.add_child(l)

    var req := _section("今月の依頼")
    if state["village_requests"].is_empty():
        rules.ensure_requests(state)
    for r in state["village_requests"]:
        var suffix := " ✓" if r.get("done",false) else ""
        req.add_child(_button("%s　報酬¥%d%s" % [r["label"],r["reward"],suffix],_on_request.bind(r["id"])))

    var codex := _section("里山図鑑")
    var label := Label.new()
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    var names := PackedStringArray()
    for key in state["discovered"]:
        if data.get_table("products").has(key):
            names.append(data.get_table("products")[key]["name"])
    label.text = "登録 %d種｜%s" % [state["discovered"].size(),"・".join(names)]
    codex.add_child(label)

    var settings := _section("設定")
    settings.add_child(_button("触覚：%s" % ("ON" if bool(state["settings"]["haptics"]) else "OFF"),_toggle_haptics))
    settings.add_child(_button("演出軽減：%s" % ("ON" if bool(state["settings"]["reduced_motion"]) else "OFF"),_toggle_motion))

    var logbox := _section("記録")
    for line in state["log"].slice(0,12):
        var log_label := Label.new()
        log_label.text = line
        log_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        logbox.add_child(log_label)

func _commit(result: Dictionary, return_tab: String, facility: String = "") -> void:
    state["analytics"]["session_actions"] = int(state["analytics"].get("session_actions",0)) + 1
    var ok := bool(result.get("ok",false))
    var tier := int(result.get("tier",1))
    var msg := str(result.get("msg",""))
    if ok:
        _record_event(str(result.get("feedback","action")),{"facility":facility,"tier":tier})
        save_service.save(state)
        _haptic(tier)
    if feedback:
        feedback.pop(msg,tier)
    _show_tab(return_tab)
    if map and facility != "":
        map.play_action_feedback(facility)

func _record_event(name: String, properties: Dictionary = {}) -> void:
    var events: Array = state["analytics"]["events"]
    events.append({"event":name,"year":state["year"],"month":state["month"],"properties":properties})
    if events.size() > 80:
        events.pop_front()
    state["analytics"]["events"] = events

func _haptic(tier: int) -> void:
    if not bool(state["settings"].get("haptics",true)):
        return
    if not OS.has_feature("mobile"):
        return
    var ms := 18
    if tier >= 4:
        ms = 45
    elif tier >= 3:
        ms = 30
    Input.vibrate_handheld(ms)

func _on_apply_compost() -> void:
    _commit(rules.apply_compost(state),"farm","sansai")

func _on_next_month() -> void:
    _commit(rules.next_month(state),"farm")

func _on_craft(id: String) -> void:
    _commit(rules.craft(state,id),"work")

func _on_gather_leaves() -> void:
    _commit(rules.gather_leaves(state),"work")

func _on_inoculate(kind: String) -> void:
    _commit(rules.inoculate_logs(state,kind),"work")

func _on_upgrade(id: String) -> void:
    _commit(rules.upgrade_facility(state,id),"work")

func _on_buy_project(id: String) -> void:
    _commit(rules.buy_project(state,id),"work")

func _on_channel(id: String) -> void:
    selected_channel = id
    _show_tab("market")

func _on_sell(id: String) -> void:
    _commit(rules.sell_all(state,id,selected_channel),"market")

func _on_request(id: String) -> void:
    _commit(rules.fulfill_request(state,id),"village")

func _toggle_haptics() -> void:
    state["settings"]["haptics"] = not bool(state["settings"]["haptics"])
    save_service.save(state)
    _show_tab("village")

func _toggle_motion() -> void:
    state["settings"]["reduced_motion"] = not bool(state["settings"]["reduced_motion"])
    feedback.set_reduced_motion(bool(state["settings"]["reduced_motion"]))
    save_service.save(state)
    _show_tab("village")
