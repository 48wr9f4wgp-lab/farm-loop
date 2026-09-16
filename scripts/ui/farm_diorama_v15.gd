class_name FarmDioramaV15
extends "res://scripts/ui/farm_diorama_v14.gd"

# Visual Pass 13: practical final-target pass.
# Goal: a lightweight premium satoyama miniature that is achievable in the
# current Godot/WebGL stack. Do not chase generated concept-art density.
# Improve phone-scale readability through mid-scale landscape structure,
# stronger material separation, facility silhouettes and a clear restore payoff.

func _build_world() -> void:
    super._build_world()
    visual_pass = 13
    visual_target_id = "satoyama-practical-final-2026-09-16-v1"
    if world_root == null:
        return

    world_root.name = "SatoyamaDioramaV15"
    var marker := Node3D.new()
    marker.name = "PracticalFinalVisualTargetV15"
    world_root.add_child(marker)

    _apply_practical_lighting()

    var landscape := Node3D.new()
    landscape.name = "PracticalLandscapeLayerV15"
    world_root.add_child(landscape)
    _add_stream_banks(landscape)
    _add_path_edges(landscape)
    _add_backdrop_conifers(landscape)
    _add_meadow_details(landscape)
    _add_contact_foundations(landscape)
    _add_facility_silhouette_details()

func _sync_visual_state() -> void:
    super._sync_visual_state()
    _apply_practical_lighting()

func _apply_practical_lighting() -> void:
    if world_root == null:
        return

    if sun != null:
        sun.light_color = Color("#f1d3a9")
        sun.light_energy = 0.43 if weather in ["雪","雨"] else 0.55
        sun.shadow_enabled = true
        sun.rotation_degrees = Vector3(-49,-39,0)

    var env_node := world_root.get_node_or_null("PremiumEnvironment") as WorldEnvironment
    if env_node != null and env_node.environment != null:
        var sky := Color("#abc8cf")
        var ambient := Color("#c6cfc1")
        if season == "winter":
            sky = Color("#b8c9cc")
            ambient = Color("#c7d0cd")
        elif season == "autumn":
            sky = Color("#b7c4bd")
            ambient = Color("#d0c7ae")
        if weather in ["雪","雨"]:
            sky = sky.darkened(0.08)
            ambient = ambient.darkened(0.06)
        env_node.environment.background_color = sky
        env_node.environment.ambient_light_color = ambient
        env_node.environment.ambient_light_energy = 0.22

    var fill := world_root.get_node_or_null("CoolFillLight") as DirectionalLight3D
    if fill != null:
        fill.light_color = Color("#b5cbca")
        fill.light_energy = 0.060

func _add_stream_banks(layer: Node3D) -> void:
    # The stream is one of the game's strongest satoyama identity cues.
    # Give it a readable wet edge and bright center line without expensive
    # water shaders or post-processing.
    _box_child(layer,Vector3(1.98,0.067,0.35),Vector3(0.26,0.045,7.40),Color("#486a50"),Vector3(0,-0.02,0))
    _box_child(layer,Vector3(3.18,0.067,0.35),Vector3(0.24,0.045,7.36),Color("#496b52"),Vector3(0,0.02,0))
    _box_child(layer,Vector3(2.59,0.091,0.22),Vector3(0.52,0.018,6.72),Color("#78b8bf"),Vector3(0,-0.10,0))

    for i in range(7):
        var z := -2.58 + float(i) * 0.88
        var side := -1.0 if i % 2 == 0 else 1.0
        _rock(Vector3(2.58 + side * 0.47,0.12,z),0.09 + float(i % 3) * 0.018)

    for i in range(5):
        var z2 := -2.18 + float(i) * 1.24
        var reed_x := 2.08 if i % 2 == 0 else 3.08
        for j in range(3):
            _cylinder_child(
                layer,
                Vector3(reed_x + float(j) * 0.055,0.15 + float(j) * 0.025,z2 + float(j) * 0.045),
                0.014,
                0.30 + float(j) * 0.05,
                Color("#526f49"),
                5
            )

func _add_path_edges(layer: Node3D) -> void:
    # Mid-scale path edging makes the farm feel authored rather than printed on
    # a board. Keep it sparse so the route stays readable at phone size.
    for i in range(9):
        var x := -4.25 + float(i) * 0.72
        if i % 2 == 0:
            _rock(Vector3(x,0.105,0.22),0.075 + float(i % 3) * 0.012)
    for i in range(6):
        var z := 0.80 + float(i) * 0.52
        _cylinder_child(layer,Vector3(-0.08,0.12,z),0.012,0.22,Color("#496744"),5)
        if i % 2 == 0:
            _sphere_child(layer,Vector3(-0.13,0.20,z+0.03),0.055,Color("#648650"))

func _add_backdrop_conifers(layer: Node3D) -> void:
    # A few strong conifer silhouettes sell snow-country much more efficiently
    # than adding dozens of tiny props.
    var points := [
        Vector3(-4.70,0.04,-3.66), Vector3(-2.95,0.04,-3.82),
        Vector3(-1.35,0.04,-3.76), Vector3(0.72,0.04,-3.75),
        Vector3(2.88,0.04,-3.46), Vector3(4.48,0.04,-2.82)
    ]
    for i in range(points.size()):
        _conifer_child(layer,points[i],0.72 + float(i % 3) * 0.10,i)

func _conifer_child(parent: Node3D, pos: Vector3, scale_value: float, seed_value: int) -> void:
    var tree := Node3D.new()
    tree.position = pos
    tree.scale = Vector3.ONE * scale_value
    tree.name = "ConiferV15_%d" % seed_value
    parent.add_child(tree)
    _cylinder_child(tree,Vector3(0,0.34,0),0.075,0.68,Color("#554334"),7)
    var dark := Color("#355a43")
    var mid := Color("#416c4b")
    if season == "winter":
        dark = Color("#49645a")
        mid = Color("#5d7569")
    _cone_child(tree,Vector3(0,0.70,0),0.43,0.72,dark)
    _cone_child(tree,Vector3(0,1.02,0),0.34,0.64,mid)
    _cone_child(tree,Vector3(0,1.30,0),0.25,0.54,dark.lightened(0.03))
    if season == "winter":
        _cone_child(tree,Vector3(0,1.43,0),0.16,0.18,Color("#d8e1de"))

func _add_meadow_details(layer: Node3D) -> void:
    # Sparse meadow islands remove the remaining flat-green-board feeling.
    var patches := [
        Vector3(-5.25,0.08,2.65), Vector3(-4.52,0.08,3.22),
        Vector3(-2.95,0.08,-2.85), Vector3(-1.75,0.08,-3.06),
        Vector3(0.90,0.08,3.72), Vector3(3.88,0.08,3.42),
        Vector3(4.62,0.08,1.62), Vector3(4.50,0.08,-1.16)
    ]
    for i in range(patches.size()):
        var p: Vector3 = patches[i]
        _sphere_child(layer,p + Vector3(-0.10,0.09,0.02),0.11,Color("#527448"))
        _sphere_child(layer,p + Vector3(0.10,0.10,-0.02),0.10,Color("#6f8f55"))
        if season == "spring" and i % 3 == 0:
            _sphere_child(layer,p + Vector3(0.01,0.19,0.01),0.026,Color("#dfc7b4"))

func _add_contact_foundations(layer: Node3D) -> void:
    # Thin dark foundations improve contact shadows in compatibility rendering
    # without screen-space AO or expensive post effects.
    _box_child(layer,FACILITY_POS["coop"]+Vector3(0,0.045,0.04),Vector3(1.92,0.026,1.54),Color("#586347"))
    _box_child(layer,FACILITY_POS["compost"]+Vector3(0,0.043,0),Vector3(1.80,0.024,1.42),Color("#586146"))
    _box_child(layer,FACILITY_POS["mushroom"]+Vector3(0,0.041,0),Vector3(2.08,0.022,1.62),Color("#526047"))
    _box_child(layer,FACILITY_POS["bee"]+Vector3(0,0.041,0),Vector3(2.04,0.022,1.24),Color("#526448"))

func _add_facility_silhouette_details() -> void:
    var coop = facility_nodes.get("coop",null)
    if coop is Node3D and is_instance_valid(coop) and coop.get_node_or_null("PracticalSilhouetteV15") == null:
        var d := Node3D.new()
        d.name = "PracticalSilhouetteV15"
        coop.add_child(d)
        _box_child(d,Vector3(-0.48,1.33,-0.20),Vector3(0.18,0.52,0.18),Color("#5b4332"))
        _box_child(d,Vector3(-0.48,1.60,-0.20),Vector3(0.25,0.08,0.25),Color("#3e352d"))
        _box_child(d,Vector3(1.05,0.25,0.86),Vector3(0.42,0.36,0.42),Color("#89623f"))
        _box_child(d,Vector3(1.05,0.47,0.86),Vector3(0.48,0.06,0.48),Color("#5a4230"))

    var compost = facility_nodes.get("compost",null)
    if compost is Node3D and is_instance_valid(compost) and compost.get_node_or_null("PracticalSilhouetteV15") == null:
        var d2 := Node3D.new()
        d2.name = "PracticalSilhouetteV15"
        compost.add_child(d2)
        _box_child(d2,Vector3(0,1.12,-0.02),Vector3(1.82,0.075,1.42),Color("#544536"),Vector3(0,0,deg_to_rad(-2)))
        _cylinder_child(d2,Vector3(0.92,0.21,0.56),0.14,0.32,Color("#8b6744"),10)

    var mushroom = facility_nodes.get("mushroom",null)
    if mushroom is Node3D and is_instance_valid(mushroom) and mushroom.get_node_or_null("PracticalSilhouetteV15") == null:
        var d3 := Node3D.new()
        d3.name = "PracticalSilhouetteV15"
        mushroom.add_child(d3)
        _box_child(d3,Vector3(0,1.16,0),Vector3(2.18,0.08,1.54),Color("#554b3c"),Vector3(0,0,deg_to_rad(-3)))
        _box_child(d3,Vector3(0.94,0.48,0.68),Vector3(0.055,0.76,0.055),Color("#554332"))
        _box_child(d3,Vector3(0.94,0.82,0.68),Vector3(0.44,0.22,0.06),Color("#baa77e"))

    var bees = facility_nodes.get("bee",null)
    if bees is Node3D and is_instance_valid(bees) and bees.get_node_or_null("PracticalSilhouetteV15") == null:
        var d4 := Node3D.new()
        d4.name = "PracticalSilhouetteV15"
        bees.add_child(d4)
        for i in range(3):
            var x := -0.52 + float(i) * 0.52
            _box_child(d4,Vector3(x,0.38,0.225),Vector3(0.26,0.055,0.055),Color("#49382e"))
            _box_child(d4,Vector3(x,0.11,0.34),Vector3(0.42,0.05,0.22),Color("#745337"))

func _rebuild_restore_patch() -> void:
    super._rebuild_restore_patch()
    if restore_root == null or not is_instance_valid(restore_root):
        return

    var finish := Node3D.new()
    finish.name = "PracticalRestoreTargetV15"
    restore_root.add_child(finish)

    # Stage 0 must look worked but depleted. Stage 1 (the FTUE payoff) must
    # become obviously harvestable without requiring zoom or explanatory UI.
    if restoration_stage <= 0:
        for i in range(4):
            _box_child(
                finish,
                Vector3(-0.90+float(i)*0.58,0.16,-0.05),
                Vector3(0.34,0.022,1.30),
                Color("#745c44"),
                Vector3(0,-0.08,0)
            )
        return

    var living_edge := Color("#405e3f") if restoration_stage == 1 else Color("#34563a")
    _box_child(finish,Vector3(0,0.098,-1.03),Vector3(3.18,0.035,0.08),living_edge)
    _box_child(finish,Vector3(-1.55,0.098,0),Vector3(0.08,0.035,2.12),living_edge)

    var rosette_count := 7 if restoration_stage == 1 else 11
    for i in range(rosette_count):
        var col := i % 4
        var row := i / 4
        var px := -1.05 + float(col) * 0.68 + float(row % 2) * 0.10
        var pz := -0.58 + float(row) * 0.55
        _sansai_rosette(finish,Vector3(px,0.15,pz),0.84 + float(i % 3) * 0.08,i)

    var flower_count := 5 if restoration_stage == 1 else 9
    for i in range(flower_count):
        _flower_child(
            finish,
            Vector3(-1.10+float(i%5)*0.50,0.25,0.66-float(i/5)*0.36),
            700+i
        )

    facility_nodes["sansai"] = restore_root

func _sansai_rosette(parent: Node3D, pos: Vector3, scale_value: float, seed_value: int) -> void:
    var root := Node3D.new()
    root.position = pos
    root.scale = Vector3.ONE * scale_value
    root.name = "SansaiRosetteV15_%d" % seed_value
    parent.add_child(root)

    var stem_color := Color("#365d3d")
    var leaf_a := Color("#4f8249")
    var leaf_b := Color("#6c9957")
    for i in range(4):
        var angle := float(i) * TAU / 4.0 + float(seed_value % 3) * 0.18
        var dx := cos(angle) * 0.10
        var dz := sin(angle) * 0.10
        _cylinder_child(root,Vector3(dx*0.45,0.11,dz*0.45),0.014,0.22,stem_color,5)
        var leaf := _sphere_child(root,Vector3(dx,0.24,dz),0.095,leaf_a if i%2==0 else leaf_b)
        leaf.scale = Vector3(1.45,0.48,0.82)
        leaf.rotation_degrees.y = rad_to_deg(-angle)
