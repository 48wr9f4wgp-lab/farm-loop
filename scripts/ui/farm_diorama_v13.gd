class_name FarmDioramaV13
extends "res://scripts/ui/farm_diorama_v12.gd"

# Visual Pass 11: guided-target clarity without changing safe framing.
# Early FTUE targets use a restrained world-space bracket, so the visible cue,
# allowed input and objective all point to the same facility.

func _build_world() -> void:
    super._build_world()
    visual_pass = 11
    visual_target_id = "satoyama-premium-2026-09-15-v11"
    if world_root == null:
        return
    world_root.name = "SatoyamaDioramaV13"
    var marker := Node3D.new()
    marker.name = "GuidedTargetClarityV13"
    world_root.add_child(marker)
    _ensure_guided_facility_focus()

func _sync_visual_state() -> void:
    super._sync_visual_state()
    _ensure_guided_facility_focus()

func _ensure_guided_facility_focus() -> void:
    if guided_focus.is_empty() or guided_focus == "sansai":
        return
    var target = facility_nodes.get(guided_focus,null)
    if not (target is Node3D) or not is_instance_valid(target):
        return
    if target.get_node_or_null("GuidedFacilityFocusV13") != null:
        return

    var focus := Node3D.new()
    focus.name = "GuidedFacilityFocusV13"
    target.add_child(focus)

    var focus_color := Color("#c6d28a")
    var x := 0.90
    var z := 0.70
    var y := 0.105
    var long_size := 0.38
    var thin := 0.045
    for sx in [-1.0,1.0]:
        for sz in [-1.0,1.0]:
            _box_child(focus,Vector3(sx*(x-long_size*0.5),y,sz*z),Vector3(long_size,0.030,thin),focus_color)
            _box_child(focus,Vector3(sx*x,y,sz*(z-long_size*0.5)),Vector3(thin,0.030,long_size),focus_color)

    var guide := _sphere_child(focus,Vector3(0,1.46,0),0.075,Color("#dbe3a7"))
    guide.scale = Vector3(1.0,0.72,1.0)
