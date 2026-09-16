class_name CirculationBoardV5
extends "res://scripts/ui/circulation_board_v4.gd"

# V4 M5: show causal preview in the diorama before the player commits.
# This layer is prediction-only: it never mutates ecological board state.

var chain_preview_source: String = ""
var chain_preview_events: Array = []
var chain_preview_layer: Node3D
var chain_preview_pulse_nodes: Array[Node3D] = []
var chain_preview_edge_count: int = 0
var chain_preview_target_count: int = 0
var chain_preview_time: float = 0.0

func _build_world() -> void:
    super._build_world()
    if world_root == null:
        return
    world_root.name = "CirculationBoardV5World"
    var marker := Node3D.new()
    marker.name = "V4M5ChainPreviewMarker"
    world_root.add_child(marker)
    _rebuild_chain_preview()

func set_chain_preview(source_zone: String, events: Array) -> void:
    chain_preview_source = source_zone if ZONE_POS.has(source_zone) else ""
    chain_preview_events = events.duplicate(true)
    _rebuild_chain_preview()

func clear_chain_preview() -> void:
    chain_preview_source = ""
    chain_preview_events = []
    _rebuild_chain_preview()

func _process(delta: float) -> void:
    super._process(delta)
    if reduced_motion or chain_preview_pulse_nodes.is_empty():
        return
    chain_preview_time += delta
    for i in range(chain_preview_pulse_nodes.size()):
        var node := chain_preview_pulse_nodes[i]
        if not is_instance_valid(node):
            continue
        var phase := float(node.get_meta("preview_phase",float(i) * 0.55))
        var strength := 1.0 + 0.12 * sin(chain_preview_time * 3.2 + phase)
        node.scale = Vector3.ONE * strength

func _rebuild_chain_preview() -> void:
    chain_preview_edge_count = 0
    chain_preview_target_count = 0
    chain_preview_pulse_nodes.clear()
    if world_root == null:
        return
    if chain_preview_layer != null and is_instance_valid(chain_preview_layer):
        chain_preview_layer.queue_free()
    chain_preview_layer = Node3D.new()
    chain_preview_layer.name = "V4M5ChainPreviewLayer"
    world_root.add_child(chain_preview_layer)
    if chain_preview_source.is_empty() or chain_preview_events.is_empty():
        return

    var seen_edges: Dictionary = {}
    var seen_targets: Dictionary = {}
    for event in chain_preview_events:
        if not (event is Dictionary):
            continue
        var event_type := str(event.get("type",""))
        var target := str(event.get("zone",""))
        var source := str(event.get("from",chain_preview_source))
        if source.is_empty():
            source = chain_preview_source

        if ZONE_POS.has(target) and not seen_targets.has(target):
            seen_targets[target] = true
            _add_target_pulse(target,_event_color(event_type))
            chain_preview_target_count += 1

        if source == target or not ZONE_POS.has(source) or not ZONE_POS.has(target):
            continue
        var edge_key := "%s>%s" % [source,target]
        if seen_edges.has(edge_key):
            continue
        seen_edges[edge_key] = true
        _add_connection(source,target,_event_color(event_type),chain_preview_edge_count)
        chain_preview_edge_count += 1

func _event_color(event_type: String) -> Color:
    match event_type:
        "stream_recovered", "water_reached":
            return Color("#8bcfd8")
        "growth", "pollinator_boost":
            return Color("#a9cf74")
        "pollinators_return":
            return Color("#e1cf72")
        _:
            return Color("#c8d997")

func _add_connection(source_zone: String, target_zone: String, color: Color, edge_index: int) -> void:
    var start: Vector3 = ZONE_POS[source_zone] + Vector3(0,0.29,0)
    var finish: Vector3 = ZONE_POS[target_zone] + Vector3(0,0.29,0)
    var delta := finish - start
    var length := Vector2(delta.x,delta.z).length()
    if length <= 0.05:
        return
    var midpoint := start.lerp(finish,0.5)
    var angle := atan2(delta.z,delta.x)
    _box_child(
        chain_preview_layer,
        midpoint,
        Vector3(length,0.020,0.045),
        Color(color.r,color.g,color.b,0.82),
        Vector3(0,-angle,0)
    )

    # Moving-looking dotted nodes keep the connection legible at phone scale
    # without requiring expensive particles or camera movement.
    for i in range(1,6):
        var t := float(i) / 6.0
        var dot := _sphere_child(
            chain_preview_layer,
            start.lerp(finish,t) + Vector3(0,0.025,0),
            0.055,
            color
        )
        dot.set_meta("preview_phase",float(edge_index) * 0.9 + float(i) * 0.52)
        chain_preview_pulse_nodes.append(dot)

func _add_target_pulse(zone_id: String, color: Color) -> void:
    var pulse := Node3D.new()
    pulse.name = "PreviewTarget_%s" % zone_id
    pulse.position = ZONE_POS[zone_id] + Vector3(0,0.23,0)
    chain_preview_layer.add_child(pulse)
    var half: Vector2 = ZONE_HALF_SIZE.get(zone_id,Vector2(1.0,0.75))
    var radius_x := minf(half.x,1.10)
    var radius_z := minf(half.y,0.78)
    for i in range(8):
        var angle := TAU * float(i) / 8.0
        _sphere_child(
            pulse,
            Vector3(cos(angle)*radius_x,0,sin(angle)*radius_z),
            0.045,
            color
        )
    pulse.set_meta("preview_phase",float(chain_preview_target_count) * 0.8)
    chain_preview_pulse_nodes.append(pulse)
