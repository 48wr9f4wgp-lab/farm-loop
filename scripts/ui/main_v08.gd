extends "res://scripts/ui/main_v07.gd"

const ProductMapOverlayV08Class = preload("res://scripts/ui/product_map_overlay_v08.gd")
const ProductMapOverlayV07Class = preload("res://scripts/ui/product_map_overlay_v07.gd")

func _ready() -> void:
    super._ready()
    state["version"] = "godot-0.8-art-wave"
    save_service.save(state)
    _show_tab(current_tab)

func _build_farm() -> void:
    super._build_farm()
    if map == null or not rules.has_method("land_progress"):
        return
    for child in map.get_children():
        if child.get_script() == ProductMapOverlayV07Class:
            child.queue_free()
    var progress: Dictionary = rules.land_progress(state)
    var art = ProductMapOverlayV08Class.new()
    art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    art.set_product_state(rules.season_key(int(state["month"])),int(progress["rank"]),bool(state["settings"].get("reduced_motion",false)))
    map.add_child(art)
