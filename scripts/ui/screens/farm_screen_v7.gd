class_name FarmScreenV7
extends "res://scripts/ui/screens/farm_screen_v6.gd"

const FarmDioramaV7Class = preload("res://scripts/ui/farm_diorama_v7.gd")

func _build_map(host) -> void:
    var farm_map = FarmDioramaV7Class.new()
    var viewport_h: float = host.get_viewport_rect().size.y
    farm_map.custom_minimum_size = Vector2(0,clampf(viewport_h * 0.55,455.0,530.0))
    farm_map.set_state(
        host.rules.season_key(int(host.state["month"])),
        str(host.state["weather"]),
        host.state["ready"],
        host.selected_facility,
        bool(host.state["settings"].get("reduced_motion",false))
    )

    var guided: bool = host.ftue_service != null and host.ftue_service.active(host.state)
    var guided_step: int = host.ftue_service.step(host.state) if guided else -1
    var focus_id := ""
    if guided_step == 0:
        focus_id = "coop"
    elif guided_step == 2:
        focus_id = "compost"
    elif guided_step in [4,5]:
        focus_id = "sansai"
    if not focus_id.is_empty():
        farm_map.set_guided_focus(focus_id)

    var restore_stage: int = int(host.state.get("restoration_v3",{}).get("first_patch_stage",0))
    if host.ftue_service != null and host.ftue_service.has_method("restoration_stage"):
        restore_stage = int(host.ftue_service.restoration_stage(host.state))
    farm_map.set_restoration_stage(restore_stage)
    farm_map.facility_selected.connect(Callable(host,"_on_map_select"))
    farm_map.player_arrived.connect(Callable(host,"_on_map_arrive"))
    host.content.add_child(farm_map)
    host.map = farm_map
