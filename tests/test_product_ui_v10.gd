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
        _ok(not secondary.visible,"secondary metric row removed from hero")

    _ok(_has_text(scene,"YUKISATO"),"brand metadata visible")
    var map = scene.get("map")
    _ok(map != null,"farm map exists")
    if map != null:
        _ok(float(map.custom_minimum_size.y) >= 380.0,"farm map remains hero sized")

    var desc = scene.get("selected_desc_label")
    _ok(desc != null and not desc.visible,"facility paragraph hidden from first screen")

    var runtime_state: Dictionary = scene.get("state")
    _ok(runtime_state.has("ftue_v3"),"runtime uses FTUE v3 state")
    _ok(runtime_state.has("restoration_v3"),"runtime has explicit restoration state")
    runtime_state["ftue_v3"]["step"] = 0
    runtime_state["ftue_v3"]["active"] = true
    runtime_state["ftue_v3"]["completed"] = false
    runtime_state["restoration_v3"]["proof_mode"] = true

    # Off-beat visits must redirect instead of exposing unrelated systems.
    scene.call("_show_tab","work")
    await process_frame
    _ok(_has_text(scene,"いまの手順"),"off-beat work tab shows focused guidance")
    _ok(_has_text(scene,"農場へ戻る"),"off-beat work tab offers direct return CTA")
    _ok(not _has_text(scene,"今日の山道を選ぶ"),"mountain route choice stays outside V3 proof")

    runtime_state["ftue_v3"]["step"] = 1
    scene.call("_show_tab","work")
    await process_frame
    _ok(_has_text(scene,"落ち葉・籾殻を集める"),"V3 material beat exposes only restoration input")
    _ok(not _has_text(scene,"沢沿い") and not _has_text(scene,"尾根"),"material beat has no mountain-route noise")

    runtime_state["ftue_v3"]["step"] = 4
    runtime_state["restoration_v3"]["first_patch_stage"] = 0
    scene.call("_show_tab","farm")
    await process_frame
    _ok(_has_text(scene,"里山の回復"),"farm surfaces restoration status")
    _ok(_has_text(scene,"荒れた山菜区画"),"damaged patch state is readable before restoration")

    scene.call("_show_tab","market")
    await process_frame
    _ok(_has_text(scene,"今は里山を蘇らせる"),"market is explicitly de-emphasized in V3 proof")
    _ok(not _has_text(scene,"売り先を選ぶ"),"channel comparison is absent from V3 proof")

    scene.call("_show_tab","village")
    await process_frame
    _ok(_has_text(scene,"いまの手順") or _has_text(scene,"今日の村"),"village visit remains non-blocking during transition to V3")

    print("CURRENT PRODUCT UI V3 CONTRACT COMPLETE failures=",failures)
    scene.queue_free()
    quit(1 if failures > 0 else 0)
