class_name FarmDioramaV1
extends SubViewportContainer

signal facility_selected(facility_id: String)
signal player_arrived(facility_id: String)

var season: String = "spring"
var weather: String = "晴れ"
var readiness: Dictionary = {}
var selected_facility: String = "coop"
var reduced_motion: bool = false
var restoration_stage: int = 0
var action_facility: String = ""
var action_timer: float = 0.0
var is_3d_diorama: bool = true

var viewport_3d: SubViewport
var world_root: Node3D
var camera: Camera3D
var player: Node3D
var sun: DirectionalLight3D
var facility_nodes: Dictionary = {}
var ready_markers: Dictionary = {}
var restore_root: Node3D
var ambient_nodes: Array[Node3D] = []
var ambient_time: float = 0.0
var movement_tween: Tween

const FACILITY_POS := {
    "coop": Vector3(-3.7,0.0,1.0),
    "compost": Vector3(-0.8,0.0,-0.6),
    "mushroom": Vector3(3.25,0.0,0.2),
    "sansai": Vector3(-1.8,0.0,3.0),
    "bee": Vector3(2.25,0.0,2.65)
}

const C_GROUND := Color("#6f9b58")
const C_GROUND_DARK := Color("#52784a")
const C_EARTH := Color("#795943")
const C_EARTH_DRY := Color("#6f6251")
const C_WOOD := Color("#86593b")
const C_WOOD_DARK := Color("#4f392d")
const C_ROOF := Color("#6e4435")
const C_PATH := Color("#c7ae80")
const C_WATER := Color("#5ca7b6")
const C_LEAF := Color("#4f8750")
const C_LEAF_LIGHT := Color("#7daf5d")
const C_SNOW := Color("#f0f6f5")
const C_GOLD := Color("#f0c54f")
const C_SKY := Color("#a6cdd4")

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_STOP
    stretch = true
    _build_viewport()
    _build_world()
    _sync_visual_state()
    set_process(true)

func set_state(new_season: String, new_weather: String, ready_state: Dictionary, selected: String = "", reduce_motion: bool = false) -> void:
    season = new_season
    weather = new_weather
    readiness = ready_state.duplicate(true)
    selected_facility = selected
    reduced_motion = reduce_motion
    if world_root != null:
        _sync_visual_state()

func set_restoration_stage(stage: int) -> void:
    restoration_stage = clampi(stage,0,2)
    if restore_root != null:
        _rebuild_restore_patch()

func focus_facility(id: String) -> void:
    if not FACILITY_POS.has(id) or player == null:
        return
    selected_facility = id
    _update_selection()
    if movement_tween != null and movement_tween.is_valid():
        movement_tween.kill()
    var target: Vector3 = FACILITY_POS[id] + Vector3(0,0.46,0.44)
    if reduced_motion:
        player.position = target
        player_arrived.emit(id)
        return
    movement_tween = create_tween()
    movement_tween.set_trans(Tween.TRANS_QUAD)
    movement_tween.set_ease(Tween.EASE_IN_OUT)
    movement_tween.tween_property(player,"position",target,0.52)
    movement_tween.finished.connect(func(): player_arrived.emit(id))

func play_action_feedback(id: String) -> void:
    action_facility = id
    action_timer = 0.62
    if not facility_nodes.has(id):
        return
    var node: Node3D = facility_nodes[id]
    if reduced_motion:
        return
    var tw := create_tween()
    tw.set_trans(Tween.TRANS_BACK)
    tw.set_ease(Tween.EASE_OUT)
    tw.tween_property(node,"scale",Vector3.ONE*1.10,0.12)
    tw.tween_property(node,"scale",Vector3.ONE,0.24)

func _notification(what: int) -> void:
    if what == NOTIFICATION_RESIZED and viewport_3d != null:
        viewport_3d.size = Vector2i(maxi(1,int(size.x)),maxi(1,int(size.y)))

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

func _process(delta: float) -> void:
    if action_timer > 0.0:
        action_timer = maxf(0.0,action_timer-delta)
    if reduced_motion:
        return
    ambient_time += delta
    for i in range(ambient_nodes.size()):
        var n := ambient_nodes[i]
        if is_instance_valid(n):
            n.rotation.y += delta*(0.08+float(i%3)*0.018)
            n.position.y = 0.55 + sin(ambient_time*1.2+float(i))*0.035

func _build_viewport() -> void:
    viewport_3d = SubViewport.new()
    viewport_3d.name = "DioramaViewport"
    viewport_3d.size = Vector2i(maxi(1,int(size.x)),maxi(1,int(size.y)))
    viewport_3d.own_world_3d = true
    viewport_3d.render_target_update_mode = SubViewport.UPDATE_ALWAYS
    viewport_3d.msaa_3d = Viewport.MSAA_2X
    add_child(viewport_3d)

func _build_world() -> void:
    world_root = Node3D.new()
    world_root.name = "SatoyamaDiorama"
    viewport_3d.add_child(world_root)

    var env_node := WorldEnvironment.new()
    var env := Environment.new()
    env.background_mode = Environment.BG_COLOR
    env.background_color = C_SKY
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color("#dbe5d6")
    env.ambient_light_energy = 0.82
    env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
    env_node.environment = env
    world_root.add_child(env_node)

    sun = DirectionalLight3D.new()
    sun.light_color = Color("#fff1c4")
    sun.light_energy = 1.45
    sun.shadow_enabled = true
    sun.rotation_degrees = Vector3(-54,-32,0)
    world_root.add_child(sun)

    camera = Camera3D.new()
    camera.projection = Camera3D.PROJECTION_ORTHOGONAL
    camera.size = 11.8
    camera.position = Vector3(9.6,10.7,13.2)
    camera.look_at(Vector3(0.0,0.45,0.7),Vector3.UP)
    camera.current = true
    world_root.add_child(camera)

    _build_landscape()
    _build_facilities()
    _build_player()
    _rebuild_restore_patch()

func _build_landscape() -> void:
    _box("Ground",Vector3(0,-0.22,0),Vector3(13.5,0.42,10.2),C_GROUND)
    _box("BackSlope",Vector3(0,0.0,-4.25),Vector3(13.5,0.5,1.4),C_GROUND_DARK)

    _cone("MountainLeft",Vector3(-3.4,1.45,-5.0),2.55,3.5,Color("#597565"))
    _cone("MountainRight",Vector3(2.4,1.25,-5.25),2.85,3.1,Color("#66816d"))
    _cone("SnowLeft",Vector3(-3.4,2.74,-5.0),0.72,0.92,C_SNOW)
    _cone("SnowRight",Vector3(2.4,2.40,-5.25),0.72,0.82,C_SNOW)

    _box("River",Vector3(2.65,0.025,1.0),Vector3(1.18,0.08,8.2),C_WATER,Vector3(0,-0.11,0))
    _box("PathA",Vector3(-0.25,0.055,0.9),Vector3(8.7,0.10,1.28),C_PATH,Vector3(0,-0.13,0))
    _box("PathB",Vector3(0.45,0.06,2.15),Vector3(1.15,0.10,4.6),C_PATH,Vector3(0,0.47,0))

    for i in range(13):
        var x := -5.4 + float(i)*0.88
        var z := -3.55 + float(i%3)*0.12
        _tree(Vector3(x,0.0,z),0.72+float(i%3)*0.09,i%2==0)
    for i in range(7):
        var x2 := 3.2 + float(i%3)*0.75
        var z2 := -1.8 + float(i)*0.65
        _tree(Vector3(x2,0.0,z2),0.62+float(i%2)*0.10,i%2==1)

    for i in range(5):
        var water_glint := _box("WaterGlint%d" % i,Vector3(2.55+float(i%2)*0.13,0.09,-1.7+float(i)*1.34),Vector3(0.5,0.025,0.05),Color("#d6f0ef"))
        ambient_nodes.append(water_glint)

func _build_facilities() -> void:
    facility_nodes["coop"] = _build_coop(FACILITY_POS["coop"])
    facility_nodes["compost"] = _build_compost(FACILITY_POS["compost"])
    facility_nodes["mushroom"] = _build_mushroom(FACILITY_POS["mushroom"])
    facility_nodes["bee"] = _build_bees(FACILITY_POS["bee"])

    for id in FACILITY_POS:
        var marker := _sphere("Ready_%s" % id,FACILITY_POS[id]+Vector3(0,1.45,0),0.16,C_GOLD)
        ready_markers[id] = marker

func _build_player() -> void:
    player = Node3D.new()
    player.name = "Player"
    player.position = Vector3(0.2,0.46,3.9)
    world_root.add_child(player)
    _cylinder_child(player,Vector3(0,0.30,0),0.18,0.58,Color("#325c4a"),8)
    _sphere_child(player,Vector3(0,0.70,0),0.19,Color("#e2b184"))
    _cylinder_child(player,Vector3(0,0.89,0),0.35,0.08,Color("#9a6a35"),12)
    _cone_child(player,Vector3(0,0.96,0),0.26,0.22,Color("#b77c3f"))

func _build_coop(pos: Vector3) -> Node3D:
    var root := Node3D.new()
    root.name = "Coop"
    root.position = pos
    world_root.add_child(root)
    _box_child(root,Vector3(0,0.48,0),Vector3(1.55,0.92,1.15),Color("#a96645"))
    _box_child(root,Vector3(0,1.02,0),Vector3(1.72,0.22,1.30),C_ROOF,Vector3(0,0,0.18))
    _box_child(root,Vector3(0,0.44,0.59),Vector3(0.42,0.50,0.08),Color("#4d382b"))
    for i in range(3):
        var chicken := Node3D.new()
        chicken.position = Vector3(-0.58+float(i)*0.45,0.13,0.78+float(i%2)*0.18)
        root.add_child(chicken)
        _sphere_child(chicken,Vector3.ZERO,0.13,Color("#f3ead6"))
        _sphere_child(chicken,Vector3(0,0.13,0.08),0.085,Color("#f3ead6"))
        ambient_nodes.append(chicken)
    return root

func _build_compost(pos: Vector3) -> Node3D:
    var root := Node3D.new()
    root.name = "Compost"
    root.position = pos
    world_root.add_child(root)
    _box_child(root,Vector3(0,0.28,0),Vector3(1.42,0.56,1.05),C_WOOD_DARK)
    _box_child(root,Vector3(0,0.58,0),Vector3(1.55,0.12,1.14),C_WOOD)
    _box_child(root,Vector3(0,0.68,0),Vector3(1.10,0.16,0.76),Color("#596b3f"))
    for i in range(3):
        _sphere_child(root,Vector3(-0.28+float(i)*0.28,0.95,0),0.11,Color(0.93,0.95,0.88,0.45))
    return root

func _build_mushroom(pos: Vector3) -> Node3D:
    var root := Node3D.new()
    root.name = "MushroomLogs"
    root.position = pos
    world_root.add_child(root)
    for i in range(3):
        var log := _cylinder_child(root,Vector3(0,0.20+float(i)*0.22,-0.25+float(i)*0.18),0.24,1.45,C_WOOD,10)
        log.rotation_degrees.z = 90
        for j in range(2):
            _sphere_child(root,Vector3(-0.35+float(j)*0.7,0.44+float(i)*0.20,-0.18+float(i)*0.18),0.13,Color("#d8c8ad"))
    return root

func _build_bees(pos: Vector3) -> Node3D:
    var root := Node3D.new()
    root.name = "BeeHives"
    root.position = pos
    world_root.add_child(root)
    for i in range(3):
        _box_child(root,Vector3(-0.52+float(i)*0.52,0.36,0),Vector3(0.42,0.72,0.42),Color("#d4a036"))
        _box_child(root,Vector3(-0.52+float(i)*0.52,0.74,0),Vector3(0.48,0.10,0.48),Color("#765339"))
    for i in range(4):
        var bee := _sphere_child(root,Vector3(-0.45+float(i)*0.28,0.95+float(i%2)*0.12,0.20),0.07,C_GOLD)
        ambient_nodes.append(bee)
    return root

func _rebuild_restore_patch() -> void:
    if world_root == null:
        return
    if restore_root != null and is_instance_valid(restore_root):
        restore_root.queue_free()
    restore_root = Node3D.new()
    restore_root.name = "RestorePatch"
    restore_root.position = FACILITY_POS["sansai"]
    world_root.add_child(restore_root)

    var soil_color := C_EARTH_DRY
    if restoration_stage == 1:
        soil_color = Color("#746247")
    elif restoration_stage >= 2:
        soil_color = Color("#596842")
    _box_child(restore_root,Vector3(0,0.07,0),Vector3(2.7,0.14,1.85),soil_color,Vector3(0,-0.10,0))

    var plant_count := 2
    if restoration_stage == 1:
        plant_count = 6
    elif restoration_stage >= 2:
        plant_count = 12
    for i in range(plant_count):
        var row := i/4
        var col := i%4
        var x := -0.90+float(col)*0.58+float(row%2)*0.14
        var z := -0.45+float(row)*0.47
        var stem_h := 0.18+float(i%3)*0.05
        _cylinder_child(restore_root,Vector3(x,0.14+stem_h*0.5,z),0.025,stem_h,Color("#3f6f3f"),6)
        _sphere_child(restore_root,Vector3(x-0.07,0.25+stem_h,z),0.10,C_LEAF_LIGHT)
        _sphere_child(restore_root,Vector3(x+0.08,0.30+stem_h,z+0.03),0.11,C_LEAF)
    if restoration_stage >= 1:
        for i in range(3 if restoration_stage == 1 else 6):
            var life := _sphere_child(restore_root,Vector3(-1.0+float(i)*0.38,0.55+float(i%2)*0.08,0.72-float(i%3)*0.20),0.045,Color("#f2d66a"))
            ambient_nodes.append(life)
    facility_nodes["sansai"] = restore_root

func _sync_visual_state() -> void:
    if world_root == null:
        return
    var ground = world_root.get_node_or_null("Ground") as MeshInstance3D
    if ground != null:
        var c := C_GROUND
        if season == "summer": c = Color("#5f934f")
        elif season == "autumn": c = Color("#8b8250")
        elif season == "winter": c = Color("#dce7e3")
        ground.material_override = _material(c)
    if sun != null:
        sun.light_energy = 1.05 if weather in ["雪","雨"] else 1.45
    for id in ready_markers:
        var marker: Node3D = ready_markers[id]
        marker.visible = true if id == "compost" else bool(readiness.get(id,false))
    _update_selection()
    _rebuild_restore_patch()

func _update_selection() -> void:
    for id in facility_nodes:
        var node: Node3D = facility_nodes[id]
        if not is_instance_valid(node):
            continue
        node.scale = Vector3.ONE*1.055 if id == selected_facility else Vector3.ONE

func _tree(pos: Vector3, scale_value: float, light: bool) -> void:
    var root := Node3D.new()
    root.position = pos
    root.scale = Vector3.ONE*scale_value
    world_root.add_child(root)
    _cylinder_child(root,Vector3(0,0.38,0),0.10,0.76,C_WOOD_DARK,7)
    var crown := C_LEAF_LIGHT if light else C_LEAF
    if season == "autumn": crown = Color("#a06d3f") if light else Color("#7f5d39")
    elif season == "winter": crown = Color("#66796f")
    _sphere_child(root,Vector3(0,0.93,0),0.48,crown)
    _sphere_child(root,Vector3(-0.22,0.80,0.04),0.32,crown.lightened(0.05))
    if season == "winter":
        _sphere_child(root,Vector3(0,1.18,0),0.28,C_SNOW)

func _box(name_text: String, pos: Vector3, mesh_size: Vector3, color: Color, rot: Vector3 = Vector3.ZERO) -> MeshInstance3D:
    var m := MeshInstance3D.new()
    m.name = name_text
    var mesh := BoxMesh.new()
    mesh.size = mesh_size
    m.mesh = mesh
    m.material_override = _material(color)
    m.position = pos
    m.rotation = rot
    world_root.add_child(m)
    return m

func _box_child(parent: Node3D, pos: Vector3, mesh_size: Vector3, color: Color, rot: Vector3 = Vector3.ZERO) -> MeshInstance3D:
    var m := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = mesh_size
    m.mesh = mesh
    m.material_override = _material(color)
    m.position = pos
    m.rotation = rot
    parent.add_child(m)
    return m

func _sphere(name_text: String, pos: Vector3, radius: float, color: Color) -> MeshInstance3D:
    var m := MeshInstance3D.new()
    m.name = name_text
    var mesh := SphereMesh.new()
    mesh.radius = radius
    mesh.height = radius*2.0
    mesh.radial_segments = 10
    mesh.rings = 5
    m.mesh = mesh
    m.material_override = _material(color)
    m.position = pos
    world_root.add_child(m)
    return m

func _sphere_child(parent: Node3D, pos: Vector3, radius: float, color: Color) -> MeshInstance3D:
    var m := MeshInstance3D.new()
    var mesh := SphereMesh.new()
    mesh.radius = radius
    mesh.height = radius*2.0
    mesh.radial_segments = 10
    mesh.rings = 5
    m.mesh = mesh
    m.material_override = _material(color)
    m.position = pos
    parent.add_child(m)
    return m

func _cylinder_child(parent: Node3D, pos: Vector3, radius: float, height: float, color: Color, segments: int) -> MeshInstance3D:
    var m := MeshInstance3D.new()
    var mesh := CylinderMesh.new()
    mesh.top_radius = radius
    mesh.bottom_radius = radius
    mesh.height = height
    mesh.radial_segments = segments
    m.mesh = mesh
    m.material_override = _material(color)
    m.position = pos
    parent.add_child(m)
    return m

func _cone(name_text: String, pos: Vector3, radius: float, height: float, color: Color) -> MeshInstance3D:
    var m := MeshInstance3D.new()
    m.name = name_text
    var mesh := CylinderMesh.new()
    mesh.top_radius = 0.0
    mesh.bottom_radius = radius
    mesh.height = height
    mesh.radial_segments = 7
    m.mesh = mesh
    m.material_override = _material(color)
    m.position = pos
    world_root.add_child(m)
    return m

func _cone_child(parent: Node3D, pos: Vector3, radius: float, height: float, color: Color) -> MeshInstance3D:
    var m := MeshInstance3D.new()
    var mesh := CylinderMesh.new()
    mesh.top_radius = 0.0
    mesh.bottom_radius = radius
    mesh.height = height
    mesh.radial_segments = 10
    m.mesh = mesh
    m.material_override = _material(color)
    m.position = pos
    parent.add_child(m)
    return m

func _material(color: Color) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.roughness = 0.88
    return material
