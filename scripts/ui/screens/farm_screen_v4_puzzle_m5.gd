class_name FarmScreenV4PuzzleM5
extends "res://scripts/ui/screens/farm_screen_v4_puzzle.gd"

const CirculationBoardM5 = preload("res://scripts/ui/circulation_board_v5.gd")

func _build_board(board_state: Dictionary) -> void:
    var farm_map = CirculationBoardM5.new()
    farm_map.name = "CirculationBoardV5"
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
    if not preview_intervention_id.is_empty() and bool(preview_result.get("ok",false)):
        farm_map.set_chain_preview(
            selected_zone,
            preview_result.get("predicted_events",[])
        )
    farm_map.zone_selected.connect(Callable(self,"_on_zone_selected"))
    host.content.add_child(farm_map)
    host.map = farm_map
