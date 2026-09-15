class_name FarmScreenV3
extends "res://scripts/ui/screens/farm_screen.gd"

const FarmDioramaV3Class = preload("res://scripts/ui/farm_diorama_v3.gd")

func _build_map(host) -> void:
    var farm_map = FarmDioramaV3Class.new()
    var viewport_h: float = host.get_viewport_rect().size.y
    # Give the scenery enough vertical authority to act as the emotional hero.
    farm_map.custom_minimum_size = Vector2(0,clampf(viewport_h * 0.54,445.0,520.0))
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
