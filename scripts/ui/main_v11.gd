extends "res://scripts/ui/main_v102.gd"

func _ready() -> void:
    super._ready()
    state["version"] = "godot-1.1-work-gameplay"
    save_service.save(state)

func _build_work() -> void:
    rules.ensure_entertainment_fields(state)
    var entertainment: Dictionary = state["entertainment"]
    var explored: int = int(entertainment.get("explores_this_month",0))
    var strong_left: int = maxi(0,2-explored)
    var rank_info: Dictionary = rules.land_progress(state)

    var explore := _section("山へ入る")
    var hero := HBoxContainer.new()
    hero.add_theme_constant_override("separation",10)
    explore.add_child(hero)

    var left := VBoxContainer.new()
    left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    left.add_theme_constant_override("separation",2)
    hero.add_child(left)

    var headline := Label.new()
    headline.text = "今月の濃い探索　残り %d / 2" % strong_left
    headline.add_theme_font_size_override("font_size",16)
    headline.add_theme_color_override("font_color",GREEN_DARK)
    left.add_child(headline)

    var sub := Label.new()
    sub.text = "季節の恵み、珍品、里山成長。行動力なしで何度でも入れる。"
    sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    sub.add_theme_font_size_override("font_size",11)
    sub.add_theme_color_override("font_color",MUTED)
    left.add_child(sub)

    var rank := Label.new()
    rank.text = "%s　里山ランク %d" % [str(rank_info.get("name","雪里")),int(rank_info.get("rank",1))]
    rank.add_theme_font_size_override("font_size",11)
    rank.add_theme_color_override("font_color",Color("#8a621c"))
    left.add_child(rank)

    var explore_button := _button("山を探索する",_on_work_explore,true,false)
    explore_button.custom_minimum_size.y = 58
    explore.add_child(explore_button)

    var rare: Array = entertainment.get("rare_finds",[])
    var find_label := Label.new()
    find_label.text = "珍品：まだ見つかっていない" if rare.is_empty() else "最近の珍品：%s" % "・".join(PackedStringArray(rare.slice(maxi(0,rare.size()-3),rare.size())))
    find_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    find_label.add_theme_font_size_override("font_size",10)
    find_label.add_theme_color_override("font_color",MUTED)
    explore.add_child(find_label)

    var hero_work := _section("今日の山仕事")
    hero_work.add_child(_lead_text("探索で拾った恵みを、農場の循環へつなぐ。"))
    hero_work.add_child(_button("落ち葉・籾殻を集める",_on_gather_leaves,true,false))

    var logs := HBoxContainer.new()
    logs.add_theme_constant_override("separation",5)
    hero_work.add_child(logs)
    for kind in ["shiitake","nameko","hiratake"]:
        var b := _button("%s原木" % str(data.get_table("products")[kind]["name"]),_on_inoculate.bind(kind),false,true)
        b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        logs.add_child(b)

    var recipes := _section("加工小屋")
    recipes.add_child(_lead_text("収穫物をひと手間かけて、価値の高い商品へ。"))
    for r in data.get_table("recipes"):
        recipes.add_child(_button("%s　¥%d" % [str(r["name"]),int(r["cost"])],_on_craft.bind(str(r["id"])),false,true))

    var growth := _section("里の成長")
    growth.add_child(_lead_text("よく使う場所から強くする。設備は収穫効率と選択肢を増やす。"))
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

func _on_work_explore() -> void:
    if not rules.has_method("explore_mountain"):
        return
    _commit(rules.explore_mountain(state),"work","mountain")
