class_name FarmDioramaV10
extends "res://scripts/ui/farm_diorama_v9.gd"

# Visual Pass 8: keep the portrait-safe framing, then improve visual hierarchy.
# The camera no longer zooms to teach the player. The restoration patch wins
# attention through contrast, vegetation and authored ground treatment instead.

func _build_world() -> void:
    super._build_world()
    visual_pass = 8
    visual_target_id = "satoyama-premium-2026-09-15-v8"
    if world_root != null:
        world_root.name = "SatoyamaDioramaV10"
        var marker := Node3D.new()
        marker.name = "VisualPass8HierarchyMarker"
        world_root.add_child(marker)

func _mountain(pos: Vector3, radius: float, height: float, body: Color, snow_ratio: float) -> void:
    # Orthographic mountains stay visually large even when they are far away.
    # Reduce their silhouette and blend them toward the sky so the farm reads first.
    var mountain_radius := radius * 0.78
    var mountain_height := height * 0.72
    var background_body := body.lerp(Color("#94aaa6"),0.58).darkened(0.04)
    var mountain_pos := Vector3(pos.x,pos.y-0.18,pos.z)
    _cone("MountainBodyV10",mountain_pos,mountain_radius,mountain_height,background_body)
    var snow_height := mountain_height * snow_ratio * 0.24
    var snow_y := mountain_pos.y + mountain_height * 0.5 - snow_height * 0.54
    _cone("MountainSnowV10",Vector3(mountain_pos.x,snow_y,mountain_pos.z),mountain_radius*0.30,snow_height,Color("#d5dedb"))

func _rebuild_restore_patch() -> void:
    super._rebuild_restore_patch()
    if restore_root == null or not is_instance_valid(restore_root):
        return

    var hierarchy := Node3D.new()
    hierarchy.name = "RestorationHierarchyV10"
    restore_root.add_child(hierarchy)

    # A dark natural rim makes the plot readable at phone size without glowing UI.
    var rim := Color("#40583d")
    var x := 1.66
    var z := 1.16
    var y := 0.105
    _box_child(hierarchy,Vector3(0,y,-z),Vector3(3.38,0.045,0.065),rim)
    _box_child(hierarchy,Vector3(0,y,z),Vector3(3.38,0.045,0.065),rim)
    _box_child(hierarchy,Vector3(-x,y,0),Vector3(0.065,0.045,2.36),rim)
    _box_child(hierarchy,Vector3(x,y,0),Vector3(0.065,0.045,2.36),rim)

    # Recovery needs to feel materially richer than the damaged state.
    if restoration_stage == 1:
        for i in range(6):
            var col := i % 3
            var row := i / 3
            _herb_cluster_child(
                hierarchy,
                Vector3(-0.72+float(col)*0.72,0.17,-0.18+float(row)*0.58),
                i+80
            )
        for i in range(2):
            _flower_child(hierarchy,Vector3(-0.46+float(i)*0.92,0.22,0.72),i+90)
    elif restoration_stage >= 2:
        for i in range(10):
            var col := i % 5
            var row := i / 5
            _herb_cluster_child(
                hierarchy,
                Vector3(-1.10+float(col)*0.55,0.18,-0.22+float(row)*0.52),
                i+100
            )
        for i in range(5):
            _flower_child(hierarchy,Vector3(-0.92+float(i)*0.46,0.23,0.74-float(i%2)*0.18),i+120)

    facility_nodes["sansai"] = restore_root

func _apply_guided_focus() -> void:
    super._apply_guided_focus()
    if guided_focus != "sansai" or camera == null:
        return

    # Preserve the proven safe camera framing from V9. Emphasis now comes from
    # world treatment, not from zooming or shifting the whole farm.
    camera.size = 12.55
    camera.look_at(Vector3(0.05,0.46,0.72),Vector3.UP)
    if restore_root != null and is_instance_valid(restore_root):
        restore_root.scale = Vector3(1.10,1.0,1.10)
