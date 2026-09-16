extends SceneTree

const DioramaClass = preload("res://scripts/ui/farm_diorama_v15.gd")

var failures: int = 0

func _ok(condition: bool, message: String) -> void:
    if condition:
        print("PASS: ",message)
    else:
        failures += 1
        printerr("FAIL: ",message)

func _find_button(node: Node, target: String) -> Button:
    if node is Button and target in str(node.text):
        return node
    for child in node.get_children():
        var found := _find_button(child,target)
        if found != null:
            return found
    return null

func _find_label(node: Node, target: String) -> Label:
    if node is Label and target in str(node.text):
        return node
    for child in node.get_children():
        var found := _find_label(child,target)
        if found != null:
            return found
    return null

func _init() -> void:
    var diorama = DioramaClass.new()
    diorama.custom_minimum_size = Vector2(390,480)
    diorama.set_state("spring","晴れ",{"coop":true,"compost":true,"sansai":true,"bee":true,"mushroom":true},"sansai",false)
    diorama.set_guided_focus("sansai")
    diorama.set_restoration_stage(1)
    root.add_child(diorama)
    await process_frame
    await process_frame

    _ok(bool(diorama.get("is_3d_diorama")),"farm renderer identifies as 3D diorama")
    _ok(int(diorama.get("visual_pass")) == 13,"runtime renderer declares practical final visual pass 13")
    _ok(str(diorama.get("visual_target_id")) == "satoyama-practical-final-2026-09-16-v1","renderer is locked to practical final visual target")
    _ok(diorama.get("viewport_3d") is SubViewport,"3D diorama owns a SubViewport")
    var camera = diorama.get("camera")
    _ok(camera is Camera3D,"3D diorama owns a Camera3D")
    if camera is Camera3D:
        _ok(camera.projection == Camera3D.PROJECTION_ORTHOGONAL,"diorama uses orthographic camera")
        _ok(camera.size >= 12.4,"guided focus preserves hard portrait safe framing")

    var facilities: Dictionary = diorama.get("facility_nodes")
    _ok(facilities.has("coop") and facilities.has("compost") and facilities.has("sansai") and facilities.has("mushroom") and facilities.has("bee"),"all identity facilities exist in 3D")
    var world_root = diorama.get("world_root")
    _ok(world_root != null and world_root.name == "SatoyamaDioramaV15","V15 world root is active")
    _ok(world_root != null and world_root.get_node_or_null("GuidedInteractionLockMarker") != null,"guided interaction lock remains active")
    _ok(world_root != null and world_root.get_node_or_null("PremiumDetailLayerV12") != null,"premium satoyama world detail layer remains active")
    _ok(world_root != null and world_root.get_node_or_null("GuidedTargetClarityV13") != null,"guided target clarity marker remains active")
    _ok(world_root != null and world_root.get_node_or_null("AlphaReadinessVisualV14") != null,"alpha readiness visual layer remains active")
    _ok(world_root != null and world_root.get_node_or_null("PracticalFinalVisualTargetV15") != null,"practical final visual marker is active")
    _ok(world_root != null and world_root.get_node_or_null("PracticalLandscapeLayerV15") != null,"practical landscape target layer is active")

    if facilities.has("coop"):
        _ok(facilities["coop"].get_node_or_null("PremiumCoopV12") != null,"coop has premium rural detail")
        _ok(facilities["coop"].get_node_or_null("PracticalSilhouetteV15") != null,"coop has practical final silhouette detail")
    if facilities.has("compost"):
        _ok(facilities["compost"].get_node_or_null("PremiumCompostV12") != null,"compost shed has premium working detail")
        _ok(facilities["compost"].get_node_or_null("PracticalSilhouetteV15") != null,"compost shed has practical final silhouette detail")
    if facilities.has("mushroom"):
        _ok(facilities["mushroom"].get_node_or_null("PremiumMushroomV12") != null,"mushroom area has premium shade-rack detail")
        _ok(facilities["mushroom"].get_node_or_null("PracticalSilhouetteV15") != null,"mushroom area has practical final silhouette detail")
    if facilities.has("bee"):
        _ok(facilities["bee"].get_node_or_null("PremiumBeeV12") != null,"bee area has premium hive and flower detail")
        _ok(facilities["bee"].get_node_or_null("PracticalSilhouetteV15") != null,"bee area has practical final silhouette detail")

    var restore_root = diorama.get("restore_root")
    _ok(restore_root != null and restore_root.get_node_or_null("GuidedRestoreFocus") != null,"guided restoration keeps world-space focus treatment")
    _ok(restore_root != null and restore_root.get_node_or_null("RestorationHierarchyV10") != null,"restoration patch keeps authored visual hierarchy treatment")
    _ok(restore_root != null and restore_root.get_node_or_null("RestorationPayoffV12") != null,"restoration patch keeps premium before-after treatment")
    _ok(restore_root != null and restore_root.get_node_or_null("AlphaRestorationPayoffV14") != null,"restoration patch keeps alpha payoff layer")
    _ok(restore_root != null and restore_root.get_node_or_null("PracticalRestoreTargetV15") != null,"restoration patch has practical harvestable target layer")
    var practical_restore = restore_root.get_node_or_null("PracticalRestoreTargetV15") if restore_root != null else null
    if practical_restore != null:
        var rosette_count := 0
        for child in practical_restore.get_children():
            if str(child.name).begins_with("SansaiRosetteV15_"):
                rosette_count += 1
        _ok(rosette_count >= 7,"recovering patch has phone-readable sansai rosettes")

    var premium_motion_nodes: Array = diorama.get("premium_motion_nodes")
    _ok(premium_motion_nodes.size() >= 5,"premium pass includes restrained environmental motion")
    var alpha_motion_nodes: Array = diorama.get("alpha_motion_nodes")
    _ok(alpha_motion_nodes.size() >= 4,"alpha payoff includes visible returning-life motion")

    var ready_markers: Dictionary = diorama.get("ready_markers")
    if ready_markers.has("sansai"):
        _ok(bool(ready_markers["sansai"].visible),"guided restoration keeps target marker visible")
    if ready_markers.has("coop"):
        _ok(not bool(ready_markers["coop"].visible),"guided restoration suppresses unrelated ready markers")
    if ready_markers.has("bee"):
        _ok(not bool(ready_markers["bee"].visible),"guided restoration suppresses bee marker competition")

    var selected_events: Array = []
    diorama.facility_selected.connect(func(id): selected_events.append(id))
    if camera is Camera3D:
        var bee_tap := InputEventMouseButton.new()
        bee_tap.button_index = MOUSE_BUTTON_LEFT
        bee_tap.pressed = true
        bee_tap.position = camera.unproject_position(Vector3(2.25,0.55,2.65))
        diorama._gui_input(bee_tap)
        _ok(selected_events.is_empty(),"guided sansai beat ignores bee world tap")
        _ok(str(diorama.get("selected_facility")) == "sansai","guided sansai beat keeps selected facility locked to target")

    diorama.queue_free()
    await process_frame

    var packed := load("res://main.tscn") as PackedScene
    _ok(packed != null,"current main scene loads for portrait contract")
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
        _ok(root_rect.position.x >= 10.0,"HUD keeps a left portrait gutter")
        _ok(root_rect.end.x <= viewport_width - 20.0,"HUD keeps a deliberate right portrait gutter")
    if money_chip != null:
        var money_rect := money_chip.get_global_rect()
        _ok(money_rect.end.x <= viewport_width - 20.0,"money chip stays clear of the physical right edge")
        _ok(money_rect.size.x <= 72.0,"money chip cannot consume the season row")
    if season_chip != null:
        var season_rect := season_chip.get_global_rect()
        _ok(season_rect.end.x <= viewport_width - 88.0,"season label leaves reserved width for money chip")

    var state: Dictionary = scene.get("state")

    state["ftue_v3"]["step"] = 0
    state["ftue_v3"]["active"] = true
    state["ftue_v3"]["completed"] = false
    scene.call("_show_tab","farm")
    await process_frame
    await process_frame
    var early_map = scene.get("map")
    _ok(early_map != null and str(early_map.get_script().resource_path).ends_with("farm_diorama_v15.gd"),"early FTUE uses practical final diorama v15")
    if early_map != null:
        _ok(early_map.custom_minimum_size.y <= 420.0,"early guided hero stays clear of fixed bottom navigation")
        _ok(str(early_map.get("guided_focus")) == "coop","FTUE step 1 focuses the coop")
        var early_facilities: Dictionary = early_map.get("facility_nodes")
        if early_facilities.has("coop"):
            _ok(early_facilities["coop"].get_node_or_null("GuidedFacilityFocusV13") != null,"coop has explicit world-space guided focus")
    _ok(_find_label(scene,"里山の回復") == null,"early FTUE hides premature recovery status")

    state["ftue_v3"]["step"] = 3
    state["ftue_v3"]["active"] = true
    state["ftue_v3"]["completed"] = false
    state["compost_queue"] = 1
    state["inventory"]["compost"] = 0
    state["month"] = 4
    scene.call("_show_tab","farm")
    await process_frame
    await process_frame

    var month_button := _find_button(scene,"今月を終える")
    _ok(month_button != null,"FTUE step 4 exposes month CTA above the hero")
    if month_button != null:
        month_button.emit_signal("pressed")
        await process_frame
        await process_frame
        _ok(int(state["month"]) == 5,"month CTA advances April to May")
        _ok(int(state["ftue_v3"]["step"]) == 4,"month CTA advances Restore Loop FTUE")

    var restore_button := _find_button(scene,"完成堆肥を土へ還す")
    _ok(restore_button != null,"FTUE step 5 exposes focused restore CTA")
    if restore_button != null:
        _ok(not restore_button.disabled,"restore CTA is actionable after compost matures")

    var focused_map = scene.get("map")
    _ok(focused_map != null and str(focused_map.get("guided_focus")) == "sansai","FTUE step 5 focuses restoration patch")
    if focused_map != null:
        _ok(str(focused_map.get_script().resource_path).ends_with("farm_diorama_v15.gd"),"runtime uses practical final diorama v15")
        _ok(focused_map.custom_minimum_size.y <= 420.0,"guided hero remains compact in portrait")
        var runtime_camera = focused_map.get("camera")
        if runtime_camera is Camera3D:
            _ok(runtime_camera.size >= 12.4,"runtime guided camera keeps hard safe framing")

    if restore_button != null:
        restore_button.emit_signal("pressed")
        await process_frame
        await process_frame
        _ok(int(state["ftue_v3"]["step"]) == 5,"restore CTA advances Restore Loop FTUE")
        _ok(int(state["restoration_v3"].get("first_patch_stage",0)) >= 1,"restore CTA advances land restoration")
        var restored_map = scene.get("map")
        if restored_map != null:
            var restored_root = restored_map.get("restore_root")
            _ok(restored_root != null and restored_root.get_node_or_null("AlphaRestorationPayoffV14") != null,"runtime rebuild keeps alpha restoration payoff")
            _ok(restored_root != null and restored_root.get_node_or_null("PracticalRestoreTargetV15") != null,"runtime rebuild keeps practical restoration target")

    print("3D DIORAMA V15 PRACTICAL FINAL TARGET CONTRACT COMPLETE failures=",failures)
    scene.queue_free()
    quit(1 if failures > 0 else 0)
