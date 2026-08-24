extends "res://scripts/ui/main_v12.gd"

const RulesV13Class = preload("res://scripts/core/game_rules_v13.gd")

func _ready() -> void:
    super._ready()
    rules = RulesV13Class.new(data)
    rules.ensure_route_fields(state)
    state["version"] = "godot-1.3-market-product"
    save_service.save(state)
    _header()
    _show_tab(current_tab)

func _build_market() -> void:
    var total_items: int = _sellable_stock()
    var best_id: String = rules.best_channel(state)
    var channels: Dictionary = data.get_table("channels")
    if not channels.has(selected_channel) or int(state["level"]) < int(channels[selected_channel].get("unlock",999)):
        selected_channel = best_id

    var preview: Dictionary = rules.basket_preview(state,selected_channel)
    var best_name: String = str(channels[best_id]["name"])
    var selected_name: String = str(channels[selected_channel]["name"])

    var hero := _section("今日の出荷")
    var hero_top := HBoxContainer.new()
    hero_top.add_theme_constant_override("separation",8)
    hero.add_child(hero_top)

    var value_box := VBoxContainer.new()
    value_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    value_box.add_theme_constant_override("separation",0)
    hero_top.add_child(value_box)

    var caption := Label.new()
    caption.text = "予想手取り"
    caption.add_theme_font_size_override("font_size",10)
    caption.add_theme_color_override("font_color",MUTED)
    value_box.add_child(caption)

    var value := Label.new()
    value.text = "約 ¥%d" % int(preview.get("net",0))
    value.add_theme_font_size_override("font_size",30)
    value.add_theme_color_override("font_color",Color("#8a621c"))
    value_box.add_child(value)

    var recommend := Label.new()
    recommend.text = "おすすめ\n%s" % best_name
    recommend.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    recommend.add_theme_font_size_override("font_size",10)
    recommend.add_theme_color_override("font_color",GREEN_DARK)
    recommend.add_theme_stylebox_override("normal",_chip_style(Color("#e3efd9")))
    hero_top.add_child(recommend)

    var summary := Label.new()
    summary.text = "%sへ %d種・%d品｜手数料 ¥%d" % [selected_name,int(preview.get("kinds",0)),int(preview.get("items",0)),int(preview.get("fee",0))]
    summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    summary.add_theme_font_size_override("font_size",11)
    summary.add_theme_color_override("font_color",MUTED)
    hero.add_child(summary)

    var sell_all := _button("%sへまとめて出荷" % selected_name,_on_sell_basket,true,false)
    sell_all.custom_minimum_size.y = 58
    sell_all.disabled = total_items <= 0
    hero.add_child(sell_all)

    if total_items <= 0:
        hero.add_child(_lead_text("収穫かごは空。農場か山で恵みを集めると、ここに売上予想が出る。"))

    var channels_section := _section("売り先を選ぶ")
    channels_section.add_child(_lead_text("価格倍率と手数料の差で、同じ収穫でも手取りが変わる。"))
    for key in channels:
        var channel: Dictionary = channels[key]
        if int(state["level"]) < int(channel.get("unlock",999)):
            continue
        var p: Dictionary = rules.basket_preview(state,key)
        var star: String = "　★おすすめ" if key == best_id else ""
        var label_text := "%s　×%.2f｜手数料¥%d｜約¥%d%s" % [
            str(channel["name"]),float(channel["price"]),int(channel["fee"]),int(p.get("net",0)),star
        ]
        var b := _button(label_text,_on_channel.bind(key),key == selected_channel,false)
        b.custom_minimum_size.y = 52
        channels_section.add_child(b)

    var basket := _section("収穫かご")
    var found: bool = false
    for key in data.get_table("products"):
        var product: Dictionary = data.get_table("products")[key]
        var count: int = int(state["inventory"].get(key,0))
        if not bool(product.get("sellable",false)) or count <= 0:
            continue
        found = true
        var item_value: int = rules.preview_price(state,key,selected_channel) * count
        var item_button := _button("%s ×%d　約¥%d" % [str(product["name"]),count,item_value],_on_sell.bind(key),false,true)
        item_button.custom_minimum_size.y = 46
        basket.add_child(item_button)
    if not found:
        basket.add_child(_lead_text("まだ出荷できる品はない。"))
