extends SceneTree

const DioramaClass = preload("res://scripts/ui/farm_diorama_v3.gd")

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
    diorama.custom_minimum_size = Vector2(390,470)
    diorama.set_state("spring","晴れ",{"coop":true,"sansai":true},"coop",false)
    diorama.set_restoration_stage(1)
    root.add_child(diorama)
    await process_frame
    await process_frame

    _ok(bool(diorama.get("is_3d_diorama")),"farm renderer identifies as 3D diorama")
    _ok(diorama.get("viewport_3d") is SubViewport,"3D diorama owns a SubViewport")
    var camera = diorama.get("camera")
    _ok(camera is Camera3D,"3D diorama owns a Camera3D")
    if camera is Camera3D:
        _ok(camera.projection == Camera3D.PROJECTION_ORTHOGONAL,"diorama uses orthographic camera")
        _ok(camera.size <= 11.5,"V3 camera gives the diorama stronger visual authority")
    var facilities: Dictionary = diorama.get("facility_nodes")
    _ok(facilities.has("coop") and facilities.has("compost") and facilities.has("sansai") and facilities.has("mushroom") and facilities.has("bee"),"all identity facilities exist in 3D")
    _ok(int(diorama.get("restoration_stage")) == 1,"restoration stage is represented by diorama")
    var world_root = diorama.get("world_root")
    _ok(world_root != null and world_root.get_node_or_null("IslandBase") != null,"V3 has a floating miniature base")
    _ok(world_root != null and world_root.get_node_or_null("StreamBridge") != null,"V3 has a stream bridge landmark")
    _ok(world_root != null and world_root.get_node_or_null("BackTerrace") != null,"V3 has layered satoyama terrain")
    diorama.play_action_feedback("coop")
    _ok(str(diorama.get("action_facility")) == "coop","3D action feedback targets selected facility")
    _ok(float(diorama.get("action_timer")) > 0.0,"3D action feedback starts immediately")
    diorama.queue_free()
    await process_frame

    var packed := load("res://main.tscn") as PackedScene
    _ok(packed != null,"current main scene loads for month-gate contract")
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

    var farm_map = scene.get("map")
    _ok(farm_map != null and bool(farm_map.get("is_3d_diorama")),"runtime farm screen uses 3D diorama renderer")
    if farm_map != null:
        _ok(str(farm_map.get_script().resource_path).ends_with("farm_diorama_v3.gd"),"runtime uses approved visual-target diorama v3")

    print("3D DIORAMA V3 VISUAL CONTRACT COMPLETE failures=",failures)
    scene.queue_free()
    quit(1 if failures > 0 else 0)
