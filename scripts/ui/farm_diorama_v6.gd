class_name FarmDioramaV6
extends "res://scripts/ui/farm_diorama_v5.gd"

# Visual Pass 4: make the restoration patch the clear emotional protagonist.
# Gameplay, save, FTUE progression and facility contracts remain unchanged.

func _build_world() -> void:
    super._build_world()
    visual_pass = 4
    visual_target_id = "satoyama-premium-2026-09-15-v4"
    if world_root != null:
        world_root.name = "SatoyamaDioramaV6"
        var marker := Node3D.new()
        marker.name = "VisualPass4Marker"
        world_root.add_child(marker)

func _build_landscape() -> void:
    super._build_landscape()

    # Wet banks and worn footpaths add human / ecological history to the land.
    _box("WetBankSouth",Vector3(2.55,0.045,3.62),Vector3(1.65,0.07,0.62),Color("#4e6b54"),Vector3(0,-0.08,0))
    _box("FootpathWearA",Vector3(-2.55,0.075,0.78),Vector3(2.25,0.035,0.42),Color("#ad9569"),Vector3(0,-0.10,0))
    _box("FootpathWearB",Vector3(-0.34,0.078,-1.38),Vector3(0.44,0.035,2.10),Color("#aa9368"),Vector3(0,0.12,0))

    # Small rural details keep the scene from reading as a clean model board.
    _box("FieldMarkerPost",Vector3(-4.95,0.30,-1.34),Vector3(0.07,0.60,0.07),Color("#574333"))
    _box("FieldMarkerPlate",Vector3(-4.95,0.57,-1.34),Vector3(0.46,0.24,0.07),Color("#c6b183"))
    for i in range(6):
        _rock(Vector3(-4.75+float(i)*0.34,0.11,-1.70+float(i%2)*0.08),0.10+float(i%3)*0.02)

func _mountain(pos: Vector3, radius: float, height: float, body: Color, snow_ratio: float) -> void:
    # Background mountains must support the farm rather than steal the first read.
    var muted_body := body.darkened(0.20).lerp(Color("#718087"),0.22)
    _cone("MountainBodyV6",pos,radius,height,muted_body)
    var snow_height := height * snow_ratio * 0.30
    var snow_y := pos.y + height * 0.5 - snow_height * 0.54
    _cone("MountainSnowV6",Vector3(pos.x,snow_y,pos.z),radius*0.33,snow_height,Color("#cdd8d8"))

func _rebuild_restore_patch() -> void:
    super._rebuild_restore_patch()
    if restore_root == null or not is_instance_valid(restore_root):
        return

    restore_root.scale = Vector3(1.10,1.0,1.10)

    var hero_marker := Node3D.new()
    hero_marker.name = "RestorationHeroMarker"
    restore_root.add_child(hero_marker)

    # A subtle larger underlay gives the patch a readable silhouette at phone size.
    var underlay_color := Color("#6e5b45")
    if restoration_stage == 1:
        underlay_color = Color("#5f6a45")
    elif restoration_stage >= 2:
        underlay_color = Color("#496443")
    _box_child(restore_root,Vector3(0,0.035,0),Vector3(3.35,0.07,2.36),underlay_color,Vector3(0,-0.08,0))

    # Small field sign anchors the patch as an authored place in the satoyama.
    _box_child(restore_root,Vector3(1.34,0.34,0.72),Vector3(0.055,0.66,0.055),Color("#564333"))
    _box_child(restore_root,Vector3(1.34,0.66,0.72),Vector3(0.50,0.28,0.07),Color("#c7b486"))

    if restoration_stage <= 0:
        # Damaged state: sparse, dry and visibly worked but not healthy.
        for i in range(4):
            _box_child(
                restore_root,
                Vector3(-0.90+float(i)*0.58,0.17,-0.44),
                Vector3(0.42,0.025,1.18),
                Color("#806447"),
                Vector3(0,-0.08,0)
            )
    elif restoration_stage == 1:
        # Recovering state: the payoff must be obvious immediately after compost return.
        for i in range(8):
            var col := i % 4
            var row := i / 4
            _herb_cluster_child(
                restore_root,
                Vector3(-1.02+float(col)*0.66,0.16,-0.48+float(row)*0.54),
                i+20
            )
        for i in range(4):
            _flower_child(restore_root,Vector3(-0.92+float(i)*0.58,0.20,0.56-float(i%2)*0.18),i+30)
    else:
        # Thriving state: abundance, flowers and returning small life are the visual reward.
        for i in range(14):
            var col := i % 5
            var row := i / 5
            _herb_cluster_child(
                restore_root,
                Vector3(-1.18+float(col)*0.55,0.16,-0.58+float(row)*0.42),
                i+40
            )
        for i in range(9):
            _flower_child(
                restore_root,
                Vector3(-1.08+float(i%5)*0.52,0.21,0.68-float(i/5)*0.38),
                i+50
            )
        for i in range(5):
            var life := _sphere_child(
                restore_root,
                Vector3(-0.95+float(i)*0.46,0.72+float(i%2)*0.09,0.28-float(i%3)*0.14),
                0.045,
                Color("#d9bf50")
            )
            ambient_nodes.append(life)

    facility_nodes["sansai"] = restore_root

func _material(color: Color) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = color.darkened(0.145)
    material.roughness = 0.99
    material.metallic = 0.0
    return material
