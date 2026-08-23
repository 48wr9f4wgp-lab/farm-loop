extends "res://scripts/ui/main_v06.gd"

const RulesV07Class = preload("res://scripts/core/game_rules_v07.gd")
const ProductMapOverlayV07Class = preload("res://scripts/ui/product_map_overlay_v07.gd")
const ProductMapOverlayV06Class = preload("res://scripts/ui/product_map_overlay_v06.gd")

var quick_ready_label: Label
var quick_secondary_button: Button

func _ready() -> void:
    super._ready()
    rules = RulesV07Class.new(data)
    rules.ensure_product_fields(state)
    state["version"] = "godot-0.7-product-wave2"
    save_service.save(state)
    _header()
    _show_tab(current_tab)

func _build_shell() -> void:
    super._build_shell()
    root_box.offset_top = 8
    root_box.add_theme_constant_override("separation",6)
    if objective_label != null:
        objective_label.add_theme_font_size_override("font_size",12)
    for id in nav_buttons:
        var b: Button = nav_buttons[id]
        b.custom_minimum_size.y = 44

func _header() -> void:
    super._header()
    if objective_label == null:
        return
    var text_value: String = _clean_objective(_next_objective()).replace("\n","｜")
    objective_label.text = text_value

func _facility_description(id: String) -> String:
    if id == "coop": return "卵と鶏糞を回収。循環のスタート地点。"
    if id == "compost": return "鶏糞と落ち葉を仕込み、翌月に堆肥へ。"
    if id == "sansai": return "旬をまとめて収穫。堆肥と受粉で収量UP。"
    if id == "mushroom": return "季節と原木の育ちで、きのこが発生。"
    if id == "bee": return "採蜜と受粉で、里山全体を底上げ。"
    return ""

func _facility_action_label(id: String) -> String:
    if id == "coop": return "卵と鶏糞を回収"
    if id == "compost": return "堆肥を仕込む"
    if id == "sansai": return "旬の山菜を一気に収穫"
    if id == "mushroom": return "原木きのこを収穫"
    if id == "bee": return "採蜜する"
    return "作業する"

func _build_farm() -> void:
    super._build_farm()
    if not rules.has_method("land_progress"):
        return
    if map != null:
        map.custom_minimum_size = Vector2(0,350)
        for child in map.get_children():
            if child.get_script() == ProductMapOverlayV06Class:
                child.queue_free()
        var progress: Dictionary = rules.land_progress(state)
        var polish = ProductMapOverlayV07Class.new()
        polish.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
        polish.set_product_state(rules.season_key(int(state["month"])),int(progress["rank"]),bool(state["settings"].get("reduced_motion",false)))
        map.add_child(polish)

    var old_panel: Control = _find_section_panel("今いる場所")
    if old_panel != null:
        old_panel.visible = false

    var quick_panel := PanelContainer.new()
    quick_panel.add_theme_stylebox_override("panel",_panel_style(Color("#fffdf6"),18))
    content.add_child(quick_panel)
    content.move_child(quick_panel,1)
    var box := VBoxContainer.new()
    box.add_theme_constant_override("separation",7)
    quick_panel.add_child(box)

    var top := HBoxContainer.new()
    top.add_theme_constant_override("separation",8)
    box.add_child(top)
    selected_title_label = Label.new()
    selected_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    selected_title_label.add_theme_font_size_override("font_size",16)
    selected_title_label.add_theme_color_override("font_color",INK)
    top.add_child(selected_title_label)
    quick_ready_label = Label.new()
    quick_ready_label.add_theme_font_size_override("font_size",11)
    quick_ready_label.add_theme_color_override("font_color",GREEN)
    quick_ready_label.add_theme_stylebox_override("normal",_chip_style(Color("#e3efd9")))
    top.add_child(quick_ready_label)

    selected_desc_label = Label.new()
    selected_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    selected_desc_label.add_theme_font_size_override("font_size",12)
    selected_desc_label.add_theme_color_override("font_color",MUTED)
    box.add_child(selected_desc_label)

    selected_action_button = _button("",_on_selected_action,true,false)
    selected_action_button.custom_minimum_size.y = 54
    box.add_child(selected_action_button)

    quick_secondary_button = _button("完成堆肥を山菜へ還元",_on_apply_compost,false,true)
    box.add_child(quick_secondary_button)
    _refresh_selected_panel()

func _refresh_selected_panel() -> void:
    super._refresh_selected_panel()
    if quick_ready_label == null or selected_action_button == null:
        return
    var is_ready: bool = true if selected_facility == "compost" else bool(state["ready"].get(selected_facility,false))
    quick_ready_label.text = "準備OK" if is_ready else "今月は完了"
    quick_ready_label.add_theme_color_override("font_color",GREEN if is_ready else MUTED)
    selected_action_button.disabled = not is_ready
    if quick_secondary_button != null:
        quick_secondary_button.visible = selected_facility == "sansai" and int(state["inventory"].get("compost",0)) > 0

func _on_map_select(id: String) -> void:
    super._on_map_select(id)
    if selected_action_button != null:
        selected_action_button.disabled = true
        selected_action_button.text = "移動中…"
    if quick_ready_label != null:
        quick_ready_label.text = "移動中"

func _on_map_arrive(id: String) -> void:
    super._on_map_arrive(id)
    _refresh_selected_panel()

func _build_market() -> void:
    super._build_market()
    var total: int = _sellable_stock()
    var basket := _section("収穫かご")
    var summary := Label.new()
    summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    summary.add_theme_font_size_override("font_size",13)
    summary.add_theme_color_override("font_color",GREEN_DARK)
    summary.text = "販売できる収穫物 %d点。手間なく一括で売れる。" % total if total > 0 else "収穫かごは空。農場や山で恵みを集めよう。"
    basket.add_child(summary)
    var sell_button := _button("収穫かごをまとめて出荷",_on_sell_basket,true,false)
    sell_button.disabled = total <= 0
    basket.add_child(sell_button)
    var panel: Control = _find_section_panel("収穫かご")
    if panel != null:
        content.move_child(panel,mini(1,content.get_child_count()-1))

func _on_sell_basket() -> void:
    if not rules.has_method("sell_basket"):
        return
    _commit(rules.sell_basket(state,selected_channel),"market")
