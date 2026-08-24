class_name GameRulesV13
extends "res://scripts/core/game_rules_v12.gd"

func preview_price(s: Dictionary, product_id: String, channel_id: String) -> int:
    var p: Dictionary = data.get_table("products").get(product_id,{})
    var c: Dictionary = data.get_table("channels").get(channel_id,{})
    if p.is_empty() or c.is_empty():
        return 0
    var season_bonus: float = 1.22 if p.get("season","") == season_key(int(s["month"])) else 1.0
    var quality: float = 0.94 + minf(0.18,float(s["reputation"])/300.0) + minf(0.10,float(s["loop_score"])/500.0)
    var processed: float = 1.12 if p["category"] == "processed" and channel_id == "giftshop" else 1.0
    return maxi(1,int(round(float(p["base"])*float(c["price"])*season_bonus*quality*processed)))

func basket_preview(s: Dictionary, channel_id: String) -> Dictionary:
    var c: Dictionary = data.get_table("channels").get(channel_id,{})
    if c.is_empty() or int(s["level"]) < int(c.get("unlock",999)):
        return {"ok":false,"net":0,"gross":0,"fee":0,"items":0,"kinds":0}
    var gross: int = 0
    var items: int = 0
    var kinds: int = 0
    for key in data.get_table("products"):
        var p: Dictionary = data.get_table("products")[key]
        var count: int = int(s["inventory"].get(key,0))
        if bool(p.get("sellable",false)) and count > 0:
            gross += preview_price(s,key,channel_id) * count
            items += count
            kinds += 1
    var fee: int = int(c.get("fee",0)) if items > 0 else 0
    return {"ok":true,"net":maxi(0,gross-fee),"gross":gross,"fee":fee,"items":items,"kinds":kinds}

func best_channel(s: Dictionary) -> String:
    var best_id: String = "roadside"
    var best_net: int = -1
    for key in data.get_table("channels"):
        var c: Dictionary = data.get_table("channels")[key]
        if int(s["level"]) < int(c.get("unlock",999)):
            continue
        var preview: Dictionary = basket_preview(s,key)
        if int(preview.get("net",0)) > best_net:
            best_net = int(preview.get("net",0))
            best_id = key
    return best_id
