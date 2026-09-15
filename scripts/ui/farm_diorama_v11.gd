class_name FarmDioramaV11
extends "res://scripts/ui/farm_diorama_v10.gd"

# Visual Pass 9: guided interaction lock.
# During FTUE beats, unrelated facilities remain visible but are not tappable.
# This keeps the objective, world highlight and actual input contract aligned.

func _build_world() -> void:
    super._build_world()
    visual_pass = 9
    visual_target_id = "satoyama-premium-2026-09-15-v9"
    if world_root != null:
        world_root.name = "SatoyamaDioramaV11"
        var marker := Node3D.new()
        marker.name = "GuidedInteractionLockMarker"
        world_root.add_child(marker)

func _gui_input(event: InputEvent) -> void:
    var point := Vector2.ZERO
    var accepted := false
    if event is InputEventScreenTouch and event.pressed:
        point = event.position
        accepted = true
    elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
        point = event.position
        accepted = true
    if not accepted or camera == null:
        return

    var nearest := ""
    var nearest_distance := 99999.0
    for id in FACILITY_POS:
        # Guided FTUE beats allow only the highlighted facility to receive
        # world taps. Everything else stays visible but inert.
        if not guided_focus.is_empty() and id != guided_focus:
            continue
        var world_point: Vector3 = FACILITY_POS[id] + Vector3(0,0.55,0)
        if camera.is_position_behind(world_point):
            continue
        var screen_point: Vector2 = camera.unproject_position(world_point)
        var distance := point.distance_to(screen_point)
        if distance < nearest_distance:
            nearest_distance = distance
            nearest = id

    if nearest != "" and nearest_distance <= 72.0:
        selected_facility = nearest
        facility_selected.emit(nearest)
        focus_facility(nearest)
        accept_event()
