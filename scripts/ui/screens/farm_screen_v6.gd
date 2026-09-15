class_name FarmScreenV6
extends "res://scripts/ui/screens/farm_screen_v5.gd"

const FarmDioramaV6Class = preload("res://scripts/ui/farm_diorama_v6.gd")

func build(host) -> void:
    host.rules.ensure_product_fields(host.state)
    host.rules.ensure_entertainment_fields(host.state)

    var guided: bool = host.ftue_service != null and host.ftue_service.active(host.state)
    var guided_step: int = host.ftue_service.step(host.state) if guided else -1
    var proof_mode: bool = bool(host.state.get("restoration_v3",{}).get("proof_mode",false))

    if guided and guided_step == 3:
        _build_month_gate(host)
    elif guided and guided_step == 4:
        # The previous screen kept the compost shed selected while the objective
        # asked the player to restore the sansai patch. Make the visual target,
        # selected facility and primary CTA agree in one frame.
        host.selected_facility = "sansai"
        host.state["ui"]["selected_facility"] = "sansai"
        _build_restore_gate(host)
    else:
        _build_quick_action(host)

    _build_map(host)

    if guided:
        _build_restore_status(host)
    elif proof_mode:
        _build_restore_status(host)
        _build_circulation(host,true)
    else:
        _build_restore_status(host)
        _build_notebook(host)
        _build_mountain(host)
        _build_chain(host)
        _build_circulation(host,false)
        _build_stock(host)

    # Dedicated month/restore gates own their CTA and must not be overwritten by
    # the legacy selected-facility panel refresh.
    if not (guided and guided_step in [3,4]):
        host._refresh_selected_panel()

func _build_restore_gate(host) -> void:
    host.selected_title_label = null
    host.selected_desc_label = null
    host.selected_action_button = null
    host.quick_ready_label = null
    host.quick_secondary_button = null

    var panel := PanelContainer.new()
    var style: StyleBoxFlat = host._panel_style(Color("#fffaf0"),15)
    style.content_margin_top = 12
    style.content_margin_bottom = 12
    style.content_margin_left = 12
    style.content_margin_right = 12
    style.shadow_size = 2
    panel.add_theme_stylebox_override("panel",style)
    host.content.add_child(panel)

    var box := VBoxContainer.new()
    box.add_theme_constant_override("separation",7)
    panel.add_child(box)

    var title := Label.new()
    title.text = "山菜区画を蘇らせる"
    title.add_theme_font_size_override("font_size",16)
    title.add_theme_color_override("font_color",GREEN_DARK)
    box.add_child(title)

    var lead := Label.new()
    lead.text = "完成した堆肥を土へ還して、里山に恵みを戻そう。"
    lead.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    lead.add_theme_font_size_override("font_size",11)
    lead.add_theme_color_override("font_color",MUTED)
    box.add_child(lead)

    var compost_count: int = int(host.state["inventory"].get("compost",0))
    var status := Label.new()
    status.text = "山菜区画を強調表示中｜完成堆肥 %d" % compost_count
    status.add_theme_font_size_override("font_size",10)
    status.add_theme_color_override("font_color",GREEN)
    box.add_child(status)

    var apply: Button = host._button("完成堆肥を土へ還す",Callable(host,"_on_apply_compost"),true,false)
    apply.custom_minimum_size.y = 58
    apply.add_theme_font_size_override("font_size",15)
    apply.disabled = compost_count <= 0
    if apply.disabled:
        apply.text = "完成堆肥がありません"
    box.add_child(apply)

func _build_map(host) -> void:
    var farm_map = FarmDioramaV6Class.new()
    var viewport_h: float = host.get_viewport_rect().size.y
    farm_map.custom_minimum_size = Vector2(0,clampf(viewport_h * 0.55,455.0,530.0))
    farm_map.set_state(
        host.rules.season_key(int(host.state["month"])),
        str(host.state["weather"]),
        host.state["ready"],
        host.selected_facility,
        bool(host.state["settings"].get("reduced_motion",false))
    )
    var restore_stage: int = int(host.state.get("restoration_v3",{}).get("first_patch_stage",0))
    if host.ftue_service != null and host.ftue_service.has_method("restoration_stage"):
        restore_stage = int(host.ftue_service.restoration_stage(host.state))
    farm_map.set_restoration_stage(restore_stage)
    farm_map.facility_selected.connect(Callable(host,"_on_map_select"))
    farm_map.player_arrived.connect(Callable(host,"_on_map_arrive"))
    host.content.add_child(farm_map)
    host.map = farm_map
