class_name GameRulesV12
extends "res://scripts/core/game_rules_v07.gd"

const ROUTES := {
    "stream": {"name":"沢沿い","rare_bonus":-0.015,"qty_bonus":1,"growth_bonus":1},
    "beech": {"name":"ブナ林","rare_bonus":0.045,"qty_bonus":0,"growth_bonus":2},
    "ridge": {"name":"尾根","rare_bonus":0.095,"qty_bonus":-1,"growth_bonus":3}
}

func ensure_route_fields(s: Dictionary) -> void:
    ensure_entertainment_fields(s)
    var e: Dictionary = s["entertainment"]
    if not e.has("route_counts"):
        e["route_counts"] = {"stream":0,"beech":0,"ridge":0}
    if not e.has("last_route"):
        e["last_route"] = ""
    if not e.has("last_find"):
        e["last_find"] = ""
    s["entertainment"] = e

func route_name(route_id: String) -> String:
    return str(ROUTES.get(route_id,{}).get("name","山道"))

func _route_products(sk: String, route_id: String) -> Array[String]:
    if route_id == "stream":
        if sk == "spring": return ["kogomi","udo","kogomi","taranome"]
        if sk == "summer": return ["sansho","honey","sansho"]
        if sk == "autumn": return ["nameko","hiratake","nameko"]
        return ["shiitake","eggs"]
    if route_id == "beech":
        if sk == "spring": return ["taranome","koshi","udo"]
        if sk == "summer": return ["sansho","honey"]
        if sk == "autumn": return ["shiitake","nameko","hiratake"]
        return ["shiitake","eggs"]
    if sk == "spring": return ["taranome","koshi","taranome"]
    if sk == "summer": return ["honey","sansho","honey"]
    if sk == "autumn": return ["hiratake","shiitake","hiratake"]
    return ["eggs","shiitake"]

func explore_route(s: Dictionary, route_id: String) -> Dictionary:
    ensure_route_fields(s)
    if not ROUTES.has(route_id):
        return _result(false,"その山道には入れない")

    var cfg: Dictionary = ROUTES[route_id]
    var e: Dictionary = s["entertainment"]
    var count: int = int(e["explores_this_month"])
    var strong: bool = count < 2
    e["explores_this_month"] = count + 1
    e["last_route"] = route_id
    e["route_counts"][route_id] = int(e["route_counts"].get(route_id,0)) + 1

    var rank: int = land_rank(s)
    var sk: String = season_key(int(s["month"]))
    var base_rare: float = (0.20 + float(rank-1)*0.035) if strong else 0.055
    var rare_chance: float = clampf(base_rare + float(cfg["rare_bonus"]),0.02,0.55)

    if rng.randf() < rare_chance:
        var rare_name: String = _rare_name(sk)
        var first: bool = rare_name not in e["rare_finds"]
        if first:
            e["rare_finds"].append(rare_name)
        var reward: int = 2800 + rank*850 + (1800 if first else 0) + (600 if route_id == "ridge" else 0)
        s["money"] += reward
        s["reputation"] += 2 if first else 1
        s["loop_score"] = mini(100,int(s["loop_score"])+5)
        var growth: Dictionary = _add_prosperity(s,(22 if first else 12) + int(cfg["growth_bonus"]))
        e["last_find"] = rare_name
        add_log(s,"%s探索：%s発見！ ¥%d" % [route_name(route_id),rare_name,reward])
        var suffix: String = " / 里山ランクUP" if bool(growth["rank_up"]) else ""
        var result := _result(true,"RARE！ %s +¥%d%s" % [rare_name,reward,suffix],5,"major")
        result["route"] = route_id
        result["rare"] = true
        result["find"] = rare_name
        return result

    var products: Array[String] = _route_products(sk,route_id)
    var key: String = products[rng.randi_range(0,products.size()-1)]
    var qty: int = (rng.randi_range(2,4) if strong else 1) + int(cfg["qty_bonus"])
    qty = maxi(1,qty)
    if data.get_table("products").has(key):
        _give(s,{key:qty})
    var prosperity: int = (rng.randi_range(7,11) if strong else 2) + int(cfg["growth_bonus"])
    var growth: Dictionary = _add_prosperity(s,prosperity)
    s["xp"] += 3 if strong else 1
    var product_name: String = str(data.get_table("products").get(key,{}).get("name","山の恵み"))
    e["last_find"] = "%s ×%d" % [product_name,qty]
    add_log(s,"%s探索：%s ×%dを発見" % [route_name(route_id),product_name,qty])
    var suffix: String = " / 里山ランクUP" if bool(growth["rank_up"]) else ""
    var result := _result(true,"%s：%s ×%d%s" % [route_name(route_id),product_name,qty,suffix],4 if bool(growth["rank_up"]) else 3,"collect")
    result["route"] = route_id
    result["rare"] = false
    result["find"] = product_name
    result["qty"] = qty
    return result
