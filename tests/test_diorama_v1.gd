extends SceneTree

const DioramaClass = preload("res://scripts/ui/farm_diorama_v15.gd")

var failures: int = 0

func _ok(condition: bool, message: String) -> void:
    if condition:
        print("PASS: ",message)
    else:
        failures += 1
        printerr("FAIL: ",message)

func _init() -> void:
    # Keep the previous renderer contract isolated from the new gameplay layer.
    var diorama = DioramaClass.new()
    diorama.custom_minimum_size = Vector2(390,480)
    diorama.set_state("spring","晴れ",{"coop":true,"compost":true,"sansai":true,"bee":true,"mushroom":true},"sansai",false)
    diorama.set_guided_focus("sansai")
    diorama.set_restoration_stage(1)
    root.add_child(diorama)
    await process_frame
    await process_frame

    _ok(bool(diorama.get("is_3d_diorama")),"farm renderer identifies as 3D diorama")
    _ok(int(diorama.get("visual_pass")) == 13,"renderer retains practical visual pass 13")
    _ok(str(diorama.get("visual_target_id")) == "satoyama-practical-final-2026-09-16-v1","renderer retains practical visual target")
    var camera = diorama.get("camera")
    _ok(camera is Camera3D and camera.projection == Camera3D.PROJECTION_ORTHOGONAL,"diorama remains orthographic")
    if camera is Camera3D:
        _ok(camera.size >= 12.4,"legacy guided framing remains portrait safe")

    var world_root = diorama.get("world_root")
    _ok(world_root != null and world_root.name == "SatoyamaDioramaV15","V15 visual world remains intact")
    _ok(world_root != null and world_root.get_node_or_null("PracticalFinalVisualTargetV15") != null,"practical visual marker remains active")
    _ok(world_root != null and world_root.get_node_or_null("PracticalLandscapeLayerV15") != null,"practical landscape layer remains active")

    var restore_root = diorama.get("restore_root")
    _ok(restore_root != null and restore_root.get_node_or_null("PracticalRestoreTargetV15") != null,"phone-readable restoration target remains intact")
    var practical_restore = restore_root.get_node_or_null("PracticalRestoreTargetV15") if restore_root != null else null
    if practical_restore != null:
        var rosette_count := 0
        for child in practical_restore.get_children():
            if str(child.name).begins_with("SansaiRosetteV15_"):
                rosette_count += 1
        _ok(rosette_count >= 7,"recovering patch keeps readable sansai rosettes")

    diorama.queue_free()
    await process_frame

    # Current runtime must preserve the same visual target while replacing the
    # old facility-CTA interaction with ecological zone selection.
    var packed := load("res://main.tscn") as PackedScene
    _ok(packed != null,"current V4 main scene loads")
    if packed == null:
        quit(1)
        return

    var scene = packed.instantiate()
    root.add_child(scene)
    await process_frame
    await process_frame

    var viewport_width: float = scene.get_viewport_rect().size.x
    var root_box = scene.get("root_box") as Control
    var money_chip = scene.get("money_chip") as Control
    var season_chip = scene.get("season_chip") as Control
    if root_box != null:
        var root_rect := root_box.get_global_rect()
        _ok(root_rect.position.x >= 10.0,"HUD keeps left portrait gutter")
        _ok(root_rect.end.x <= viewport_width - 20.0,"HUD keeps deliberate right portrait gutter")
    if money_chip != null:
        var money_rect := money_chip.get_global_rect()
        _ok(money_rect.end.x <= viewport_width - 20.0,"legacy money chip cannot clip if still present in shell")
    if season_chip != null:
        var season_rect := season_chip.get_global_rect()
        _ok(season_rect.end.x <= viewport_width - 88.0,"season row keeps physical-edge reservation")

    var farm_map = scene.get("map")
    _ok(farm_map != null and str(farm_map.get_script().resource_path).ends_with("circulation_board_v4.gd"),"current farm uses ecological board V4")
    if farm_map != null:
        _ok(int(farm_map.get("visual_pass")) == 13,"V4 board retains visual pass 13")
        _ok(str(farm_map.get("visual_target_id")) == "satoyama-practical-final-2026-09-16-v1","V4 board retains canonical visual target")
        var v4_world = farm_map.get("world_root")
        _ok(v4_world != null and v4_world.name == "CirculationBoardV4World","V4 board owns explicit interaction world identity")
        _ok(v4_world != null and v4_world.get_node_or_null("V4SelectedZoneFocus") != null,"V4 board has zone focus treatment")
        var v4_camera = farm_map.get("camera")
        if v4_camera is Camera3D:
            var zone_events: Array = []
            farm_map.zone_selected.connect(func(id): zone_events.append(id))
            var sansai_tap := InputEventMouseButton.new()
            sansai_tap.button_index = MOUSE_BUTTON_LEFT
            sansai_tap.pressed = true
            sansai_tap.position = v4_camera.unproject_position(farm_map.zone_world_position("sansai") + Vector3(0,0.2,0))
            farm_map._gui_input(sansai_tap)
            _ok(zone_events.size() == 1 and str(zone_events[0]) == "sansai","V4 board maps portrait tap to sansai zone")
            _ok(str(farm_map.get("selected_zone")) == "sansai","V4 world keeps selected zone state")

    print("3D VISUAL + V4 BOARD CONTRACT COMPLETE failures=",failures)
    scene.queue_free()
    await process_frame
    quit(1 if failures > 0 else 0)
