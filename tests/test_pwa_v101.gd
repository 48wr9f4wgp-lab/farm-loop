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

    var preset_text := FileAccess.get_file_as_string("res://export_presets.cfg")
    _ok("html/canvas_resize_policy=2" in preset_text,"Web canvas uses Adaptive resize policy")
    _ok("viewport-fit=cover" in preset_text,"iPhone Web shell opts into full safe-area viewport")
    _ok("width:100vw" in preset_text and "height:100vh" in preset_text,"Web canvas CSS fills viewport")

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

    _ok(root.content_scale_mode == Window.CONTENT_SCALE_MODE_CANVAS_ITEMS,"runtime scale mode is canvas items")
    _ok(root.content_scale_aspect == Window.CONTENT_SCALE_ASPECT_EXPAND,"runtime scale aspect is expand")
    _ok(root.content_scale_stretch == Window.CONTENT_SCALE_STRETCH_FRACTIONAL,"runtime allows fractional full-width scaling")

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

    for task_name in ["収穫","山を探索","販売"]:
        var row = scene.call("_daily_row",task_name,0,2)
        _ok(row is HBoxContainer,"daily notebook row builds: %s" % task_name)
        if row is HBoxContainer and row.get_child_count() >= 2:
            var label = row.get_child(0)
            var count = row.get_child(1)
            _ok(label is Label and label.has_theme_color_override("font_color") and label.get_theme_color("font_color").a > 0.9,"daily task label has explicit readable contrast: %s" % task_name)
            _ok(count is Label and count.has_theme_color_override("font_color") and count.get_theme_color("font_color").a > 0.9,"daily progress has explicit readable contrast: %s" % task_name)
        if row is Node:
            row.free()

    var map_value = scene.get("map")
    _ok(map_value is Control and map_value.custom_minimum_size.y >= 385.0,"farm map keeps product-scale visual area")

    print("V1.0.2 IPHONE PWA TESTS COMPLETE failures=",failures)
    scene.queue_free()
    quit(1 if failures > 0 else 0)
