class_name FarmDioramaV12
extends "res://scripts/ui/farm_diorama_v11.gd"

# Visual Pass 10: premium satoyama detail without changing framing or rules.
# Keep the proven portrait-safe camera and guided input lock, while reducing
# primitive-model feel through authored rural details, restoration contrast,
# stream life and restrained ambient motion.

var premium_motion_nodes: Array[Node3D] = []
var premium_time: float = 0.0

func _build_world() -> void:
    super._build_world()
    visual_pass = 10
    visual_target_id = "satoyama-premium-2026-09-15-v10"
    if world_root == null:
        return
    world_root.name = "SatoyamaDioramaV12"

    var layer := Node3D.new()
    layer.name = "PremiumDetailLayerV12"
    world_root.add_child(layer)

    _upgrade_coop_detail()
    _upgrade_compost_detail()
    _upgrade_mushroom_detail()
    _upgrade_bee_detail()
    _add_stream_detail(layer)
    _add_rural_ground_detail(layer)

func _process(delta: float) -> void:
    super._process(delta)
    if reduced_motion:
        return
    premium_time += delta
    for i in range(premium_motion_nodes.size()):
        var node := premium_motion_nodes[i]
        if not is_instance_valid(node):
            continue
        var base_pos = node.get_meta("premium_base_pos",node.position)
        var phase := float(node.get_meta("premium_phase",float(i)))
        var kind := str(node.get_meta("premium_kind","glint"))
        if kind == "glint":
            node.position = base_pos + Vector3(sin(premium_time*1.15+phase)*0.07,0.0,0.0)
        else:
            node.position = base_pos + Vector3(
                sin(premium_time*0.82+phase)*0.035,
                sin(premium_time*1.28+phase)*0.035,
                cos(premium_time*0.73+phase)*0.025
            )

func _upgrade_coop_detail() -> void:
    var root = facility_nodes.get("coop",null)
    if not (root is Node3D) or not is_instance_valid(root):
        return
    if root.get_node_or_null("PremiumCoopV12") != null:
        return
    var detail := Node3D.new()
    detail.name = "PremiumCoopV12"
    root.add_child(detail)

    # Stronger roof silhouette, timber trim and lived-in yard details.
    _box_child(detail,Vector3(0,1.12,-0.02),Vector3(1.82,0.075,0.09),Color("#51382d"))
    _box_child(detail,Vector3(-0.72,0.50,0.67),Vector3(0.075,0.86,0.075),Color("#684532"))
    _box_child(detail,Vector3(0.72,0.50,0.67),Vector3(0.075,0.86,0.075),Color("#684532"))
    _box_child(detail,Vector3(0,0.91,0.67),Vector3(1.48,0.07,0.07),Color("#684532"))
    _box_child(detail,Vector3(0,0.18,1.48),Vector3(0.76,0.18,0.28),Color("#8d663d"))
    _box_child(detail,Vector3(0,0.31,1.48),Vector3(0.62,0.08,0.22),Color("#c7a466"))
    for i in range(3):
        _cylinder_child(detail,Vector3(-0.50+float(i)*0.50,0.16,1.72),0.13,0.18,Color("#c49a55"),8)

func _upgrade_compost_detail() -> void:
    var root = facility_nodes.get("compost",null)
    if not (root is Node3D) or not is_instance_valid(root):
        return
    if root.get_node_or_null("PremiumCompostV12") != null:
        return
    var detail := Node3D.new()
    detail.name = "PremiumCompostV12"
    root.add_child(detail)

    # Split bays, cross braces and tools make the shed read as a working place.
    _box_child(detail,Vector3(-0.28,0.42,0.33),Vector3(0.055,0.70,0.08),Color("#5b402f"))
    _box_child(detail,Vector3(0.28,0.42,0.33),Vector3(0.055,0.70,0.08),Color("#5b402f"))
    _box_child(detail,Vector3(-0.58,0.62,-0.47),Vector3(0.08,0.78,0.08),Color("#60422f"),Vector3(0,0,deg_to_rad(-28)))
    _box_child(detail,Vector3(0.58,0.62,-0.47),Vector3(0.08,0.78,0.08),Color("#60422f"),Vector3(0,0,deg_to_rad(28)))
    _cylinder_child(detail,Vector3(0.92,0.24,-0.12),0.12,0.28,Color("#9e7448"),10)
    _box_child(detail,Vector3(0.92,0.43,-0.12),Vector3(0.34,0.055,0.14),Color("#654733"))

func _upgrade_mushroom_detail() -> void:
    var root = facility_nodes.get("mushroom",null)
    if not (root is Node3D) or not is_instance_valid(root):
        return
    if root.get_node_or_null("PremiumMushroomV12") != null:
        return
    var detail := Node3D.new()
    detail.name = "PremiumMushroomV12"
    root.add_child(detail)

    # Shade rack and irregular log ends make the mushroom area less toy-like.
    for x in [-0.82,0.82]:
        _box_child(detail,Vector3(x,0.58,-0.08),Vector3(0.08,1.16,0.08),Color("#5d4432"))
    _box_child(detail,Vector3(0,1.08,-0.08),Vector3(1.92,0.10,1.36),Color("#61513f"),Vector3(0,0,deg_to_rad(-3)))
    for i in range(4):
        _sphere_child(detail,Vector3(-0.58+float(i)*0.38,0.28,0.61-float(i%2)*0.16),0.10,Color("#d7c7ac"))

func _upgrade_bee_detail() -> void:
    var root = facility_nodes.get("bee",null)
    if not (root is Node3D) or not is_instance_valid(root):
        return
    if root.get_node_or_null("PremiumBeeV12") != null:
        return
    var detail := Node3D.new()
    detail.name = "PremiumBeeV12"
    root.add_child(detail)

    _box_child(detail,Vector3(0,0.07,0),Vector3(1.85,0.12,0.60),Color("#6a4a34"))
    for i in range(3):
        var x := -0.52+float(i)*0.52
        _box_child(detail,Vector3(x,0.84,0),Vector3(0.50,0.09,0.50),Color("#6c4931"))
    for i in range(7):
        var col := i % 4
        var row := i / 4
        _flower_child(detail,Vector3(-0.80+float(col)*0.48,0.12,0.58+float(row)*0.34),i+220)

func _add_stream_detail(layer: Node3D) -> void:
    # Reeds, stepping stones and subtle water shimmer sell a living mountain stream.
    for i in range(10):
        var z := -3.05+float(i)*0.70
        var x := 1.95 if i % 2 == 0 else 3.18
        _cylinder_child(layer,Vector3(x,0.16,z),0.025,0.32,Color("#536f47"),6)
        _cylinder_child(layer,Vector3(x+0.08,0.13,z+0.05),0.022,0.26,Color("#6d874f"),6)
    for i in range(5):
        _rock(Vector3(2.18+float(i%2)*0.52,0.105,-1.75+float(i)*0.72),0.13+float(i%3)*0.02)
    for i in range(5):
        var glint := _box(
            "PremiumWaterGlintV12_%d" % i,
            Vector3(2.56+float(i%2)*0.12,0.085,-2.52+float(i)*1.18),
            Vector3(0.48,0.016,0.045),
            Color("#d3ece8"),
            Vector3(0,0.08 if i%2==0 else -0.06,0)
        )
        glint.set_meta("premium_base_pos",glint.position)
        glint.set_meta("premium_phase",float(i)*0.73)
        glint.set_meta("premium_kind","glint")
        premium_motion_nodes.append(glint)

func _add_rural_ground_detail(layer: Node3D) -> void:
    # Small authored clusters break the clean board-game surface without clutter.
    for i in range(8):
        var x := -5.45+float(i)*0.62
        var z := 3.62+float(i%3)*0.15
        _cylinder_child(layer,Vector3(x,0.13,z),0.020,0.25,Color("#4d6d44"),6)
    for i in range(6):
        _rock(Vector3(-4.90+float(i)*0.58,0.105,-2.25+float(i%2)*0.18),0.09+float(i%3)*0.018)
    _box_child(layer,Vector3(-4.28,0.20,2.72),Vector3(0.54,0.30,0.42),Color("#8a633e"))
    _box_child(layer,Vector3(-4.28,0.38,2.72),Vector3(0.62,0.055,0.48),Color("#b18a55"))

func _rebuild_restore_patch() -> void:
    super._rebuild_restore_patch()
    if restore_root == null or not is_instance_valid(restore_root):
        return

    var payoff := Node3D.new()
    payoff.name = "RestorationPayoffV12"
    restore_root.add_child(payoff)

    # Make before/after legible from a phone-sized view.
    if restoration_stage <= 0:
        for i in range(5):
            _cylinder_child(
                payoff,
                Vector3(-1.02+float(i)*0.48,0.16,0.46-float(i%2)*0.22),
                0.025,
                0.26,
                Color("#7b694c"),
                6
            )
    elif restoration_stage == 1:
        _box_child(payoff,Vector3(0,0.078,0),Vector3(3.05,0.035,2.02),Color("#556946"),Vector3(0,-0.08,0))
        for i in range(9):
            var col := i % 5
            var row := i / 5
            _herb_cluster_child(payoff,Vector3(-1.05+float(col)*0.52,0.19,-0.55+float(row)*0.74),i+260)
        for i in range(5):
            _flower_child(payoff,Vector3(-0.88+float(i)*0.44,0.23,0.72-float(i%2)*0.16),i+280)
    else:
        _box_child(payoff,Vector3(0,0.080,0),Vector3(3.10,0.038,2.06),Color("#3f633f"),Vector3(0,-0.08,0))
        for i in range(16):
            var col := i % 6
            var row := i / 6
            _herb_cluster_child(payoff,Vector3(-1.22+float(col)*0.48,0.20,-0.62+float(row)*0.52),i+300)
        for i in range(10):
            _flower_child(payoff,Vector3(-1.02+float(i%5)*0.50,0.24,0.75-float(i/5)*0.38),i+340)
        for i in range(4):
            var life := _sphere_child(
                payoff,
                Vector3(-0.80+float(i)*0.52,0.68+float(i%2)*0.08,0.18-float(i%3)*0.16),
                0.040,
                Color("#e0c957")
            )
            life.set_meta("premium_base_pos",life.position)
            life.set_meta("premium_phase",float(i)*1.1)
            life.set_meta("premium_kind","life")
            premium_motion_nodes.append(life)

    facility_nodes["sansai"] = restore_root
