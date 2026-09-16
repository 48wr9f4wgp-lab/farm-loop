extends SceneTree

var failures: int = 0

func _ok(condition: bool, message: String) -> void:
    if condition:
        print("PASS: ",message)
    else:
        failures += 1
        printerr("FAIL: ",message)

func _has_text(root_node: Node, target: String) -> bool:
    if root_node is Label and target in str(root_node.text):
        return true
    if root_node is Button and target in str(root_node.text):
        return true
    for child in root_node.get_children():
        if _has_text(child,target):
            return true
    return false

func _find_named(root_node: Node, target: String) -> Node:
    if str(root_node.name) == target:
        return root_node
    for child in root_node.get_children():
        var found := _find_named(child,target)
        if found != null:
            return found
    return null

func _find_button(root_node: Node, target: String) -> Button:
    if root_node is Button and target in str(root_node.text):
        return root_node
    for child in root_node.get_children():
        var found := _find_button(child,target)
        if found != null:
            return found
    return null

func _init() -> void:
    var packed := load("res://main.tscn") as PackedScene
    _ok(packed != null,"current main scene loads")
    if packed == null:
        quit(1)
        return

    var scene = packed.instantiate()
    _ok(scene != null,"current main scene instantiates")
    if scene == null:
        quit(1)
        return
    root.add_child(scene)
    await process_frame
    await process_frame

    var root_box = scene.get("root_box")
    _ok(root_box != null,"product shell exists")
    if root_box != null and root_box.get_child_count() > 2:
        var secondary = root_box.get_child(2)
        _ok(not secondary.visible,"legacy secondary metric row remains suppressed")

    _ok(_has_text(scene,"YUKISATO"),"brand metadata visible")
    _ok(_has_text(scene,"最初にどこから手を入れる"),"first screen asks for a player decision instead of prescribing a chore")
    _ok(_has_text(scene,"手入れ 3 / 3"),"monthly three-action budget is immediately visible")
    _ok(_has_text(scene,"里山回復"),"land recovery remains the primary progression signal")
    _ok(not _has_text(scene,"はじめての再生"),"old V3 step-by-step tutorial banner is absent from current product UI")
    _ok(not _has_text(scene,"卵と鶏糞を回収"),"old prescribed first chore is absent from current product UI")

    var map = scene.get("map")
    _ok(map != null,"V4 ecological board exists")
    if map != null:
        _ok(float(map.custom_minimum_size.y) >= 430.0,"3D world remains the dominant hero")
        _ok(str(map.get_script().resource_path).ends_with("circulation_board_v5.gd"),"current product UI is driven by M5 zone selection")

    var runtime_state: Dictionary = scene.get("state")
    _ok(runtime_state.has("circulation_v4"),"runtime uses circulation V4 state")
    _ok(int(runtime_state.get("schema_version",0)) == 5,"current product UI is backed by schema v5")

    var nav_buttons: Dictionary = scene.get("nav_buttons")
    if nav_buttons.has("work"):
        _ok(not bool(nav_buttons["work"].visible),"legacy work tab is hidden from V4 proof navigation")
    if nav_buttons.has("market"):
        _ok(not bool(nav_buttons["market"].visible),"legacy market tab is hidden from V4 proof navigation")
    if nav_buttons.has("village"):
        _ok(not bool(nav_buttons["village"].visible),"legacy village tab is hidden from V4 proof navigation")
    if nav_buttons.has("farm"):
        _ok(bool(nav_buttons["farm"].visible) and str(nav_buttons["farm"].text) == "里山","primary navigation is the satoyama board")
    if nav_buttons.has("settings"):
        _ok(bool(nav_buttons["settings"].visible),"settings remains reachable")

    _ok(_find_named(scene,"V4InterventionTray") == null,"no management card competes with the world before selection")
    if map != null and map.get("camera") is Camera3D:
        var camera: Camera3D = map.get("camera")
        var tap := InputEventMouseButton.new()
        tap.button_index = MOUSE_BUTTON_LEFT
        tap.pressed = true
        tap.position = camera.unproject_position(map.zone_world_position("stream") + Vector3(0,0.2,0))
        map._gui_input(tap)
        await process_frame
        await process_frame
        _ok(_find_named(scene,"V4InterventionTray") != null,"world tap opens contextual management only after a choice")
        _ok(_has_text(scene,"選択中｜沢"),"context tray identifies the selected land zone")
        _ok(_has_text(scene,"沢を整える"),"selected stream exposes its valid intervention")
        _ok(not _has_text(scene,"堆肥を入れる"),"stream tray does not show unrelated intervention")

        var stream_action := _find_button(scene,"沢を整える")
        if stream_action != null:
            stream_action.emit_signal("pressed")
            await process_frame
            await process_frame
            var preview_map = scene.get("map")
            _ok(_find_named(scene,"V4PreviewCard") != null,"intervention choice enters preview state before commit")
            _ok(preview_map != null and int(preview_map.get("chain_preview_edge_count")) >= 2,"M5 preview draws multiple ecological connections in-world")
            _ok(preview_map != null and int(preview_map.get("chain_preview_target_count")) >= 2,"M5 preview marks predicted receiving zones")

    print("CURRENT PRODUCT UI V4 M5 CONTRACT COMPLETE failures=",failures)
    scene.queue_free()
    await process_frame
    quit(1 if failures > 0 else 0)
