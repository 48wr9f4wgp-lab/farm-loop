class_name FarmDioramaV7
extends "res://scripts/ui/farm_diorama_v6.gd"

# Visual Pass 5: direct the player's eye before adding more detail.
# During guided farm beats, non-target ready markers are suppressed and the
# current target receives a restrained, world-space focus treatment.

var guided_focus: String = ""

func set_guided_focus(facility_id: String) -> void:
    guided_focus = facility_id
    if world_root != null:
        _apply_guided_focus()

func _build_world() -> void:
    super._build_world()
    visual_pass = 5
    visual_target_id = "satoyama-premium-2026-09-15-v5"
    if world_root != null:
        world_root.name = "SatoyamaDioramaV7"
        var marker := Node3D.new()
        marker.name = "VisualPass5Marker"
        world_root.add_child(marker)
    _apply_guided_focus()

func _sync_visual_state() -> void:
    super._sync_visual_state()
    _apply_guided_focus()

func _rebuild_restore_patch() -> void:
    super._rebuild_restore_patch()
    if restore_root == null or not is_instance_valid(restore_root):
        return

    if guided_focus == "sansai":
        _decorate_restore_focus()
    facility_nodes["sansai"] = restore_root

func _mountain(pos: Vector3, radius: float, height: float, body: Color, snow_ratio: float) -> void:
    # Orthographic projection keeps distant objects visually large, so the
    # mountains need explicit size/contrast reduction to behave as background.
    var mountain_radius := radius * 0.88
    var mountain_height := height * 0.84
    var muted_body := body.lerp(Color("#81928c"),0.58).lightened(0.04)
    _cone("MountainBodyV7",pos,mountain_radius,mountain_height,muted_body)
    var snow_height := mountain_height * snow_ratio * 0.28
    var snow_y := pos.y + mountain_height * 0.5 - snow_height * 0.54
    _cone("MountainSnowV7",Vector3(pos.x,snow_y,pos.z),mountain_radius*0.32,snow_height,Color("#c7d0ce"))

func _apply_guided_focus() -> void:
    if world_root == null:
        return

    if guided_focus.is_empty():
        return

    # The active FTUE target should be the only floating readiness cue.
    for id in ready_markers:
        var marker = ready_markers[id]
        if marker != null and is_instance_valid(marker):
            marker.visible = id == guided_focus
            if id == guided_focus:
                marker.scale = Vector3.ONE * 0.72
                if marker is MeshInstance3D:
                    marker.material_override = _material(Color("#b7c96d"))

    # Reduce visual competition from high-saturation support facilities while
    # the restoration patch is the instructional target.
    if guided_focus == "sansai":
        var bees = facility_nodes.get("bee",null)
        if bees is Node3D and is_instance_valid(bees):
            bees.scale = Vector3.ONE * 0.88

        if camera != null:
            camera.size = 10.35
            camera.look_at(Vector3(-0.82,0.42,1.58),Vector3.UP)

        if restore_root != null and is_instance_valid(restore_root):
            restore_root.scale = Vector3(1.17,1.0,1.17)
            if restore_root.get_node_or_null("GuidedRestoreFocus") == null:
                _decorate_restore_focus()

func _decorate_restore_focus() -> void:
    if restore_root == null or not is_instance_valid(restore_root):
        return
    if restore_root.get_node_or_null("GuidedRestoreFocus") != null:
        return

    var focus := Node3D.new()
    focus.name = "GuidedRestoreFocus"
    restore_root.add_child(focus)

    # Four short corner brackets read as selection without covering plants or
    # turning the calm diorama into a flashing mobile-game target.
    var focus_color := Color("#b6c77b")
    var x := 1.58
    var z := 1.08
    var y := 0.12
    var long_size := 0.52
    var thin := 0.055

    for sx in [-1.0,1.0]:
        for sz in [-1.0,1.0]:
            _box_child(focus,Vector3(sx*(x-long_size*0.5),y,sz*z),Vector3(long_size,0.035,thin),focus_color)
            _box_child(focus,Vector3(sx*x,y,sz*(z-long_size*0.5)),Vector3(thin,0.035,long_size),focus_color)

    # A small soft marker sits above the soil, not above every facility.
    var guide := _sphere_child(focus,Vector3(0,0.72,0.02),0.085,Color("#d8df9a"))
    guide.scale = Vector3(1.0,0.72,1.0)
