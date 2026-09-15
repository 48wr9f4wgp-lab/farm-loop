class_name FarmDioramaV5
extends "res://scripts/ui/farm_diorama_v4.gd"

# Visual Pass 3: push the approved diorama toward a believable, authored
# satoyama instead of a collection of primitives. Gameplay, Save and FTUE
# behavior remain unchanged.

func _build_world() -> void:
    visual_pass = 3
    visual_target_id = "satoyama-premium-2026-09-15-v3"
    super._build_world()

    # Final exposure correction for iPhone WebGL. V4 fixed the state-sync
    # regression; V5 deliberately lowers the overall luminance so wood, soil,
    # water and foliage keep their local contrast on-device.
    if sun != null:
        sun.light_energy = 0.54
    if world_root != null:
        var env_node := world_root.get_node_or_null("PremiumEnvironment") as WorldEnvironment
        if env_node != null and env_node.environment != null:
            env_node.environment.background_color = Color("#abc8cf")
            env_node.environment.ambient_light_color = Color("#c4cec0")
            env_node.environment.ambient_light_energy = 0.24
        var fill := world_root.get_node_or_null("CoolFillLight") as DirectionalLight3D
        if fill != null:
            fill.light_energy = 0.055
        var marker := Node3D.new()
        marker.name = "VisualPass3Marker"
        world_root.add_child(marker)

func _sync_visual_state() -> void:
    super._sync_visual_state()
    if sun != null:
        sun.light_energy = 0.42 if weather in ["雪","雨"] else 0.54

    if world_root == null:
        return
    var ground := world_root.get_node_or_null("Ground") as MeshInstance3D
    if ground != null:
        var ground_color := Color("#668451")
        if season == "summer":
            ground_color = Color("#587a47")
        elif season == "autumn":
            ground_color = Color("#776744")
        elif season == "winter":
            ground_color = Color("#a9bbb6")
        ground.material_override = _material(ground_color)

func _build_landscape() -> void:
    super._build_landscape()

    # Give the stream a darker, readable bank so it remains a landscape
    # feature instead of disappearing into the bright paths.
    _box("RiverBankWest",Vector3(1.92,0.025,0.10),Vector3(0.20,0.10,7.20),Color("#536f4b"),Vector3(0,-0.02,0))
    _box("RiverBankEast",Vector3(3.27,0.025,0.10),Vector3(0.20,0.10,7.15),Color("#536f4b"),Vector3(0,0.02,0))

    # Terraced patches and edge planting create mid-scale forms between the
    # buildings and tiny vegetation. This is essential at phone scale.
    _box("FieldTerraceA",Vector3(-4.28,0.055,-2.25),Vector3(2.35,0.11,1.05),Color("#789257"),Vector3(0,-0.05,0))
    _box("FieldTerraceB",Vector3(-4.15,0.060,-1.12),Vector3(2.00,0.12,0.78),Color("#8aa063"),Vector3(0,0.04,0))
    _box("MeadowPatch",Vector3(-0.40,0.055,3.92),Vector3(3.25,0.10,0.86),Color("#6d8b55"),Vector3(0,-0.08,0))

    var groundcover := [
        Vector3(-5.55,0.07,-0.45), Vector3(-5.10,0.07,0.60),
        Vector3(-4.55,0.07,1.32), Vector3(-3.65,0.07,-3.20),
        Vector3(-2.75,0.07,3.55), Vector3(-1.85,0.07,3.78),
        Vector3(-0.82,0.07,-3.52), Vector3(0.18,0.07,-3.42),
        Vector3(1.05,0.07,-2.52), Vector3(3.72,0.07,-2.10),
        Vector3(4.28,0.07,-0.05), Vector3(4.48,0.07,1.10),
        Vector3(4.92,0.07,2.30), Vector3(3.72,0.07,3.64)
    ]
    for i in range(groundcover.size()):
        _groundcover_cluster(groundcover[i],i)

func _build_coop(pos: Vector3) -> Node3D:
    var root := super._build_coop(pos)
    if root == null:
        return root

    # Deeper eaves, framed doorway, feed bin and small roof ridge make the
    # coop read as a real rural building rather than a colored block.
    _box_child(root,Vector3(0,1.14,0.02),Vector3(0.16,0.10,1.62),Color("#6d4934"))
    _box_child(root,Vector3(-0.30,0.56,0.715),Vector3(0.07,0.64,0.08),Color("#5f402e"))
    _box_child(root,Vector3(0.30,0.56,0.715),Vector3(0.07,0.64,0.08),Color("#5f402e"))
    _box_child(root,Vector3(0,0.88,0.715),Vector3(0.67,0.07,0.08),Color("#5f402e"))
    _box_child(root,Vector3(0.88,0.24,0.88),Vector3(0.36,0.44,0.40),Color("#8f6845"))
    _box_child(root,Vector3(0.88,0.49,0.88),Vector3(0.42,0.07,0.46),Color("#59402e"))
    return root

func _build_compost(pos: Vector3) -> Node3D:
    var root := super._build_compost(pos)
    if root == null:
        return root

    # Timber slats and stacked material visually explain the function without
    # needing extra UI text.
    for i in range(4):
        _box_child(root,Vector3(-0.48+float(i)*0.32,0.42,0.43),Vector3(0.10,0.54,0.08),Color("#735039"))
    _box_child(root,Vector3(-0.95,0.17,-0.26),Vector3(0.40,0.25,0.50),Color("#806044"))
    _sphere_child(root,Vector3(-0.95,0.36,-0.26),0.22,Color("#544331"))
    _box_child(root,Vector3(0.98,0.42,0.20),Vector3(0.055,0.92,0.055),Color("#5a4636"),Vector3(0,0,deg_to_rad(-12)))
    return root

func _build_mushroom(pos: Vector3) -> Node3D:
    var root := super._build_mushroom(pos)
    if root == null:
        return root

    # A lightweight shade frame gives the log bed a distinct silhouette.
    for x in [-0.88,0.88]:
        _box_child(root,Vector3(x,0.72,0),Vector3(0.08,1.22,0.08),Color("#5b4433"))
    _box_child(root,Vector3(0,1.25,0),Vector3(2.12,0.08,1.50),Color("#6d6750"),Vector3(0,0,deg_to_rad(-4)))
    return root

func _build_bees(pos: Vector3) -> Node3D:
    var root := super._build_bees(pos)
    if root == null:
        return root

    # Slight roof overhang and support posts reduce the toy-block look.
    for x in [-0.43,0.43]:
        _box_child(root,Vector3(x,1.05,0),Vector3(0.76,0.09,0.78),Color("#6a5137"))
    _box_child(root,Vector3(-0.72,0.28,0),Vector3(0.08,0.58,0.08),Color("#5b4432"))
    _box_child(root,Vector3(0.72,0.28,0),Vector3(0.08,0.58,0.08),Color("#5b4432"))
    for i in range(5):
        _flower_child(root,Vector3(-0.80+float(i)*0.38,0.08,0.58+float(i%2)*0.10),i)
    return root

func _rebuild_restore_patch() -> void:
    super._rebuild_restore_patch()
    if restore_root == null or not is_instance_valid(restore_root):
        return

    # The restoration patch is the product's emotional core. Frame it with a
    # readable natural edge and scale the abundance much more visibly between
    # damaged / recovering / thriving states.
    _box_child(restore_root,Vector3(0,0.10,-1.00),Vector3(2.95,0.08,0.10),Color("#665341"))
    _box_child(restore_root,Vector3(-1.47,0.10,0),Vector3(0.10,0.08,1.95),Color("#665341"))

    var extra_count := 0
    if restoration_stage == 1:
        extra_count = 5
    elif restoration_stage >= 2:
        extra_count = 12

    for i in range(extra_count):
        var col := i % 6
        var row := i / 6
        var px := -1.15 + float(col) * 0.44
        var pz := -0.72 + float(row) * 0.36
        _herb_cluster_child(restore_root,Vector3(px,0.14,pz),i)

    if restoration_stage >= 2:
        for i in range(5):
            _flower_child(restore_root,Vector3(-1.08+float(i)*0.52,0.18,-0.08+float(i%2)*0.30),i+7)

func _groundcover_cluster(pos: Vector3, seed_value: int) -> void:
    var root := Node3D.new()
    root.position = pos
    world_root.add_child(root)
    var base := Color("#426d42")
    var light := Color("#628c50")
    _sphere_child(root,Vector3(-0.12,0.16,0.02),0.16,base)
    _sphere_child(root,Vector3(0.10,0.18,-0.03),0.15,light)
    _sphere_child(root,Vector3(0.0,0.26,0.04),0.13,light.darkened(0.05))
    if seed_value % 3 == 0:
        _sphere_child(root,Vector3(0.03,0.34,0.03),0.035,Color("#dbc49e"))

func _herb_cluster_child(parent: Node3D, pos: Vector3, seed_value: int) -> void:
    for i in range(3):
        var ox := -0.08 + float(i)*0.08
        var stem_h := 0.12 + float((seed_value+i)%3)*0.025
        _cylinder_child(parent,pos+Vector3(ox,stem_h*0.5,0.02*float(i%2)),0.015,stem_h,Color("#466e3f"),6)
        var leaf := _sphere_child(parent,pos+Vector3(ox-0.02,stem_h+0.05,0),0.075,Color("#5d8a4d"))
        leaf.scale = Vector3(1.25,0.60,0.82)

func _material(color: Color) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    # Stronger value compression than V4. The approved concept is warm, but
    # the phone build still clipped pale surfaces; this preserves local color.
    material.albedo_color = color.darkened(0.135)
    material.roughness = 0.98
    material.metallic = 0.0
    return material
