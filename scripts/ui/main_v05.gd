extends "res://scripts/ui/main_v041.gd"

const RulesV05Class = preload("res://scripts/core/game_rules_v05.gd")
const GrowthOverlayClass = preload("res://scripts/ui/satoyama_growth_overlay.gd")
const UI_FONT_PATH := "res://assets/fonts/farmloop-jp.woff2"

func _ready() -> void:
    _install_ui_font()
    super._ready()
    rules = RulesV05Class.new(data)
    rules.ensure_entertainment_fields(state)
    state["version"] = "godot-0.5.1-jp-font"
    save_service.save(state)
    _refresh_v05_shell()
    _polish_mobile_shell()
    _show_tab(current_tab)

func _install_ui_font() -> void:
    if not ResourceLoader.exists(UI_FONT_PATH):
        push_warning("Japanese UI font missing; fallback font will be used")
        return
    var font = load(UI_FONT_PATH)
    if font == null or not (font is Font):
        push_warning("Japanese UI font failed to load")
        return
    var ui_theme := Theme.new()
    ui_theme.default_font = font
    ui_theme.default_font_size = 14
    theme = ui_theme

func _polish_mobile_shell() -> void:
    if status_label != null:
        status_label.add_theme_font_size_override("font_size",13)
    if objective_label != null:
        objective_label.add_theme_font_size_override("font_size",13)
    var scrolls := find_children("*","ScrollContainer",true,false)
    for node in scrolls:
        if node is ScrollContainer:
            var bar := node.get_v_scroll_bar()
            if bar != null:
                bar.modulate.a = 0.0
                bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
                bar.custom_minimum_size.x = 1.0

func _ensure_v03_fields() -> void:
    super._ensure_v03_fields()
    if not state.has("entertainment"):
        state["entertainment"] = {
            "prosperity_xp":0,
            "explores_this_month":0,
            "rare_finds":[],
            "chain_stage":0,
            "chains_completed":0,
            "best_chain":0
        }
    state["version"] = "godot-0.5.1-jp-font"

func _refresh_v05_shell() -> void:
    if root_box != null and root_box.get_child_count() > 0:
        var head = root_box.get_child(0)
        if head is HBoxContainer and head.get_child_count() > 1:
            var tag = head.get_child(1)
            if tag is Label:
                tag.text = "GODOT 0.5.1"

func _next_objective() -> String:
    if int(state.get("tutorial_step",0)) < 6:
        return super._next_objective()
    var e: Dictionary = state.get("entertainment",{})
    if int(e.get("explores_this_month",0)) < 2:
        return "遊びの目標｜山を探索して、今月のレア発見を狙おう"
    var stage: int = int(e.get("chain_stage",0))
    var labels: Array[String] = [
        "鶏舎で回収して循環チェイン開始",
        "堆肥舎で仕込み、チェインをつなぐ",
        "今月を終えて堆肥を完成させる",
        "完成堆肥を山菜区画へ還元",
        "山菜を収穫してチェイン継続",
        "販売して循環チェイン完成"
    ]
    return "循環チェイン %d/6｜%s" % [stage,labels[mini(stage,5)]]

func _build_farm() -> void:
    super._build_farm()
    if not rules.has_method("land_progress"):
        return
    rules.ensure_entertainment_fields(state)
    var progress: Dictionary = rules.land_progress(state)
    if map != null:
        var overlay = GrowthOverlayClass.new()
        overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
        overlay.set_rank(int(progress["rank"]),bool(state["settings"].get("reduced_motion",false)))
        map.add_child(overlay)

    var mountain := _section("山の探索")
    var summary := Label.new()
    summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    summary.add_theme_color_override("font_color",GREEN_DARK)
    summary.text = "里山ランク %d｜%s　成長 %d / %d\n今月の探索 %d回　珍品 %d種" % [
        progress["rank"],progress["name"],progress["current"],progress["next"],
        state["entertainment"]["explores_this_month"],state["entertainment"]["rare_finds"].size()
    ]
    mountain.add_child(summary)
    var bar := ProgressBar.new()
    bar.max_value = 100
    bar.value = int(round(float(progress["ratio"])*100.0))
    bar.show_percentage = false
    bar.custom_minimum_size = Vector2(0,12)
    mountain.add_child(bar)
    var explore_text: String = "山へ探索に行く"
    if int(state["entertainment"]["explores_this_month"]) >= 2:
        explore_text = "もう一度探索（追加探索は控えめ報酬）"
    mountain.add_child(_button(explore_text,_on_explore,true))

    var chain := _section("循環チェイン")
    var chain_stage: int = int(state["entertainment"]["chain_stage"])
    var c := Label.new()
    c.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    c.text = "現在 %d / 6　完成 %d回\n鶏 → 堆肥 → 月送り → 還元 → 山菜 → 販売" % [
        chain_stage,state["entertainment"]["chains_completed"]
    ]
    chain.add_child(c)
    var cb := ProgressBar.new()
    cb.max_value = 6
    cb.value = chain_stage
    cb.show_percentage = false
    cb.custom_minimum_size = Vector2(0,12)
    chain.add_child(cb)

func _build_village() -> void:
    super._build_village()
    if not state.has("entertainment"):
        return
    var finds := _section("雪里の珍品")
    var label := Label.new()
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    var list: Array = state["entertainment"].get("rare_finds",[])
    label.text = "まだ珍品を見つけていない。山の探索で探してみよう。" if list.is_empty() else "発見 %d種｜%s" % [list.size(),"・".join(PackedStringArray(list))]
    finds.add_child(label)

func _commit(result: Dictionary, return_tab: String, facility: String = "") -> void:
    var chain: Dictionary = {}
    var ok: bool = bool(result.get("ok",false))
    var kind: String = str(result.get("feedback","work"))
    if ok and rules.has_method("register_loop_action"):
        chain = rules.register_loop_action(state,kind,facility)
    super._commit(result,return_tab,facility)
    if not ok or chain.is_empty():
        return
    if bool(chain.get("complete",false)):
        save_service.save(state)
        if feedback != null:
            var extra: String = " + 里山ランクUP" if bool(chain.get("rank_up",false)) else ""
            feedback.pop("循環チェイン完成！ +¥%d%s" % [chain.get("bonus",0),extra],5)
            feedback.fly_tokens("major",10)
        if sfx != null:
            sfx.play_kind("major",5)
        _haptic(5)
    elif bool(chain.get("advanced",false)) and feedback != null:
        feedback.pop("循環チェイン %d/6" % chain.get("stage",0),2)

func _on_explore() -> void:
    if not rules.has_method("explore_mountain"):
        return
    _commit(rules.explore_mountain(state),"farm")
