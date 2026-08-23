class_name GameRulesV07
extends "res://scripts/core/game_rules_v06.gd"

func sell_basket(s: Dictionary, channel_id: String) -> Dictionary:
    var c: Dictionary = data.get_table("channels").get(channel_id,{})
    if c.is_empty() or int(s["level"]) < int(c["unlock"]):
        return _result(false,"販路未解放")

    var gross: int = 0
    var item_count: int = 0
    var kind_count: int = 0
    var sold: Dictionary = {}
    for key in data.get_table("products"):
        var p: Dictionary = data.get_table("products")[key]
        var n: int = int(s["inventory"].get(key,0))
        if not bool(p.get("sellable",false)) or n <= 0:
            continue
        gross += quote_price(s,key,channel_id) * n
        item_count += n
        kind_count += 1
        sold[key] = n

    if item_count <= 0:
        return _result(false,"販売できる収穫物がない")

    var net: int = maxi(0,gross-int(c["fee"]))
    for key in sold:
        s["inventory"][key] = 0
    s["money"] += net
    s["yearly_sales"] += net
    s["lifetime_sales"] += net
    s["reputation"] += int(c["rep"]) + int(item_count/8.0)
    s["xp"] += maxi(3,int(net/850.0))
    s["counters"]["sales"] += net
    add_log(s,"%sへ収穫かごを一括出荷：%d種%d品 ¥%d" % [c["name"],kind_count,item_count,net])
    check_level(s)
    return _result(true,"まとめて出荷！ %d品 +¥%d" % [item_count,net],4,"sell")
