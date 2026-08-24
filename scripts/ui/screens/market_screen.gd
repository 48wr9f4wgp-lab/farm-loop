class_name MarketScreen
extends RefCounted

const GREEN_DARK := Color("#234c36")
const MUTED := Color("#6d786f")

func build(host) -> void:
    var total_items: int = host._sellable_stock()
    var best_id: String = host.rules.best_channel(host.state)
    var channels: Dictionary = host.data.get_table("channels")
    if not channels.has(host.selected_channel) or int(host.state["level"]) < int(channels[host.selected_channel].get("unlock",999)):
        host.selected_channel = best_id

    var guided: bool = host.ftue_service != null and host.ftue_service.active(host.state)
    var guided_step: int = host.ftue_service.step(host.state) if guided else -1
    var sale_unlocked: bool = not guided or guided_step >= 8

    var preview: Dictionary = host.rules.basket_preview(host.state,host.selected_channel)
    var best_name: String = str(channels[best_id]["name"])
    var selected_name: String = str(channels[host.selected_channel]["name"])

    var hero: VBoxContainer = host._section("今日の出荷")
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
    recommend.add_theme_stylebox_override("normal",host._chip_style(Color("#e3efd9")))
    hero_top.add_child(recommend)

    var summary := Label.new()
    summary.text = "%sへ %d種・%d品｜手数料 ¥%d" % [selected_name,int(preview.get("kinds",0)),int(preview.get("items",0)),int(preview.get("fee",0))]
    summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    summary.add_theme_font_size_override("font_size",11)
    summary.add_theme_color_override("font_color",MUTED)
    hero.add_child(summary)

    var sell_all: Button = host._button("%sへまとめて出荷" % selected_name,Callable(host,"_on_sell_basket"),true,false)
    sell_all.custom_minimum_size.y = 58
    sell_all.disabled = total_items <= 0 or not sale_unlocked
    hero.add_child(sell_all)

    if guided and not sale_unlocked:
        hero.add_child(host._lead_text("最初の循環をつなぐまでは売上を確認するだけ。素材を先に売って詰むことはない。"))
    elif total_items <= 0:
        hero.add_child(host._lead_text("収穫かごは空。農場か山で恵みを集めると、ここに売上予想が出る。"))

    var channels_section: VBoxContainer = host._section("売り先を選ぶ")
    channels_section.add_child(host._lead_text("価格倍率と手数料の差で、同じ収穫でも手取りが変わる。"))
    for key in channels:
        var channel: Dictionary = channels[key]
        if int(host.state["level"]) < int(channel.get("unlock",999)):
            continue
        var p: Dictionary = host.rules.basket_preview(host.state,key)
        var star: String = "　★おすすめ" if key == best_id else ""
        var label_text: String = "%s　×%.2f｜手数料¥%d｜約¥%d%s" % [
            str(channel["name"]),float(channel["price"]),int(channel["fee"]),int(p.get("net",0)),star
        ]
        var b: Button = host._button(label_text,Callable(host,"_on_channel").bind(key),key == host.selected_channel,false)
        b.custom_minimum_size.y = 52
        channels_section.add_child(b)

    var basket: VBoxContainer = host._section("収穫かご")
    var found: bool = false
    for key in host.data.get_table("products"):
        var product: Dictionary = host.data.get_table("products")[key]
        var count: int = int(host.state["inventory"].get(key,0))
        if not bool(product.get("sellable",false)) or count <= 0:
            continue
        found = true
        var item_value: int = host.rules.preview_price(host.state,key,host.selected_channel) * count
        var item_button: Button = host._button("%s ×%d　約¥%d" % [str(product["name"]),count,item_value],Callable(host,"_on_sell").bind(key),false,true)
        item_button.custom_minimum_size.y = 46
        # Guided session deliberately ends on one satisfying basket sale rather
        # than letting one-by-one sales erase the payoff or consume key items.
        item_button.disabled = guided
        basket.add_child(item_button)
    if not found:
        basket.add_child(host._lead_text("まだ出荷できる品はない。"))
