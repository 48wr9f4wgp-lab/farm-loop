extends "res://scripts/ui/main.gd"

const SfxClass = preload("res://scripts/audio/sfx_player.gd")

var sfx

func _ready() -> void:
    super._ready()
    sfx = SfxClass.new()
    add_child(sfx)
    sfx.set_enabled(bool(state["settings"].get("sound",true)))
    _refresh_v041_shell()

func _ensure_v03_fields() -> void:
    super._ensure_v03_fields()
    if not state["settings"].has("sound"):
        state["settings"]["sound"] = true
    if not state.has("tutorial_step"):
        state["tutorial_step"] = 0
    state["version"] = "godot-0.4.1-mobile"

func _refresh_v041_shell() -> void:
    if root_box != null and root_box.get_child_count() > 0:
        var head = root_box.get_child(0)
        if head is HBoxContainer and head.get_child_count() > 1:
            var tag = head.get_child(1)
            if tag is Label:
                tag.text = "GODOT 0.4.1"
    if nav_buttons.has("farm"):
        nav_buttons["farm"].text = "農場"
    if nav_buttons.has("work"):
        nav_buttons["work"].text = "仕事"
    if nav_buttons.has("market"):
        nav_buttons["market"].text = "販売"
    if nav_buttons.has("village"):
        nav_buttons["village"].text = "村"

func _next_objective() -> String:
    var step := int(state.get("tutorial_step",0))
    match step:
        0:
            return "はじめての循環 1/6｜鶏舎をタップして、卵と鶏糞を回収"
        1:
            return "はじめての循環 2/6｜堆肥舎で鶏糞＋落ち葉を仕込む"
        2:
            return "はじめての循環 3/6｜今月を終えて、堆肥を発酵させる"
        3:
            return "はじめての循環 4/6｜完成堆肥を山菜区画へ還元"
        4:
            return "はじめての循環 5/6｜旬の山菜を収穫する"
        5:
            return "はじめての循環 6/6｜販売タブから収穫物を出荷"
        _:
            return super._next_objective()

func _build_village() -> void:
    super._build_village()
    var audio := _section("サウンド")
    audio.add_child(_button("効果音：%s" % ("ON" if bool(state["settings"].get("sound",true)) else "OFF"),_toggle_sound))

func _commit(result: Dictionary, return_tab: String, facility: String = "") -> void:
    var ok := bool(result.get("ok",false))
    var kind := str(result.get("feedback","work"))
    var tier := int(result.get("tier",1))
    var previous_step := int(state.get("tutorial_step",0))
    if ok:
        _advance_tutorial(kind,facility)
    super._commit(result,return_tab,facility)
    if ok and sfx != null:
        sfx.play_kind(kind,tier)
    if ok and feedback != null and kind in ["collect","loop","sell","mission","upgrade","major"]:
        feedback.fly_tokens(kind,5 if tier < 3 else 8)
    if ok and previous_step < 6 and int(state.get("tutorial_step",0)) >= 6 and feedback != null:
        feedback.pop("循環の基本を習得",4)
        if sfx != null:
            sfx.play_kind("major",4)

func _advance_tutorial(kind: String, facility: String) -> void:
    var step := int(state.get("tutorial_step",0))
    if step == 0 and facility == "coop" and kind == "collect":
        state["tutorial_step"] = 1
    elif step == 1 and facility == "compost" and kind == "work":
        state["tutorial_step"] = 2
    elif step == 2 and kind in ["month","hazard"] and int(state["inventory"].get("compost",0)) > 0:
        state["tutorial_step"] = 3
    elif step == 3 and kind == "loop":
        state["tutorial_step"] = 4
    elif step == 4 and facility == "sansai" and kind == "collect":
        state["tutorial_step"] = 5
    elif step == 5 and kind == "sell":
        state["tutorial_step"] = 6

func _on_next_month() -> void:
    var old_season: String = str(rules.season_key(int(state["month"])))
    var result: Dictionary = rules.next_month(state)
    var new_season: String = str(rules.season_key(int(state["month"])))
    _commit(result,"farm")
    if old_season != new_season and feedback != null:
        feedback.season_transition(rules.season_name(int(state["month"])))
        if sfx != null:
            sfx.play_kind("season",4)

func _toggle_sound() -> void:
    state["settings"]["sound"] = not bool(state["settings"].get("sound",true))
    if sfx != null:
        sfx.set_enabled(bool(state["settings"]["sound"]))
        if bool(state["settings"]["sound"]):
            sfx.play_kind("collect",1)
    save_service.save(state)
    _show_tab("village")
