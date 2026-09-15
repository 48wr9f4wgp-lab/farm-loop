class_name FarmDioramaV14
extends "res://scripts/ui/farm_diorama_v13.gd"

# Visual Pass 12: alpha-readiness payoff pass.
# Keep the proven portrait-safe framing and guided input lock, but make the
# restoration result unmistakable on a phone: richer growth, life returning,
# and restrained motion around the restored patch.

var alpha_motion_nodes: Array[Node3D] = []
var alpha_time: float = 0.0

func _build_world() -> void:
    super._build_world()
    visual_pass = 12
    visual_target_id = "satoyama-premium-2026-09-16-alpha-rc"
    if world_root == null:
        return
    world_root.name = "SatoyamaDioramaV14"
    var marker := Node3D.new()
    marker.name = "AlphaReadinessVisualV14"
    world_root.add_child(marker)

func _process(delta: float) -> void:
    super._process(delta)
    if reduced_motion:
        return
    alpha_time += delta
    for i in range(alpha_motion_nodes.size()):
        var node := alpha_motion_nodes[i]
        if not is_instance_valid(node):
            continue
        var base_pos: Vector3 = node.get_meta("alpha_base_pos",node.position)
        var phase := float(node.get_meta("alpha_phase",float(i)))
        var kind := str(node.get_meta("alpha_kind","life"))
        if kind == "petal":
            node.position = base_pos + Vector3(
                sin(alpha_time * 0.72 + phase) * 0.11,
                sin(alpha_time * 1.10 + phase) * 0.07,
                cos(alpha_time * 0.61 + phase) * 0.08
            )
        elif kind == "bird":
            node.position = base_pos + Vector3(
                sin(alpha_time * 0.34 + phase) * 0.20,
                sin(alpha_time * 0.55 + phase) * 0.045,
                cos(alpha_time * 0.34 + phase) * 0.12
            )
        else:
            node.position = base_pos + Vector3(0.0,sin(alpha_time * 1.25 + phase) * 0.045,0.0)

func _rebuild_restore_patch() -> void:
    super._rebuild_restore_patch()
    alpha_motion_nodes.clear()
    if restore_root == null or not is_instance_valid(restore_root):
        return

    var payoff := Node3D.new()
    payoff.name = "AlphaRestorationPayoffV14"
    restore_root.add_child(payoff)

    if restoration_stage <= 0:
        # Dry, quiet and intentionally sparse before the first compost return.
        for i in range(4):
            _rock(Vector3(-0.90 + float(i) * 0.56,0.11,0.62 - float(i % 2) * 0.32),0.10 + float(i % 2) * 0.02)
        return

    # A darker living-soil edge makes the recovered plot read clearly even at
    # phone scale without relying on UI overlays.
    _box_child(payoff,Vector3(0,0.092,0),Vector3(3.22,0.020,2.16),Color("#35553a"),Vector3(0,-0.08,0))

    if restoration_stage == 1:
        for i in range(12):
            var col := i % 6
            var row := i / 6
            _herb_cluster_child(payoff,Vector3(-1.22 + float(col) * 0.48,0.23,-0.55 + float(row) * 0.72),420 + i)
        for i in range(7):
            _flower_child(payoff,Vector3(-1.05 + float(i) * 0.35,0.27,0.72 - float(i % 2) * 0.18),460 + i)
        for i in range(4):
            var mote := _sphere_child(payoff,Vector3(-0.72 + float(i) * 0.48,0.62 + float(i % 2) * 0.08,0.08 - float(i % 3) * 0.16),0.035,Color("#d8c95b"))
            mote.set_meta("alpha_base_pos",mote.position)
            mote.set_meta("alpha_phase",float(i) * 0.9)
            mote.set_meta("alpha_kind","life")
            alpha_motion_nodes.append(mote)
        return

    # Thriving state: abundance, flowers, small insects/petals and two distant
    # bird silhouettes. This is the proof-of-fun payoff, not decorative noise.
    for i in range(22):
        var col := i % 7
        var row := i / 7
        _herb_cluster_child(payoff,Vector3(-1.35 + float(col) * 0.45,0.24,-0.68 + float(row) * 0.46),500 + i)
    for i in range(14):
        _flower_child(payoff,Vector3(-1.18 + float(i % 7) * 0.39,0.29,0.74 - float(i / 7) * 0.42),560 + i)

    for i in range(7):
        var petal := _sphere_child(payoff,Vector3(-1.00 + float(i) * 0.33,0.72 + float(i % 3) * 0.09,0.18 - float(i % 2) * 0.26),0.032,Color("#f1d7d5"))
        petal.scale = Vector3(1.25,0.55,0.90)
        petal.set_meta("alpha_base_pos",petal.position)
        petal.set_meta("alpha_phase",float(i) * 0.73)
        petal.set_meta("alpha_kind","petal")
        alpha_motion_nodes.append(petal)

    for i in range(2):
        var bird := Node3D.new()
        bird.name = "ReturningBirdV14_%d" % i
        payoff.add_child(bird)
        bird.position = Vector3(-0.55 + float(i) * 1.10,1.22,0.20 - float(i) * 0.36)
        _box_child(bird,Vector3(-0.07,0,0),Vector3(0.13,0.025,0.045),Color("#39463d"),Vector3(0,0,deg_to_rad(18)))
        _box_child(bird,Vector3(0.07,0,0),Vector3(0.13,0.025,0.045),Color("#39463d"),Vector3(0,0,deg_to_rad(-18)))
        bird.set_meta("alpha_base_pos",bird.position)
        bird.set_meta("alpha_phase",float(i) * 2.2)
        bird.set_meta("alpha_kind","bird")
        alpha_motion_nodes.append(bird)

    facility_nodes["sansai"] = restore_root
