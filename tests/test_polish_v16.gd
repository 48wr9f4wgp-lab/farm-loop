extends SceneTree

const SfxClass = preload("res://scripts/audio/sfx_player.gd")

var failures: int = 0

func _ok(condition: bool, message: String) -> void:
    if condition:
        print("PASS: ",message)
    else:
        failures += 1
        printerr("FAIL: ",message)

func _find_script(root_node: Node, suffix: String) -> Node:
    if root_node.get_script() != null and str(root_node.get_script().resource_path).ends_with(suffix):
        return root_node
    for child in root_node.get_children():
        var found := _find_script(child,suffix)
        if found != null: return found
    return null

func _init() -> void:
    var sfx = SfxClass.new()
    root.add_child(sfx)
    await process_frame
    _ok(sfx.players.size() == 3,"SFX uses polyphonic voice pool")
    for kind in ["collect","work","sell","mission","major","hazard"]:
        sfx.play_kind(kind,4)
        var voice: AudioStreamPlayer = sfx.players[(sfx.voice_index-1+sfx.players.size())%sfx.players.size()]
        _ok(voice.stream is AudioStreamWAV,"SFX stream builds for " + kind)
        if voice.stream is AudioStreamWAV:
            _ok((voice.stream as AudioStreamWAV).data.size() > 1000,"SFX has meaningful sample data for " + kind)
    sfx.queue_free()

    var packed := load("res://main.tscn") as PackedScene
    _ok(packed != null,"v1.6 main scene loads")
    if packed == null:
        quit(1)
        return
    var scene = packed.instantiate()
    root.add_child(scene)
    await process_frame
    await process_frame
    scene.call("_show_tab","farm")
    await process_frame
    await process_frame

    var map_value = scene.get("map")
    var action_fx := _find_script(map_value,"facility_action_overlay_v16.gd") if map_value != null else null
    _ok(action_fx != null,"facility-specific motion layer is attached")
    if action_fx is Control:
        _ok(action_fx.mouse_filter == Control.MOUSE_FILTER_IGNORE,"motion layer never steals farm touches")

    scene.call("_show_tab","work")
    await process_frame
    var content = scene.get("content")
    _ok(content != null,"tab content exists after transition")

    print("V1.6 POLISH TESTS COMPLETE failures=",failures)
    scene.queue_free()
    quit(1 if failures > 0 else 0)
