extends SceneTree

const DioramaClass = preload("res://scripts/ui/farm_diorama_v7.gd")

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
    _ok(int(diorama.get("visual_pass")) == 5,"runtime renderer declares visual pass 5")
    _ok(str(diorama.get("visual_target_id")) == "satoyama-premium-2026-09-15-v5","renderer is locked to visual pass 5 target")
    _ok(diorama.get("viewport_3d") is SubViewport,"3D diorama owns a SubViewport")
    var camera = diorama.get("camera")
    _ok(camera is Camera3D,"3D diorama owns a Camera3D")
    if camera is Camera3D:
        _ok(camera.projection == Camera3D.PROJECTION_ORTHOGONAL,"diorama uses orthographic camera")
        _ok(camera.size <= 10.5,"guided restoration focus moves camera closer to the hero patch")
    var facilities: Dictionary = diorama.get("facility_nodes")
    _ok(facilities.has("coop") and facilities.has("compost") and facilities.has("sansai") and facilities.has("mushroom") and facilities.has("bee"),"all identity facilities exist in 3D")
    _ok(int(diorama.get("restoration_stage")) == 1,"restoration stage is represented by diorama")
    var world_root = diorama.get("world_root")
    _ok(world_root != null and world_root.name == "SatoyamaDioramaV7","V7 world root is active")
    _ok(world_root != null and world_root.get_node_or_null("VisualPass5Marker") != null,"V7 visual pass marker is active")
    _ok(world_root != null and world_root.get_node_or_null("WetBankSouth") != null,"V7 keeps authored wet-bank detail")
    _ok(world_root != null and world_root.get_node_or_null("StreamBridge") != null,"V7 keeps the stream bridge landmark")
    var restore_root = diorama.get("restore_root")
    _ok(restore_root != null and restore_root.get_node_or_null("RestorationHeroMarker") != null,"V7 keeps restoration hero treatment")
    _ok(restore_root != null and restore_root.get_node_or_null("GuidedRestoreFocus") != null,"guided FTUE adds restrained world-space focus treatment")
    var ready_markers: Dictionary = diorama.get("ready_markers")
    if ready_markers.has("sansai"):
        _ok(bool(ready_markers["sansai"].visible),"guided restoration keeps target marker visible")
    if ready_markers.has("coop"):
        _ok(not bool(ready_markers["coop"].visible),"guided restoration suppresses unrelated ready markers")
    if ready_markers.has("bee"):
        _ok(not bool(ready_markers["bee"].visible),"guided restoration suppresses bee marker competition")
    var env_node = world_root.get_node_or_null("PremiumEnvironment") if world_root != null else null
    _ok(env_node is WorldEnvironment,"V7 keeps premium environment lighting")
    var key_light = world_root.get_node_or_null("WarmKeyLight") if world_root != null else null
    _ok(key_light is DirectionalLight3D,"V7 keeps named warm key light")
    if key_light is DirectionalLight3D:
        _ok(key_light.light_energy <= 0.55,"V7 key light preserves material color on iPhone WebGL")
    diorama.play_action_feedback("sansai")
    _ok(str(diorama.get("action_facility")) == "sansai","3D action feedback targets restoration patch")
    _ok(float(diorama.get("action_timer")) > 0.0,"3D action feedback starts immediately")
    diorama.queue_free()
    await process_frame

    var packed := load("res://main.tscn") as PackedScene
    _ok(packed != null,"current main scene loads for month / restore gate contract")
    if packed == null:
        quit(1)
        return
    var scene = packed.instantiate()
    root.add_child(scene)
    await process_frame
    await process_frame

    var state: Dictionary = scene.get("state")
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
        _ok(month_button.custom_minimum_size.y >= 50.0,"month CTA keeps mobile tap target")
        month_button.emit_signal("pressed")
        await process_frame
        await process_frame
        _ok(int(state["month"]) == 5,"month CTA advances April to May")
        _ok(int(state["ftue_v3"]["step"]) == 4,"month CTA advances Restore Loop FTUE")

    var restore_button := _find_button(scene,"完成堆肥を土へ還す")
    _ok(restore_button != null,"FTUE step 5 replaces stale facility controls with restore CTA")
    if restore_button != null:
        _ok(restore_button.custom_minimum_size.y >= 50.0,"restore CTA keeps mobile tap target")
        _ok(not restore_button.disabled,"restore CTA is actionable after compost matures")

    var focused_map = scene.get("map")
    _ok(focused_map != null and str(focused_map.get("guided_focus")) == "sansai","FTUE step 5 focuses the restoration patch in 3D")
    if focused_map != null:
        var focused_markers: Dictionary = focused_map.get("ready_markers")
        if focused_markers.has("coop"):
            _ok(not bool(focused_markers["coop"].visible),"runtime step 5 hides unrelated farm markers")
        if focused_markers.has("sansai"):
            _ok(bool(focused_markers["sansai"].visible),"runtime step 5 leaves only restoration target marker")

    if restore_button != null:
        restore_button.emit_signal("pressed")
        await process_frame
        await process_frame
        _ok(int(state["ftue_v3"]["step"]) == 5,"restore CTA advances Restore Loop FTUE")
        _ok(int(state["restoration_v3"].get("first_patch_stage",0)) >= 1,"restore CTA visibly advances land restoration")

    var farm_map = scene.get("map")
    _ok(farm_map != null and bool(farm_map.get("is_3d_diorama")),"runtime farm screen uses 3D diorama renderer")
    if farm_map != null:
        _ok(str(farm_map.get_script().resource_path).ends_with("farm_diorama_v7.gd"),"runtime uses visual-pass-5 diorama v7")

    print("3D DIORAMA V7 VISUAL CONTRACT COMPLETE failures=",failures)
    scene.queue_free()
    quit(1 if failures > 0 else 0)
