class_name CirculationBoardV4
extends "res://scripts/ui/farm_diorama_v15.gd"

signal zone_selected(zone_id: String)

const ZONE_POS := {
    "sansai": Vector3(-1.8,0.0,3.0),
    "stream": Vector3(2.58,0.0,0.45),
    "meadow": Vector3(-3.05,0.0,-2.15),
    "coop": Vector3(-3.7,0.0,1.0)
}

const ZONE_HALF_SIZE := {
    "sansai": Vector2(1.45,0.92),
    "stream": Vector2(0.72,1.30),
    "meadow": Vector2(1.30,0.90),
    "coop": Vector2(1.10,0.82)
}

var board_state: Dictionary = {}
var selected_zone: String = ""
var selection_focus: Node3D
var board_state_layer: Node3D

func _build_world() -> void:
    super._build_world()
    if world_root == null:
        return
    world_root.name = "CirculationBoardV4World"
    var marker := Node3D.new()
    marker.name = "CirculationBoardV4Marker"
    world_root.add_child(marker)
    _ensure_selection_focus()
    _rebuild_board_state_layer()

func set_board_state(value: Dictionary) -> void:
    board_state = value.duplicate(true)
    if world_root == null:
        return
    var sansai_recovery := int(board_state.get("zones",{}).get("sansai",{}).get("recovery",0))
    set_restoration_stage(clampi(sansai_recovery,0,2))
    _rebuild_board_state_layer()
    _sync_selection_focus()

func select_zone(zone_id: String) -> void:
    if not ZONE_POS.has(zone_id):
        selected_zone = ""
    else:
        selected_zone = zone_id
    _sync_selection_focus()

func zone_world_position(zone_id: String) -> Vector3:
    return ZONE_POS.get(zone_id,Vector3.ZERO)

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
    for zone_id in ZONE_POS:
        var world_point: Vector3 = ZONE_POS[zone_id] + Vector3(0,0.20,0)
        if camera.is_position_behind(world_point):
            continue
        var screen_point: Vector2 = camera.unproject_position(world_point)
        var distance := point.distance_to(screen_point)
        if distance < nearest_distance:
            nearest_distance = distance
            nearest = str(zone_id)

    # Deliberately generous touch radius for portrait phones. Zones remain
    # visually authored terrain; no grid or invisible pixel-perfect hit test.
    if nearest != "" and nearest_distance <= 86.0:
        select_zone(nearest)
        zone_selected.emit(nearest)
        accept_event()

func _ensure_selection_focus() -> void:
    if world_root == null:
        return
    selection_focus = world_root.get_node_or_null("V4SelectedZoneFocus") as Node3D
    if selection_focus != null:
        return
    selection_focus = Node3D.new()
    selection_focus.name = "V4SelectedZoneFocus"
    selection_focus.visible = false
    world_root.add_child(selection_focus)

func _sync_selection_focus() -> void:
    _ensure_selection_focus()
    if selection_focus == null:
        return
    for child in selection_focus.get_children():
        child.queue_free()
    if selected_zone.is_empty() or not ZONE_POS.has(selected_zone):
        selection_focus.visible = false
        return

    selection_focus.visible = true
    selection_focus.position = ZONE_POS[selected_zone]
    var half: Vector2 = ZONE_HALF_SIZE.get(selected_zone,Vector2(1.0,0.75))
    var color := Color("#d8e69a")
    var arm := 0.34
    var thin := 0.045
    var y := 0.12
    for sx in [-1.0,1.0]:
        for sz in [-1.0,1.0]:
            _box_child(selection_focus,Vector3(sx*(half.x-arm*0.5),y,sz*half.y),Vector3(arm,0.035,thin),color)
            _box_child(selection_focus,Vector3(sx*half.x,y,sz*(half.y-arm*0.5)),Vector3(thin,0.035,arm),color)

func _rebuild_board_state_layer() -> void:
    if world_root == null:
        return
    if board_state_layer != null and is_instance_valid(board_state_layer):
        board_state_layer.queue_free()
    board_state_layer = Node3D.new()
    board_state_layer.name = "V4EcologicalStateLayer"
    world_root.add_child(board_state_layer)
    if board_state.is_empty():
        return

    var zones: Dictionary = board_state.get("zones",{})
    var stream_state: Dictionary = zones.get("stream",{})
    var stream_water := int(stream_state.get("water",0))
    if stream_water <= 0:
        # A short debris bar makes the blocked starting state legible.
        for i in range(4):
            _rock(Vector3(2.18 + float(i)*0.25,0.16,-0.10 + float(i%2)*0.14),0.12)
    else:
        for i in range(4 + stream_water):
            _box_child(
                board_state_layer,
                Vector3(2.42 + float(i%2)*0.26,0.125,-1.25 + float(i)*0.52),
                Vector3(0.34,0.025,0.045),
                Color("#d0efeb")
            )

    var meadow_state: Dictionary = zones.get("meadow",{})
    var bloom := int(meadow_state.get("bloom",0))
    if bloom > 0:
        for i in range(4 + bloom*3):
            _flower_child(
                board_state_layer,
                Vector3(-4.10 + float(i%4)*0.55,0.20,-2.62 + float(i/4)*0.42),
                900+i
            )

    var sansai_state: Dictionary = zones.get("sansai",{})
    var soil := int(sansai_state.get("soil",0))
    if soil > 0 and int(sansai_state.get("recovery",0)) <= 0:
        # Compost is visible immediately but does not fake recovery before month end.
        for i in range(5):
            _sphere_child(
                board_state_layer,
                Vector3(-2.65 + float(i)*0.38,0.17,2.62 + float(i%2)*0.30),
                0.07,
                Color("#4d3f31")
            )
