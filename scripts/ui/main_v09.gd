extends "res://scripts/ui/main_v08.gd"

const FarmMapV09Class = preload("res://scripts/ui/farm_map_v09.gd")
const ProductMapOverlayV09Class = preload("res://scripts/ui/product_map_overlay_v09.gd")

var _v09_boot_guard: bool = true

func _ready() -> void:
    _v09_boot_guard = true
    super._ready()
    _v09_boot_guard = false
    state["version"] = "godot-0.9-product-wave3"
    save_service.save(state)
    _show_tab(current_tab)

func _show_tab(tab: String) -> void:
    if _v09_boot_guard:
        return
    super._show_tab(tab)

func _clear() -> void:
    map = null
    selected_title_label = null
    selected_desc_label = null
    selected_action_button = null
    if content == null:
        return
    for child in content.get_children():
        content.remove_child(child)
        child.queue_free()

func _build_shell() -> void:
    super._build_shell()
    if root_box != null and root_box.get_child_count() > 0:
        var head = root_box.get_child(0)
        if head is HBoxContainer and head.get_child_count() > 0:
            var brand = head.get_child(0)
            if brand is VBoxContainer and brand.get_child_count() > 1:
                var subtitle = brand.get_child(1)
                if subtitle is Label:
                    subtitle.text = "YUKISATO  •  FARM LOOP"
                    subtitle.add_theme_font_size_override("font_size",8)

func _contains_exact_label(root_node: Node, target: String) -> bool:
    if root_node is Label and str(root_node.text) == target:
        return true
    for child in root_node.get_children():
        if _contains_exact_label(child,target):
            return true
    return false

func _remove_legacy_location_panels(quick_panel: Control) -> void:
    for child in content.get_children().duplicate():
        if child == quick_panel:
            continue
        if _contains_exact_label(child,"今いる場所"):
            content.remove_child(child)
            child.queue_free()

func _build_farm() -> void:
    super._build_farm()
    if map == null:
        return

    var quick_panel: Control = null
    if selected_action_button != null and selected_action_button.get_parent() != null:
        var box = selected_action_button.get_parent()
        if box.get_parent() is PanelContainer:
            quick_panel = box.get_parent()

    _remove_legacy_location_panels(quick_panel)

    var old_map: Control = map
    var old_index: int = old_map.get_index()
    var replacement = FarmMapV09Class.new()
    replacement.custom_minimum_size = Vector2(0,360)
    replacement.set_state(
        rules.season_key(int(state["month"])),
        str(state["weather"]),
        state["ready"],
        selected_facility,
        bool(state["settings"].get("reduced_motion",false))
    )
    replacement.player_pos = Vector2(0.50,0.84)
    replacement.target_pos = replacement.player_pos
    replacement.facility_selected.connect(_on_map_select)
    replacement.player_arrived.connect(_on_map_arrive)

    content.remove_child(old_map)
    old_map.queue_free()
    content.add_child(replacement)
    content.move_child(replacement,mini(old_index,content.get_child_count()-1))
    map = replacement

    var progress: Dictionary = rules.land_progress(state)
    var art = ProductMapOverlayV09Class.new()
    art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    art.set_product_state(
        rules.season_key(int(state["month"])),
        int(progress["rank"]),
        bool(state["settings"].get("reduced_motion",false))
    )
    map.add_child(art)

    if quick_panel != null and quick_panel.get_parent() == content:
        content.move_child(quick_panel,0)
        content.move_child(map,1)
        quick_panel.add_theme_stylebox_override("panel",_panel_style(Color("#fffdf7"),17))

    if selected_desc_label != null:
        selected_desc_label.add_theme_font_size_override("font_size",11)
    if selected_action_button != null:
        selected_action_button.custom_minimum_size.y = 50
    _refresh_selected_panel()

func _on_map_arrive(id: String) -> void:
    selected_facility = id
    state["ui"]["selected_facility"] = id
    _refresh_selected_panel()
    _header()
    if feedback != null:
        feedback.pop("%sに到着" % _facility_name(id),1)

func _refresh_selected_panel() -> void:
    super._refresh_selected_panel()
    if quick_ready_label != null:
        var is_ready: bool = true if selected_facility == "compost" else bool(state["ready"].get(selected_facility,false))
        quick_ready_label.text = "作業OK" if is_ready else "完了"
    if selected_action_button != null and not selected_action_button.disabled:
        selected_action_button.text = _facility_action_label(selected_facility)
