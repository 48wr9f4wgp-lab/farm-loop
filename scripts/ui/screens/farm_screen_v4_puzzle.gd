class_name FarmScreenV4Puzzle
extends RefCounted

const Rules = preload("res://scripts/core/circulation_rules_v4.gd")
const CirculationState = preload("res://scripts/core/circulation_state_v4.gd")
const CirculationBoard = preload("res://scripts/ui/circulation_board_v4.gd")

const GREEN := Color("#356b4c")
const GREEN_DARK := Color("#234c36")
const MUTED := Color("#6d786f")
const PREVIEW_BG := Color("#eef3e4")

var host
var selected_zone: String = ""
var preview_intervention_id: String = ""
var preview_result: Dictionary = {}

func build(value) -> void:
    host = value
    CirculationState.ensure_in_state(host.state)
    var board: Dictionary = host.state["circulation_v4"]

    _build_summary(board)
    if not selected_zone.is_empty():
        _build_intervention_tray(board)
    _build_board(board)
    _build_month_end(board)
    _build_last_resolution(board)

func _build_summary(board: Dictionary) -> void:
    var panel := PanelContainer.new()
    var style: StyleBoxFlat = host._panel_style(Color("#f7f8ef"),14)
    style.content_margin_top = 8
    style.content_margin_bottom = 8
    panel.add_theme_stylebox_override("panel",style)
    host.content.add_child(panel)

    var row := HBoxContainer.new()
    row.add_theme_constant_override("separation",8)
    panel.add_child(row)

    var recovery := Label.new()
    recovery.name = "V4RecoveryLabel"
    recovery.text = "里山回復 %d%%" % int(board.get("recovery_score",0))
    recovery.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    recovery.add_theme_font_size_override("font_size",14)
    recovery.add_theme_color_override("font_color",GREEN_DARK)
    row.add_child(recovery)

    var ap := Label.new()
    ap.name = "V4ActionPointsLabel"
    ap.text = "手入れ %d / 3" % int(board.get("action_points",0))
    ap.add_theme_font_size_override("font_size",13)
    ap.add_theme_color_override("font_color",GREEN)
    ap.add_theme_stylebox_override("normal",host._chip_style(Color("#e4efd9")))
    row.add_child(ap)

func _build_board(board_state: Dictionary) -> void:
    var farm_map = CirculationBoard.new()
    farm_map.name = "CirculationBoardV4"
    var viewport_h: float = host.get_viewport_rect().size.y
    farm_map.custom_minimum_size = Vector2(0,clampf(viewport_h * 0.54,430.0,490.0))
    farm_map.set_state(
        str(board_state.get("season","spring")),
        str(board_state.get("weather","晴れ")),
        {},
        "",
        bool(host.state.get("settings",{}).get("reduced_motion",false))
    )
    farm_map.set_board_state(board_state)
    if not selected_zone.is_empty():
        farm_map.select_zone(selected_zone)
    farm_map.zone_selected.connect(Callable(self,"_on_zone_selected"))
    host.content.add_child(farm_map)
    host.map = farm_map

func _build_intervention_tray(board: Dictionary) -> void:
    var panel := PanelContainer.new()
    panel.name = "V4InterventionTray"
    var style: StyleBoxFlat = host._panel_style(Color("#fffdf8"),15)
    style.content_margin_top = 10
    style.content_margin_bottom = 10
    style.shadow_size = 2
    panel.add_theme_stylebox_override("panel",style)
    host.content.add_child(panel)

    var box := VBoxContainer.new()
    box.add_theme_constant_override("separation",6)
    panel.add_child(box)

    var title := Label.new()
    title.text = "選択中｜%s" % Rules.zone_name(selected_zone)
    title.add_theme_font_size_override("font_size",16)
    title.add_theme_color_override("font_color",GREEN_DARK)
    box.add_child(title)

    var state_line := Label.new()
    state_line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    state_line.add_theme_font_size_override("font_size",11)
    state_line.add_theme_color_override("font_color",MUTED)
    state_line.text = _zone_readable_state(board,selected_zone)
    box.add_child(state_line)

    if not preview_intervention_id.is_empty() and bool(preview_result.get("ok",false)):
        _build_preview(box,board)
        return

    var available: Array = Rules.available_interventions(board,selected_zone)
    if available.is_empty():
        var passive := Label.new()
        passive.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        passive.text = "ここは循環を支える場所。今月は直接の手入れ対象ではない。"
        passive.add_theme_font_size_override("font_size",12)
        passive.add_theme_color_override("font_color",MUTED)
        box.add_child(passive)
    else:
        for intervention in available:
            var button: Button = host._button(
                "%s｜手入れ1" % Rules.intervention_name(str(intervention)),
                Callable(self,"_on_preview_intervention").bind(str(intervention)),
                true,
                false
            )
            button.name = "V4Action_%s" % str(intervention)
            button.disabled = int(board.get("action_points",0)) <= 0
            button.custom_minimum_size.y = 48
            box.add_child(button)

    var close := host._button("選択を閉じる",Callable(self,"_on_clear_selection"),false,true)
    close.name = "V4CloseTray"
    box.add_child(close)

func _build_preview(box: VBoxContainer, board: Dictionary) -> void:
    var preview_panel := PanelContainer.new()
    preview_panel.name = "V4PreviewCard"
    preview_panel.add_theme_stylebox_override("panel",host._panel_style(PREVIEW_BG,12))
    box.add_child(preview_panel)

    var pbox := VBoxContainer.new()
    pbox.add_theme_constant_override("separation",5)
    preview_panel.add_child(pbox)

    var heading := Label.new()
    heading.text = "%sに%s" % [Rules.zone_name(selected_zone),Rules.intervention_name(preview_intervention_id)]
    heading.add_theme_font_size_override("font_size",13)
    heading.add_theme_color_override("font_color",GREEN_DARK)
    pbox.add_child(heading)

    var direct := Label.new()
    direct.name = "V4PreviewText"
    direct.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    direct.add_theme_font_size_override("font_size",11)
    direct.add_theme_color_override("font_color",MUTED)
    direct.text = "%s\n%s" % [_direct_effect_text(preview_intervention_id),_chain_preview_text(preview_result)]
    pbox.add_child(direct)

    var commit := host._button("これで手入れする｜1消費",Callable(self,"_on_commit_preview"),true,false)
    commit.name = "V4CommitPreview"
    commit.disabled = int(board.get("action_points",0)) <= 0
    commit.custom_minimum_size.y = 48
    pbox.add_child(commit)

    var cancel := host._button("別の手入れを見る",Callable(self,"_on_cancel_preview"),false,true)
    cancel.name = "V4CancelPreview"
    pbox.add_child(cancel)

func _build_month_end(board: Dictionary) -> void:
    var pending: Array = board.get("pending_actions",[])
    if pending.is_empty():
        return
    var button: Button = host._button(
        "今月を終える｜%d手の連鎖を見る" % pending.size(),
        Callable(self,"_on_month_end"),
        false,
        false
    )
    button.name = "V4MonthEnd"
    button.custom_minimum_size.y = 52
    host.content.add_child(button)

func _build_last_resolution(board: Dictionary) -> void:
    var events: Array = board.get("last_resolution",[])
    if events.is_empty():
        return
    var section: VBoxContainer = host._section("前の月に起きたこと")
    var label := Label.new()
    label.name = "V4LastResolution"
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    label.add_theme_font_size_override("font_size",11)
    label.add_theme_color_override("font_color",MUTED)
    label.text = _event_chain_text(events)
    section.add_child(label)

func _on_zone_selected(zone_id: String) -> void:
    selected_zone = zone_id
    preview_intervention_id = ""
    preview_result = {}
    host._record_event("v4_zone_selected",{"target_zone":zone_id})
    host._haptic(1)
    host._show_tab("farm")

func _on_clear_selection() -> void:
    selected_zone = ""
    preview_intervention_id = ""
    preview_result = {}
    host._show_tab("farm")

func _on_preview_intervention(intervention: String) -> void:
    var board: Dictionary = host.state["circulation_v4"]
    var preview: Dictionary = Rules.preview_intervention(board,intervention,selected_zone)
    if not bool(preview.get("ok",false)):
        if host.feedback != null:
            host.feedback.pop("この手入れは今できない",1)
        return
    preview_intervention_id = intervention
    preview_result = preview
    host._record_event("v4_intervention_previewed",{
        "intervention":intervention,
        "target_zone":selected_zone,
        "ap_before":int(board.get("action_points",0)),
        "predicted_chain_count":int(preview.get("predicted_chain_count",0)),
        "recovery_before":int(board.get("recovery_score",0)),
        "predicted_recovery":int(preview.get("predicted_recovery_score",0)),
        "month":int(board.get("month",4))
    })
    host._show_tab("farm")

func _on_cancel_preview() -> void:
    preview_intervention_id = ""
    preview_result = {}
    host._show_tab("farm")

func _on_commit_preview() -> void:
    if preview_intervention_id.is_empty() or selected_zone.is_empty():
        return
    var before: Dictionary = host.state["circulation_v4"]
    var ap_before := int(before.get("action_points",0))
    var result: Dictionary = Rules.commit_intervention(before,preview_intervention_id,selected_zone)
    if not bool(result.get("ok",false)):
        return
    host.state["circulation_v4"] = result["state"]
    host._record_event("v4_intervention_committed",{
        "intervention":preview_intervention_id,
        "target_zone":selected_zone,
        "ap_before":ap_before,
        "ap_after":int(result["state"].get("action_points",0)),
        "predicted_chain_count":int(preview_result.get("predicted_chain_count",0)),
        "month":int(before.get("month",4))
    })
    host.save_service.save(host.state)
    host._haptic(2)
    if host.feedback != null:
        host.feedback.pop("%s｜残り手入れ %d" % [Rules.intervention_name(preview_intervention_id),int(result["state"].get("action_points",0))],2)
    preview_intervention_id = ""
    preview_result = {}
    host._show_tab("farm")

func _on_month_end() -> void:
    var before: Dictionary = host.state["circulation_v4"]
    var pending: Array = before.get("pending_actions",[])
    if pending.is_empty():
        return
    var recovery_before := int(before.get("recovery_score",0))
    host._record_event("v4_month_end_pressed",{
        "month":int(before.get("month",4)),
        "actions":pending.size(),
        "recovery_before":recovery_before
    })
    var resolved: Dictionary = Rules.resolve_month(before,true)
    var after: Dictionary = resolved["state"]
    host.state["circulation_v4"] = after
    host._record_event("v4_chain_resolved",{
        "actual_chain_count":int(resolved.get("chain_count",0)),
        "recovery_before":recovery_before,
        "recovery_after":int(after.get("recovery_score",0)),
        "month":int(before.get("month",4))
    })
    host._record_event("v4_next_month_started",{
        "year":int(after.get("year",1)),
        "month":int(after.get("month",4)),
        "recovery":int(after.get("recovery_score",0))
    })
    host.save_service.save(host.state)
    host._haptic(4)
    if host.feedback != null:
        host.feedback.pop("里山が反応した｜%dつの変化" % int(resolved.get("chain_count",0)),3)
    selected_zone = ""
    preview_intervention_id = ""
    preview_result = {}
    host._sync_ambience()
    host._show_tab("farm")

func _zone_readable_state(board: Dictionary, zone_id: String) -> String:
    var zone: Dictionary = board.get("zones",{}).get(zone_id,{})
    var recovery := int(zone.get("recovery",0))
    if zone_id == "stream":
        return "沢の状態｜%s" % ("流れが戻っている" if int(zone.get("water",0)) > 0 else "流れが滞っている")
    if zone_id == "meadow":
        if int(zone.get("bloom",0)) > 0:
            return "草地の状態｜花が増え、次のつながりを待っている"
        return "草地の状態｜まだ単調で、生きものが少ない"
    if zone_id == "coop":
        return "鶏舎まわり｜循環資源を支える安定した場所"
    if recovery > 0:
        return "山菜区画｜植生が戻り始めている"
    if int(zone.get("soil",0)) > 0:
        return "山菜区画｜土は整った。水とのつながりを待っている"
    return "山菜区画｜土が痩せ、乾いている"

func _direct_effect_text(intervention: String) -> String:
    match intervention:
        Rules.INTERVENTION_COMPOST:
            return "すぐに：土が豊かになる"
        Rules.INTERVENTION_RESTORE_STREAM:
            return "すぐに：沢の流れを1段階戻す"
        Rules.INTERVENTION_FLOWERING_SHRUB:
            return "すぐに：草地に花を増やす"
    return "すぐに：里山へ手を入れる"

func _chain_preview_text(preview: Dictionary) -> String:
    var events: Array = preview.get("predicted_events",[])
    if events.is_empty():
        return "月末予想：まだ大きな連鎖は起きない"
    var text := _event_chain_text(events)
    var recovery := int(preview.get("predicted_recovery_score",0))
    return "月末予想：%s｜回復 %d%%" % [text,recovery]

func _event_chain_text(events: Array) -> String:
    var phrases := PackedStringArray()
    for event in events:
        var phrase := _event_phrase(str(event.get("type","")),str(event.get("zone","")))
        if not phrase.is_empty() and phrase not in phrases:
            phrases.append(phrase)
        if phrases.size() >= 5:
            break
    return " → ".join(phrases)

func _event_phrase(event_type: String, zone_id: String) -> String:
    match event_type:
        "stream_recovered": return "沢が流れる"
        "water_reached": return "%sに水が届く" % Rules.zone_name(zone_id)
        "growth": return "%sが育つ" % Rules.zone_name(zone_id)
        "pollinators_return": return "虫が戻る"
        "pollinator_boost": return "山菜がさらに繁る"
    return ""
