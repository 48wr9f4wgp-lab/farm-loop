extends SceneTree

var failures := 0

func _ok(condition: bool, message: String) -> void:
    if condition:
        print("PASS: ",message)
    else:
        failures += 1
        printerr("FAIL: ",message)

func _find_button(node: Node, text_part: String) -> Button:
    if node is Button and text_part in str(node.text):
        return node
    for child in node.get_children():
        var found := _find_button(child,text_part)
        if found != null:
            return found
    return null

func _find_named(node: Node, target_name: String) -> Node:
    if str(node.name) == target_name:
        return node
    for child in node.get_children():
        var found := _find_named(child,target_name)
        if found != null:
            return found
    return null

func _tap_zone(map_value, zone_id: String) -> void:
    if map_value == null or not (map_value.get("camera") is Camera3D):
        return
    var camera: Camera3D = map_value.get("camera")
    var tap := InputEventMouseButton.new()
    tap.button_index = MOUSE_BUTTON_LEFT
    tap.pressed = true
    tap.position = camera.unproject_position(map_value.zone_world_position(zone_id) + Vector3(0,0.2,0))
    map_value._gui_input(tap)

func _cleanup() -> void:
    for path in [
        "user://farm_loop_save.json",
        "user://farm_loop_save.backup.json",
        "user://farm_loop_save.tmp.json"
    ]:
        if FileAccess.file_exists(path):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

func _init() -> void:
    _cleanup()
    var packed := load("res://main.tscn") as PackedScene
    _ok(packed != null,"V4 main scene loads")
    if packed == null:
        quit(1)
        return

    var scene = packed.instantiate()
    root.add_child(scene)
    await process_frame
    await process_frame

    _ok(str(scene.get_script().resource_path).ends_with("main_v32.gd"),"V4 M5 runtime is active")
    var state: Dictionary = scene.get("state")
    var board: Dictionary = state.get("circulation_v4",{})
    _ok(int(board.get("action_points",0)) == 3,"fresh V4 UI starts at 3 AP")

    var farm_map = scene.get("map")
    _ok(farm_map != null and str(farm_map.get_script().resource_path).ends_with("circulation_board_v5.gd"),"farm screen renders CirculationBoardV5")
    _ok(_find_named(scene,"V4RecoveryLabel") != null,"compact recovery summary is visible")
    _ok(_find_named(scene,"V4ActionPointsLabel") != null,"compact AP summary is visible")
    _ok(_find_named(scene,"V4InterventionTray") == null,"context tray stays hidden before zone selection")

    if farm_map != null:
        _ok(farm_map.get("camera") is Camera3D,"V4 board has camera for authored zone picking")
        _tap_zone(farm_map,"sansai")
        await process_frame
        await process_frame

    _ok(_find_named(scene,"V4InterventionTray") != null,"tapping a zone opens contextual intervention tray")
    var compost := _find_button(scene,"堆肥を入れる")
    _ok(compost != null,"sansai tray exposes compost intervention")
    _ok(_find_button(scene,"沢を整える") == null,"sansai tray does not expose invalid stream intervention")

    if compost != null:
        compost.emit_signal("pressed")
        await process_frame
        await process_frame

    board = state.get("circulation_v4",{})
    _ok(int(board.get("action_points",0)) == 3,"preview does not spend AP")
    _ok(_find_named(scene,"V4PreviewCard") != null,"intervention choice opens preview before commit")
    _ok(_find_named(scene,"V4PreviewText") != null,"preview explains direct and connected effects")
    var commit := _find_button(scene,"これで手入れする")
    _ok(commit != null,"preview exposes explicit commit action")
    _ok(_find_button(scene,"別の手入れを見る") != null,"preview can be cancelled easily")

    if commit != null:
        commit.emit_signal("pressed")
        await process_frame
        await process_frame

    board = state.get("circulation_v4",{})
    _ok(int(board.get("action_points",0)) == 2,"committing one intervention spends exactly 1 AP")
    _ok(board.get("pending_actions",[]).size() == 1,"committed intervention is retained for month resolution")
    _ok(int(board.get("zones",{}).get("sansai",{}).get("soil",0)) == 1,"committed compost changes only direct soil state immediately")
    _ok(_find_button(scene,"今月を終える") != null,"month-end answer button appears after a committed choice")

    var current_map = scene.get("map")
    if current_map != null:
        _tap_zone(current_map,"stream")
        await process_frame
        await process_frame

    var stream_action := _find_button(scene,"沢を整える")
    _ok(stream_action != null,"stream selection exposes restore-stream intervention")
    if stream_action != null:
        stream_action.emit_signal("pressed")
        await process_frame
        await process_frame

    board = state.get("circulation_v4",{})
    _ok(int(board.get("action_points",0)) == 2,"M5 chain preview still does not spend AP")
    var preview_map = scene.get("map")
    _ok(preview_map != null and int(preview_map.get("chain_preview_edge_count")) >= 2,"M5 shows at least two predicted ecological connections in 3D")
    _ok(preview_map != null and int(preview_map.get("chain_preview_target_count")) >= 2,"M5 highlights multiple receiving zones")
    if preview_map != null:
        var world_root = preview_map.get("world_root")
        _ok(world_root != null and world_root.get_node_or_null("V4M5ChainPreviewLayer") != null,"M5 preview layer exists in the 3D world")
        _ok(preview_map.get("chain_preview_pulse_nodes").size() >= 4,"M5 preview uses phone-readable pulse nodes")

    print("CIRCULATION UI V4 M3-M5 COMPLETE failures=",failures)
    scene.queue_free()
    await process_frame
    _cleanup()
    quit(1 if failures > 0 else 0)
