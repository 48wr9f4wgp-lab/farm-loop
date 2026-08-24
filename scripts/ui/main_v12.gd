extends "res://scripts/ui/main_v11.gd"

const RulesV12Class = preload("res://scripts/core/game_rules_v12.gd")

func _ready() -> void:
    super._ready()
    rules = RulesV12Class.new(data)
    rules.ensure_route_fields(state)
    state["version"] = "godot-1.2-route-adventure"
    save_service.save(state)
    _header()
    _show_tab(current_tab)

func _build_work() -> void:
    rules.ensure_route_fields(state)
    var entertainment: Dictionary = state["entertainment"]
    var explored: int = int(entertainment.get("explores_this_month",0))
    var strong_left: int = maxi(0,2-explored)
    var rank_info: Dictionary = rules.land_progress(state)
    var last_route: String = str(entertainment.get("last_route",""))
    var last_find: String = str(entertainment.get("last_find",""))

    var explore := _section("山へ入る")
    var headline := Label.new()
    headline.text = "今日の山道を選ぶ"
    headline.add_theme_font_size_override("font_size",18)
    headline.add_theme_color_override("font_color",GREEN_DARK)
    explore.add_child(headline)

    var status := Label.new()
    status.text = "濃い探索 残り%d回｜%s・里山ランク%d" % [strong_left,str(rank_info.get("name","雪里")),int(rank_info.get("rank",1))]
    status.add_theme_font_size_override("font_size",11)
    status.add_theme_color_override("font_color",Color("#8a621c"))
    explore.add_child(status)

    var intro := _lead_text("道ごとに見つかりやすい恵みが変わる。行動力なし。ハズレ道もなし。")
    explore.add_child(intro)

    explore.add_child(_route_button("stream","沢沿い　採集量＋｜珍品 ○",last_route == "stream"))
    explore.add_child(_route_button("beech","ブナ林　バランス｜珍品 ＋",last_route == "beech"))
    explore.add_child(_route_button("ridge","尾根　珍品 ＋＋｜収量少なめ",last_route == "ridge"))

    var recent := Label.new()
    recent.text = "まだ山の発見なし" if last_find.is_empty() else "直近の発見　%s" % last_find
    recent.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    recent.add_theme_font_size_override("font_size",11)
    recent.add_theme_color_override("font_color",MUTED)
    explore.add_child(recent)

    var field := _section("山仕事")
    field.add_child(_lead_text("拾った恵みを農場へ戻す。ここから循環が強くなる。"))
    field.add_child(_button("落ち葉・籾殻を集める",_on_gather_leaves,true,false))

    var logs_title := Label.new()
    logs_title.text = "原木を仕込む"
    logs_title.add_theme_font_size_override("font_size",12)
    logs_title.add_theme_color_override("font_color",GREEN_DARK)
    field.add_child(logs_title)

    var logs := HBoxContainer.new()
    logs.add_theme_constant_override("separation",5)
    field.add_child(logs)
    for kind in ["shiitake","nameko","hiratake"]:
        var b := _button(str(data.get_table("products")[kind]["name"]),_on_inoculate.bind(kind),false,true)
        b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        b.custom_minimum_size.y = 46
        logs.add_child(b)

    var recipes := _section("加工小屋")
    recipes.add_child(_lead_text("収穫物を商品へ。加工するほど販売の一発が大きくなる。"))
    for r in data.get_table("recipes"):
        recipes.add_child(_button("%s　¥%d" % [str(r["name"]),int(r["cost"])],_on_craft.bind(str(r["id"])),false,true))

    var growth := _section("里の成長")
    growth.add_child(_lead_text("よく使う場所から強化して、次の収穫を伸ばす。"))
    for key in data.get_table("facilities"):
        var f: Dictionary = data.get_table("facilities")[key]
        growth.add_child(_button("%s　Lv%d → 強化" % [str(f["name"]),int(state["facility_levels"][key])],_on_upgrade.bind(key),false,true))

    var safety := _section("里山整備")
    for p in data.get_table("projects"):
        var installed: bool = bool(state["projects"].get(p["id"],false))
        var suffix := "　導入済" if installed else "　¥%d" % int(p["cost"])
        var pb := _button("%s%s" % [str(p["name"]),suffix],_on_buy_project.bind(str(p["id"])),false,true)
        pb.disabled = installed
        safety.add_child(pb)

func _route_button(route_id: String, label_text: String, selected: bool) -> Button:
    var button := _button(label_text,_on_route_explore.bind(route_id),selected,false)
    button.custom_minimum_size.y = 54
    return button

func _on_route_explore(route_id: String) -> void:
    if not rules.has_method("explore_route"):
        return
    _commit(rules.explore_route(state,route_id),"work","mountain_" + route_id)
