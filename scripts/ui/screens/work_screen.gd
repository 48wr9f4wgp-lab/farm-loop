class_name WorkScreen
extends RefCounted

const GREEN_DARK := Color("#234c36")
const MUTED := Color("#6d786f")

func build(host) -> void:
    host.rules.ensure_route_fields(host.state)
    var entertainment: Dictionary = host.state["entertainment"]
    var explored: int = int(entertainment.get("explores_this_month",0))
    var strong_left: int = maxi(0,2-explored)
    var rank_info: Dictionary = host.rules.land_progress(host.state)
    var last_route: String = str(entertainment.get("last_route",""))
    var last_find: String = str(entertainment.get("last_find",""))

    var explore: VBoxContainer = host._section("山へ入る")
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

    explore.add_child(host._lead_text("道ごとに見つかりやすい恵みが変わる。行動力なし。ハズレ道もなし。"))
    explore.add_child(_route_button(host,"stream","沢沿い　採集量＋｜珍品 ○",last_route == "stream"))
    explore.add_child(_route_button(host,"beech","ブナ林　バランス｜珍品 ＋",last_route == "beech"))
    explore.add_child(_route_button(host,"ridge","尾根　珍品 ＋＋｜収量少なめ",last_route == "ridge"))

    var recent := Label.new()
    recent.text = "まだ山の発見なし" if last_find.is_empty() else "直近の発見　%s" % last_find
    recent.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    recent.add_theme_font_size_override("font_size",11)
    recent.add_theme_color_override("font_color",MUTED)
    explore.add_child(recent)

    var field: VBoxContainer = host._section("山仕事")
    field.add_child(host._lead_text("拾った恵みを農場へ戻す。ここから循環が強くなる。"))
    var gather: Button = host._button("落ち葉・籾殻を集める",Callable(host,"_on_gather_leaves"),true,false)
    field.add_child(gather)

    var logs_title := Label.new()
    logs_title.text = "原木を仕込む"
    logs_title.add_theme_font_size_override("font_size",12)
    logs_title.add_theme_color_override("font_color",GREEN_DARK)
    field.add_child(logs_title)

    var logs := HBoxContainer.new()
    logs.add_theme_constant_override("separation",5)
    field.add_child(logs)
    for kind in ["shiitake","nameko","hiratake"]:
        var b: Button = host._button(str(host.data.get_table("products")[kind]["name"]),Callable(host,"_on_inoculate").bind(kind),false,true)
        b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        b.custom_minimum_size.y = 46
        logs.add_child(b)

    var recipes: VBoxContainer = host._section("加工小屋")
    recipes.add_child(host._lead_text("収穫物を商品へ。加工するほど販売の一発が大きくなる。"))
    for recipe in host.data.get_table("recipes"):
        var craft_button: Button = host._button("%s　¥%d" % [str(recipe["name"]),int(recipe["cost"])],Callable(host,"_on_craft").bind(str(recipe["id"])),false,true)
        recipes.add_child(craft_button)

    var growth: VBoxContainer = host._section("里の成長")
    growth.add_child(host._lead_text("よく使う場所から強化して、次の収穫を伸ばす。"))
    for key in host.data.get_table("facilities"):
        var facility: Dictionary = host.data.get_table("facilities")[key]
        var upgrade_button: Button = host._button("%s　Lv%d → 強化" % [str(facility["name"]),int(host.state["facility_levels"][key])],Callable(host,"_on_upgrade").bind(key),false,true)
        growth.add_child(upgrade_button)

    var safety: VBoxContainer = host._section("里山整備")
    for project in host.data.get_table("projects"):
        var installed: bool = bool(host.state["projects"].get(project["id"],false))
        var suffix: String = "　導入済" if installed else "　¥%d" % int(project["cost"])
        var project_button: Button = host._button("%s%s" % [str(project["name"]),suffix],Callable(host,"_on_buy_project").bind(str(project["id"])),false,true)
        project_button.disabled = installed
        safety.add_child(project_button)

func _route_button(host, route_id: String, label_text: String, selected: bool) -> Button:
    var button: Button = host._button(label_text,Callable(host,"_on_route_explore").bind(route_id),selected,false)
    button.custom_minimum_size.y = 54
    return button
