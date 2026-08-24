extends SceneTree

const SfxClass = preload("res://scripts/audio/sfx_player.gd")

var failures: int = 0

func _ok(condition: bool, message: String) -> void:
    if condition:
        print("PASS: ",message)
    else:
        failures += 1
        printerr("FAIL: ",message)

func _init() -> void:
    var sfx = SfxClass.new()
    root.add_child(sfx)
    await process_frame
    _ok(sfx.players.size() >= 2,"SFX supports overlapping feedback voices")
    for kind in ["collect","work","sell","mission","major","hazard"]:
        sfx.play_kind(kind,4)
        var voice: AudioStreamPlayer = sfx.players[(sfx.voice_index-1+sfx.players.size())%sfx.players.size()]
        _ok(voice.stream is AudioStreamWAV,"SFX stream builds for " + kind)
        if voice.stream is AudioStreamWAV:
            _ok((voice.stream as AudioStreamWAV).data.size() > 1000,"SFX has meaningful sample data for " + kind)
    sfx.queue_free()

    var packed := load("res://main.tscn") as PackedScene
    _ok(packed != null,"current main scene loads for polish contract")
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
    _ok(map_value != null,"farm map exists for feedback")
    if map_value != null and map_value.has_method("play_action_feedback"):
        map_value.call("play_action_feedback","coop")
        _ok(str(map_value.get("action_facility")) == "coop","facility action has immediate visual target state")
        _ok(float(map_value.get("action_timer")) > 0.0,"facility action feedback has nonzero duration")
    else:
        _ok(false,"farm exposes facility action feedback")

    scene.call("_show_tab","work")
    await process_frame
    var content = scene.get("content")
    _ok(content != null,"tab content exists after transition")
    await create_timer(0.20).timeout
    if content is CanvasItem:
        _ok(content.modulate.a > 0.95,"tab transition resolves to fully readable content")

    print("MOTION AND AUDIO PRODUCT CONTRACT TESTS COMPLETE failures=",failures)
    scene.queue_free()
    quit(1 if failures > 0 else 0)
