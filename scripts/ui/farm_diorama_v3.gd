class_name FarmDioramaV3
extends "res://scripts/ui/farm_diorama_v2.gd"

# Visual Pass 1 toward the approved 2026-09-15 finished-state concept.
# Runtime rules, Save and FTUE contracts stay unchanged; this file only
# upgrades the presentation layer and keeps the fixed tap-first diorama.

const V3_GRASS := Color("#7fa963")
const V3_GRASS_DARK := Color("#557c50")
const V3_GRASS_LIGHT := Color("#a5c97b")
const V3_EARTH := Color("#76533b")
const V3_SOIL := Color("#5e4634")
const V3_DRY_SOIL := Color("#9b7a55")
const V3_WOOD := Color("#9a643f")
const V3_WOOD_DARK := Color("#5b3c2c")
const V3_ROOF_RED := Color("#a8543d")
const V3_ROOF_DARK := Color("#5b4b43")
const V3_PATH := Color("#d8c49a")
const V3_STONE := Color("#a7aca1")
const V3_WATER := Color("#68bed0")
const V3_WATER_LIGHT := Color("#d7f4ef")
const V3_PINE := Color("#3f6b50")
const V3_LEAF := Color("#5f9252")
const V3_LEAF_LIGHT := Color("#91bb66")
const V3_SAKURA := Color("#efb5bd")
const V3_SAKURA_LIGHT := Color("#f7d0d4")
const V3_FLOWER := Color("#f5e6b3")
const V3_SKY := Color("#c7e0e3")

func _build_world() -> void:
    world_root = Node3D.new()
    world_root.name = "SatoyamaDioramaV3"
    viewport_3d.add_child(world_root)

    var env_node := WorldEnvironment.new()
    var env := Environment.new()
    env.background_mode = Environment.BG_COLOR
    env.background_color = V3_SKY
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color("#f3f1df")
    env.ambient_light_energy = 0.72
    env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
    env_node.environment = env
    world_root.add_child(env_node)

    sun = DirectionalLight3D.new()
    sun.light_color = Color("#fff0c7")
    sun.light_energy = 1.62
    sun.shadow_enabled = true
    sun.rotation_degrees = Vector3(-49,-34,0)
    world_root.add_child(sun)

    var fill := DirectionalLight3D.new()
    fill.light_color = Color("#d7edf0")
    fill.light_energy = 0.28
    fill.shadow_enabled = false
    fill.rotation_degrees = Vector3(-26,138,0)
    world_root.add_child(fill)

    camera = Camera3D.new()
    camera.projection = Camera3D.PROJECTION_ORTHOGONAL
    camera.size = 11.25
    world_root.add_child(camera)
    camera.position = Vector3(9.4,10.5,14.2)
    camera.look_at(Vector3(0.0,0.62,0.55),Vector3.UP)
    camera.current = true

    _build_landscape()
    _build_facilities()
    _build_player()
    _rebuild_restore_patch()

func _build_landscape() -> void:
    # Floating miniature base: visible dark earth sides under a soft grass cap.
    _box("IslandBase",Vector3(0,-0.52,0),Vector3(13.7,0.72,10.35),Color("#6a513a"))
    _box("Ground",Vector3(0,-0.13,0),Vector3(13.45,0.18,10.05),V3_GRASS)
    _box("BackTerrace",Vector3(0,0.01,-4.15),Vector3(13.25,0.34,1.50),V3_GRASS_DARK)
    _box("LeftTerrace",Vector3(-4.8,0.02,-2.65),Vector3(3.65,0.28,1.85),Color("#71975b"))

    # Layered snow-country mountain backdrop.
    _mountain(Vector3(-4.7,1.20,-5.45),2.05,2.8,Color("#708877"),0.54)
    _mountain(Vector3(-2.1,1.72,-5.60),2.70,3.9,Color("#607969"),0.70)
    _mountain(Vector3(1.25,1.52,-5.55),2.85,3.55,Color("#69836e"),0.66)
    _mountain(Vector3(4.25,1.05,-5.30),2.05,2.65,Color("#78927a"),0.48)

    # Woodland ridge with spring variation and blossom punctuation.
    for i in range(17):
        var x := -6.05 + float(i) * 0.76
        var z := -3.58 + float(i % 3) * 0.14
        var scale_value := 0.58 + float(i % 4) * 0.07
        _spring_tree(Vector3(x,0.02,z),scale_value,i in [1,8,14])
    for i in range(6):
        _spring_tree(Vector3(4.0+float(i%2)*0.72,0.0,-1.95+float(i)*0.78),0.57+float(i%3)*0.08,i in [1,5])

    # Meandering stream built from overlapping shallow segments.
    _box("RiverA",Vector3(2.72,0.015,-2.50),Vector3(1.05,0.075,3.20),V3_WATER,Vector3(0,-0.08,0))
    _box("RiverB",Vector3(2.60,0.018,0.20),Vector3(1.12,0.078,2.90),V3_WATER,Vector3(0,0.07,0))
    _box("RiverC",Vector3(2.38,0.020,2.85),Vector3(1.08,0.080,2.80),V3_WATER,Vector3(0,-0.10,0))
    for i in range(7):
        var z_glint := -3.1 + float(i) * 1.05
        _box("WaterGlintV3_%d" % i,Vector3(2.60+float(i%2)*0.16,0.070,z_glint),Vector3(0.55,0.018,0.055),V3_WATER_LIGHT,Vector3(0,0.08 if i%2==0 else -0.08,0))
    for i in range(11):
        var z_rock := -3.5 + float(i) * 0.72
        _rock(Vector3(1.95+float(i%2)*0.08,0.11,z_rock),0.16+float(i%3)*0.035)
        if i % 2 == 0:
            _rock(Vector3(3.20,0.10,z_rock+0.25),0.13+float(i%3)*0.03)

    _build_bridge()

    # Footpaths visually connect the loop instead of reading as UI arrows.
    _box("PathMain",Vector3(-0.45,0.035,0.90),Vector3(7.75,0.085,1.02),V3_PATH,Vector3(0,-0.10,0))
    _box("PathNorth",Vector3(-0.40,0.038,-1.38),Vector3(1.05,0.088,3.95),V3_PATH,Vector3(0,0.12,0))
    _box("PathSouth",Vector3(0.22,0.040,2.62),Vector3(1.00,0.09,3.35),V3_PATH,Vector3(0,-0.48,0))

    # Rustic borders and small landscape details.
    for i in range(8):
        _rock(Vector3(-5.15+float(i)*0.47,0.10,3.94+float(i%2)*0.05),0.14+float(i%3)*0.025)
    for i in range(7):
        _flower_cluster(Vector3(-5.20+float(i)*1.52,0.08,4.35-float(i%2)*0.25),i)
    _spring_tree(Vector3(-5.45,0.04,3.15),0.82,true)
    _spring_tree(Vector3(4.95,0.04,3.35),0.78,true)

func _build_facilities() -> void:
    facility_nodes.clear()
    ready_markers.clear()
    facility_nodes["coop"] = _build_coop(FACILITY_POS["coop"])
    facility_nodes["compost"] = _build_compost(FACILITY_POS["compost"])
    facility_nodes["mushroom"] = _build_mushroom(FACILITY_POS["mushroom"])
    facility_nodes["bee"] = _build_bees(FACILITY_POS["bee"])

    for id in FACILITY_POS:
        var marker := _sphere("Ready_%s" % id,FACILITY_POS[id]+Vector3(0,1.56,0),0.135,Color("#f0c85a"))
        ready_markers[id] = marker

func _build_coop(pos: Vector3) -> Node3D:
    var root := Node3D.new()
    root.name = "Coop"
    root.position = pos
    world_root.add_child(root)

    _box_child(root,Vector3(0,0.48,0),Vector3(1.68,0.90,1.30),Color("#b67b50"))
    _box_child(root,Vector3(0,0.50,0.66),Vector3(0.48,0.56,0.09),V3_WOOD_DARK)
    _box_child(root,Vector3(-0.62,0.52,0.66),Vector3(0.26,0.28,0.08),Color("#d9c597"))
    _box_child(root,Vector3(0.62,0.52,0.66),Vector3(0.26,0.28,0.08),Color("#d9c597"))
    _box_child(root,Vector3(-0.46,1.02,0),Vector3(1.02,0.16,1.52),V3_ROOF_RED,Vector3(0,0,deg_to_rad(20)))
    _box_child(root,Vector3(0.46,1.02,0),Vector3(1.02,0.16,1.52),V3_ROOF_RED,Vector3(0,0,deg_to_rad(-20)))
    _box_child(root,Vector3(0,0.12,0.82),Vector3(1.95,0.10,0.72),Color("#c49b63"))

    # Pen fence and chickens.
    for x in [-0.95,0.95]:
        _box_child(root,Vector3(x,0.32,0.97),Vector3(0.08,0.64,1.25),V3_WOOD_DARK)
    _box_child(root,Vector3(0,0.34,1.55),Vector3(1.95,0.08,0.08),V3_WOOD_DARK)
    for i in range(3):
        var chicken := Node3D.new()
        chicken.position = Vector3(-0.58+float(i)*0.55,0.22,1.10+float(i%2)*0.28)
        root.add_child(chicken)
        _sphere_child(chicken,Vector3.ZERO,0.14,Color("#f7f0df"))
        _sphere_child(chicken,Vector3(0,0.15,0.09),0.09,Color("#fff9ea"))
        _cone_child(chicken,Vector3(0.03,0.16,0.20),0.045,0.10,Color("#dba64e"))
        ambient_nodes.append(chicken)
    return root

func _build_compost(pos: Vector3) -> Node3D:
    var root := Node3D.new()
    root.name = "Compost"
    root.position = pos
    world_root.add_child(root)

    # Open timber compost shed with visible rich soil pile.
    for x in [-0.72,0.72]:
        for z in [-0.52,0.52]:
            _box_child(root,Vector3(x,0.60,z),Vector3(0.10,1.20,0.10),V3_WOOD_DARK)
    _box_child(root,Vector3(0,1.18,0),Vector3(1.78,0.16,1.35),V3_ROOF_DARK,Vector3(0,0,deg_to_rad(-4)))
    _box_child(root,Vector3(0,0.25,0.35),Vector3(1.48,0.50,0.14),V3_WOOD)
    _box_child(root,Vector3(-0.67,0.27,0),Vector3(0.12,0.54,0.95),V3_WOOD)
    _box_child(root,Vector3(0.67,0.27,0),Vector3(0.12,0.54,0.95),V3_WOOD)
    for i in range(7):
        var x := -0.45+float(i%4)*0.28
        var z := -0.22+float(i/4)*0.28
        var pile := _sphere_child(root,Vector3(x,0.24+float(i%2)*0.07,z),0.23,V3_SOIL)
        pile.scale = Vector3(1.25,0.72,1.05)
    _box_child(root,Vector3(0.92,0.38,0.25),Vector3(0.06,0.72,0.06),Color("#8c7c62"),Vector3(0,0,deg_to_rad(-17)))
    return root

func _build_mushroom(pos: Vector3) -> Node3D:
    var root := Node3D.new()
    root.name = "MushroomLogs"
    root.position = pos
    world_root.add_child(root)

    _box_child(root,Vector3(0,-0.01,0),Vector3(2.10,0.08,1.40),Color("#70865b"))
    for i in range(4):
        var log := _cylinder_child(root,Vector3(0,0.24+float(i)*0.18,-0.38+float(i)*0.22),0.21,1.62,V3_WOOD,12)
        log.rotation_degrees.z = 90
        for j in range(2):
            var stem_x := -0.45+float(j)*0.84
            _cylinder_child(root,Vector3(stem_x,0.43+float(i)*0.16,-0.35+float(i)*0.22),0.035,0.15,Color("#eee1c9"),8)
            var cap := _sphere_child(root,Vector3(stem_x,0.53+float(i)*0.16,-0.35+float(i)*0.22),0.13,Color("#b87f5d"))
            cap.scale = Vector3(1.15,0.55,1.15)
    _box_child(root,Vector3(0.92,0.38,0.45),Vector3(0.10,0.74,0.10),V3_WOOD_DARK)
    _box_child(root,Vector3(0.92,0.72,0.45),Vector3(0.48,0.26,0.08),Color("#d4c39c"))
    return root

func _build_bees(pos: Vector3) -> Node3D:
    var root := Node3D.new()
    root.name = "BeeHives"
    root.position = pos
    world_root.add_child(root)

    _box_child(root,Vector3(0,0.12,0),Vector3(1.70,0.16,0.48),V3_WOOD_DARK)
    for i in range(2):
        var x := -0.43+float(i)*0.86
        _box_child(root,Vector3(x,0.55,0),Vector3(0.58,0.82,0.60),Color("#d7a23b"))
        _box_child(root,Vector3(x,0.98,0),Vector3(0.66,0.10,0.68),Color("#8a633c"))
        _box_child(root,Vector3(x,0.49,0.31),Vector3(0.30,0.055,0.08),Color("#6c4b32"))
    for i in range(4):
        var bee := _sphere_child(root,Vector3(-0.52+float(i)*0.34,1.17+float(i%2)*0.10,0.20),0.055,Color("#e0b738"))
        ambient_nodes.append(bee)
    return root

func _build_player() -> void:
    player = Node3D.new()
    player.name = "Player"
    player.position = Vector3(0.12,0.43,3.85)
    player.scale = Vector3.ONE * 0.86
    world_root.add_child(player)
    _cylinder_child(player,Vector3(0,0.30,0),0.18,0.58,Color("#315d4a"),10)
    _sphere_child(player,Vector3(0,0.70,0),0.19,Color("#e0ad82"))
    _cylinder_child(player,Vector3(0,0.89,0),0.35,0.08,Color("#9b6a35"),12)
    _cone_child(player,Vector3(0,0.97,0),0.26,0.22,Color("#bd8241"))

func _rebuild_restore_patch() -> void:
    if world_root == null:
        return
    if restore_root != null and is_instance_valid(restore_root):
        restore_root.queue_free()
    restore_root = Node3D.new()
    restore_root.name = "RestorePatch"
    restore_root.position = FACILITY_POS["sansai"]
    world_root.add_child(restore_root)

    var soil_color := V3_DRY_SOIL
    if restoration_stage == 1:
        soil_color = Color("#76593f")
    elif restoration_stage >= 2:
        soil_color = Color("#514d34")
    _box_child(restore_root,Vector3(0,0.075,0),Vector3(2.95,0.15,2.00),soil_color,Vector3(0,-0.08,0))

    # Low stone edge makes the restoration patch read as an authored place.
    for i in range(7):
        _rock_child(restore_root,Vector3(-1.30+float(i)*0.43,0.17,0.92+float(i%2)*0.03),0.12+float(i%3)*0.018)

    var plant_count := 2
    if restoration_stage == 1:
        plant_count = 8
    elif restoration_stage >= 2:
        plant_count = 16
    for i in range(plant_count):
        var row := i / 4
        var col := i % 4
        var x := -1.03+float(col)*0.64+float(row%2)*0.12
        var z := -0.60+float(row)*0.42
        var stem_h := 0.17+float(i%3)*0.045
        _cylinder_child(restore_root,Vector3(x,0.15+stem_h*0.5,z),0.025,stem_h,Color("#456f40"),7)
        var leaf_a := _sphere_child(restore_root,Vector3(x-0.08,0.24+stem_h,z),0.105,V3_LEAF_LIGHT)
        leaf_a.scale = Vector3(1.25,0.72,0.85)
        var leaf_b := _sphere_child(restore_root,Vector3(x+0.09,0.28+stem_h,z+0.02),0.11,V3_LEAF)
        leaf_b.scale = Vector3(1.22,0.70,0.88)

    if restoration_stage == 0:
        for i in range(4):
            _rock_child(restore_root,Vector3(-0.95+float(i)*0.60,0.14,-0.15+float(i%2)*0.48),0.11)
    elif restoration_stage == 1:
        for i in range(4):
            _flower_child(restore_root,Vector3(-0.98+float(i)*0.58,0.17,0.58-float(i%2)*0.18),i)
    else:
        for i in range(9):
            _flower_child(restore_root,Vector3(-1.04+float(i%5)*0.48,0.18,0.64-float(i/5)*0.36),i)
        for i in range(4):
            var life := _sphere_child(restore_root,Vector3(-0.88+float(i)*0.54,0.67+float(i%2)*0.08,0.30-float(i%3)*0.18),0.040,Color("#efd35c"))
            ambient_nodes.append(life)

    facility_nodes["sansai"] = restore_root

func _mountain(pos: Vector3, radius: float, height: float, body: Color, snow_ratio: float) -> void:
    _cone("MountainBodyV3",pos,radius,height,body)
    var snow_height := height * snow_ratio * 0.33
    var snow_y := pos.y + height * 0.5 - snow_height * 0.52
    _cone("MountainSnowV3",Vector3(pos.x,snow_y,pos.z),radius*0.34,snow_height,Color("#f5f8f4"))

func _spring_tree(pos: Vector3, scale_value: float, blossom: bool) -> void:
    var root := Node3D.new()
    root.position = pos
    root.scale = Vector3.ONE * scale_value
    world_root.add_child(root)
    _cylinder_child(root,Vector3(0,0.40,0),0.095,0.80,V3_WOOD_DARK,8)
    var crown := V3_SAKURA if blossom else V3_LEAF
    var crown_light := V3_SAKURA_LIGHT if blossom else V3_LEAF_LIGHT
    _sphere_child(root,Vector3(0,0.98,0),0.43,crown)
    _sphere_child(root,Vector3(-0.25,0.88,0.08),0.30,crown_light)
    _sphere_child(root,Vector3(0.24,0.84,-0.06),0.28,crown.lightened(0.04))
    _sphere_child(root,Vector3(0.08,1.24,0.03),0.25,crown_light)

func _build_bridge() -> void:
    var root := Node3D.new()
    root.name = "StreamBridge"
    root.position = Vector3(2.55,0.16,1.44)
    world_root.add_child(root)
    for i in range(5):
        _box_child(root,Vector3(-0.72+float(i)*0.36,0,0),Vector3(0.30,0.10,0.80),Color("#a9784f"))
    _box_child(root,Vector3(0,0.12,-0.42),Vector3(1.85,0.08,0.08),V3_WOOD_DARK)
    _box_child(root,Vector3(0,0.12,0.42),Vector3(1.85,0.08,0.08),V3_WOOD_DARK)

func _rock(pos: Vector3, radius: float) -> void:
    var rock := _sphere("StoneV3",pos,radius,V3_STONE)
    rock.scale = Vector3(1.35,0.70,1.0)

func _rock_child(parent: Node3D, pos: Vector3, radius: float) -> void:
    var rock := _sphere_child(parent,pos,radius,V3_STONE)
    rock.scale = Vector3(1.30,0.68,1.0)

func _flower_cluster(pos: Vector3, seed_value: int) -> void:
    var root := Node3D.new()
    root.position = pos
    world_root.add_child(root)
    for i in range(3):
        _cylinder_child(root,Vector3(-0.10+float(i)*0.10,0.09,0.02*float(i%2)),0.012,0.18,Color("#547d47"),6)
        _sphere_child(root,Vector3(-0.10+float(i)*0.10,0.20,0.02*float(i%2)),0.045,V3_FLOWER if (seed_value+i)%2==0 else V3_SAKURA_LIGHT)

func _flower_child(parent: Node3D, pos: Vector3, seed_value: int) -> void:
    _cylinder_child(parent,pos+Vector3(0,0.07,0),0.012,0.14,Color("#4e7544"),6)
    _sphere_child(parent,pos+Vector3(0,0.16,0),0.045,V3_FLOWER if seed_value%2==0 else V3_SAKURA_LIGHT)

func _material(color: Color) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.roughness = 0.76
    return material
