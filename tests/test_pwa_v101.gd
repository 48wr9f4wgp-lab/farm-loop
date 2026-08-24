extends SceneTree

var failures: int = 0

func _ok(condition: bool, message: String) -> void:
    if condition:
        print("PASS: ",message)
    else:
        failures += 1
        printerr("FAIL: ",message)

func _init() -> void:
    _ok(str(ProjectSettings.get_setting("display/window/stretch/mode","")) == "canvas_items","PWA uses canvas_items stretch")
    _ok(str(ProjectSettings.get_setting("display/window/stretch/aspect","")) == "expand","PWA expands to tall/wide phones")
    _ok(int(ProjectSettings.get_setting("display/window/size/window_width_override",0)) == 0,"no fixed Web width override")
    _ok(int(ProjectSettings.get_setting("display/window/size/window_height_override",0)) == 0,"no fixed Web height override")

    var packed := load("res://main.tscn") as PackedScene
    _ok(packed != null,"PWA main scene loads")
    if packed == null:
        quit(1)
        return
    var scene := packed.instantiate()
    root.add_child(scene)
    await process_frame
    await process_frame
    scene.call("_show_tab","farm")
    await process_frame
    await process_frame

    var nav = scene.get("nav_buttons")
    var nav_ok: bool = true
    if nav is Dictionary:
        for id in nav:
            var b = nav[id]
            if not (b is Button) or b.custom_minimum_size.y < 44.0:
                nav_ok = false
    else:
        nav_ok = false
    _ok(nav_ok,"bottom navigation keeps iPhone-sized tap targets")

    var action = scene.get("selected_action_button")
    _ok(action is Button and action.custom_minimum_size.y >= 50.0,"farm primary action stays at least 50px")

    var row = scene.call("_daily_row","収穫",0,2)
    _ok(row is HBoxContainer,"daily notebook row builds")
    if row is HBoxContainer and row.get_child_count() >= 2:
        var label = row.get_child(0)
        var count = row.get_child(1)
        _ok(label is Label and label.get_theme_color("font_color") != Color.WHITE,"daily task label has explicit dark contrast")
        _ok(count is Label and count.get_theme_color("font_color") != Color.WHITE,"daily progress has explicit contrast")
    if row is Node:
        row.free()

    var map_value = scene.get("map")
    _ok(map_value is Control and map_value.custom_minimum_size.y >= 370.0,"farm map keeps product-scale visual area")

    print("V1.0.1 PWA TESTS COMPLETE failures=",failures)
    scene.queue_free()
    quit(1 if failures > 0 else 0)
