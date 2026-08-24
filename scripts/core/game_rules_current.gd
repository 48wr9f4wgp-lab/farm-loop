class_name GameRulesCurrent
extends "res://scripts/core/game_rules.gd"

# Canonical current-domain implementation.
# Consolidates the behavior previously layered across V05/V06/V07/V12/V13/V14.
# Keep behavior identical during B3; balance or feature changes are out of scope.

const LAND_THRESHOLDS := [0, 45, 115, 210, 340]
const LAND_NAMES := ["芽吹く里", "育つ里", "実る里", "賑わう里", "豊かな雪里"]

const DAILY_HARVEST_TARGET := 2
const DAILY_EXPLORE_TARGET := 1
const DAILY_SELL_TARGET := 1

const ROUTES := {
    "stream": {"name":"沢沿い","rare_bonus":-0.015,"qty_bonus":1,"growth_bonus":1},
    "beech": {"name":"ブナ林","rare_bonus":0.045,"qty_bonus":0,"growth_bonus":2},
    "ridge": {"name":"尾根","rare_bonus":0.095,"qty_bonus":-1,"growth_bonus":3}
}

# --- Satoyama / entertainment -------------------------------------------------

func ensure_entertainment_fields(s: Dictionary) -> void:
    if not s.has("entertainment"):
        s["entertainment"] = {}
    var e: Dictionary = s["entertainment"]
    if not e.has("prosperity_xp"): e["prosperity_xp"] = 0
    if not e.has("explores_this_month"): e["explores_this_month"] = 0
    if not e.has("rare_finds"): e["rare_finds"] = []
    if not e.has("chain_stage"): e["chain_stage"] = 0
    if not e.has("chains_completed"): e["chains_completed"] = 0
    if not e.has("best_chain"): e["best_chain"] = 0
    s["entertainment"] = e

func land_rank(s: Dictionary) -> int:
    ensure_entertainment_fields(s)
    var xp: int = int(s["entertainment"]["prosperity_xp"])
    var rank: int = 1
    for i in range(LAND_THRESHOLDS.size()):
        if xp >= int(LAND_THRESHOLDS[i]):
            rank = i + 1
    return mini(rank, LAND_THRESHOLDS.size())

func land_name(s: Dictionary) -> String:
    return str(LAND_NAMES[land_rank(s)-1])

func land_progress(s: Dictionary) -> Dictionary:
    var rank: int = land_rank(s)
    var xp: int = int(s["entertainment"]["prosperity_xp"])
    if rank >= LAND_THRESHOLDS.size():
        return {"rank":rank,"name":land_name(s),"current":xp,"next":xp,"ratio":1.0}
    var low: int = int(LAND_THRESHOLDS[rank-1])
    var high: int = int(LAND_THRESHOLDS[rank])
    return {"rank":rank,"name":land_name(s),"current":xp,"next":high,"ratio":clampf(float(xp-low)/float(high-low),0.0,1.0)}

func _add_prosperity(s: Dictionary, amount: int) -> Dictionary:
    ensure_entertainment_fields(s)
    var before: int = land_rank(s)
    s["entertainment"]["prosperity_xp"] = int(s["entertainment"]["prosperity_xp"]) + amount
    var after: int = land_rank(s)
    return {"before":before,"after":after,"rank_up":after > before}

func _season_products(sk: String) -> Array[String]:
    if sk == "spring": return ["taranome","kogomi","udo","koshi"]
    if sk == "summer": return ["sansho","honey"]
    if sk == "autumn": return ["shiitake","nameko","hiratake"]
    return ["shiitake","eggs"]

func _rare_name(sk: String) -> String:
    var pool: Array[String]
    if sk == "spring": pool = ["金芽タラ", "朝露コシアブラ", "雪解けコゴミ"]
    elif sk == "summer": pool = ["星蜜", "香り山椒", "翠蜂の蜜"]
    elif sk == "autumn": pool = ["月光なめこ", "白銀シイタケ", "紅葉ヒラタケ"]
    else: pool = ["雪灯りシイタケ", "冬籠りの宝箱", "白雪の落とし物"]
    return pool[rng.randi_range(0,pool.size()-1)]

func explore_mountain(s: Dictionary) -> Dictionary:
    ensure_entertainment_fields(s)
    var e: Dictionary = s["entertainment"]
    var count: int = int(e["explores_this_month"])
    e["explores_this_month"] = count + 1
    var rank: int = land_rank(s)
    var strong: bool = count < 2
    var rare_chance: float = (0.20 + float(rank-1)*0.035) if strong else 0.055
    var roll: float = rng.randf()
    var sk: String = season_key(int(s["month"]))

    if roll < rare_chance:
        var rare_name: String = _rare_name(sk)
        var first: bool = rare_name not in e["rare_finds"]
        if first:
            e["rare_finds"].append(rare_name)
        var reward: int = 2800 + rank*850 + (1800 if first else 0)
        s["money"] += reward
        s["reputation"] += 2 if first else 1
        s["loop_score"] = mini(100,int(s["loop_score"])+5)
        var growth: Dictionary = _add_prosperity(s, 22 if first else 12)
        add_log(s,"山探索：%s発見！ ¥%d" % [rare_name,reward])
        var suffix: String = " / 里山ランクUP" if bool(growth["rank_up"]) else ""
        return _result(true,"RARE！ %s +¥%d%s" % [rare_name,reward,suffix],5,"major")

    var products: Array[String] = _season_products(sk)
    var key: String = products[rng.randi_range(0,products.size()-1)]
    var qty: int = rng.randi_range(2,4) if strong else 1
    if data.get_table("products").has(key):
        var out: Dictionary = {}
        out[key] = qty
        _give(s,out)
    var prosperity: int = rng.randi_range(7,11) if strong else 2
    var growth: Dictionary = _add_prosperity(s,prosperity)
    s["xp"] += 3 if strong else 1
    var product_name: String = str(data.get_table("products").get(key,{}).get("name","山の恵み"))
    add_log(s,"山探索：%s ×%dを発見" % [product_name,qty])
    var suffix: String = " / 里山ランクUP" if bool(growth["rank_up"]) else ""
    return _result(true,"探索成功：%s ×%d%s" % [product_name,qty,suffix],4 if bool(growth["rank_up"]) else 3,"collect")

func register_loop_action(s: Dictionary, kind: String, facility: String = "") -> Dictionary:
    ensure_entertainment_fields(s)
    var e: Dictionary = s["entertainment"]
    var stage: int = int(e["chain_stage"])
    var matched: bool = false

    if stage == 0 and kind == "collect" and facility == "coop": matched = true
    elif stage == 1 and kind == "work" and facility == "compost": matched = true
    elif stage == 2 and kind in ["month","hazard"]: matched = true
    elif stage == 3 and kind == "loop": matched = true
    elif stage == 4 and kind == "collect" and facility == "sansai": matched = true
    elif stage == 5 and kind == "sell": matched = true

    if not matched:
        return {"advanced":false,"complete":false,"stage":stage}

    stage += 1
    e["best_chain"] = maxi(int(e["best_chain"]),stage)
    if stage < 6:
        e["chain_stage"] = stage
        return {"advanced":true,"complete":false,"stage":stage}

    e["chain_stage"] = 0
    e["chains_completed"] = int(e["chains_completed"]) + 1
    var rank: int = land_rank(s)
    var bonus: int = 1600 + rank*700 + int(e["chains_completed"])*150
    s["money"] += bonus
    s["loop_score"] = mini(100,int(s["loop_score"])+7)
    s["reputation"] += 1
    var growth: Dictionary = _add_prosperity(s,28)
    add_log(s,"循環チェイン完成！ ボーナス ¥%d" % bonus)
    return {"advanced":true,"complete":true,"stage":6,"bonus":bonus,"rank_up":bool(growth["rank_up"])}

func next_month(s: Dictionary) -> Dictionary:
    ensure_entertainment_fields(s)
    var result: Dictionary = super.next_month(s)
    s["entertainment"]["explores_this_month"] = 0
    _add_prosperity(s,3)
    return result

# --- Daily notebook -----------------------------------------------------------

func ensure_product_fields(s: Dictionary) -> void:
    ensure_entertainment_fields(s)
    if not s.has("daily"):
        s["daily"] = {}
    var d: Dictionary = s["daily"]
    var today: String = Time.get_date_string_from_system()
    if str(d.get("date","")) != today:
        var total: int = int(d.get("total_completed",0))
        d = {
            "date":today,
            "harvest":0,
            "explore":0,
            "sell":0,
            "claimed":false,
            "total_completed":total
        }
    if not d.has("harvest"): d["harvest"] = 0
    if not d.has("explore"): d["explore"] = 0
    if not d.has("sell"): d["sell"] = 0
    if not d.has("claimed"): d["claimed"] = false
    if not d.has("total_completed"): d["total_completed"] = 0
    s["daily"] = d

func daily_summary(s: Dictionary) -> Dictionary:
    ensure_product_fields(s)
    var d: Dictionary = s["daily"]
    return {
        "harvest":mini(int(d["harvest"]),DAILY_HARVEST_TARGET),
        "harvest_target":DAILY_HARVEST_TARGET,
        "explore":mini(int(d["explore"]),DAILY_EXPLORE_TARGET),
        "explore_target":DAILY_EXPLORE_TARGET,
        "sell":mini(int(d["sell"]),DAILY_SELL_TARGET),
        "sell_target":DAILY_SELL_TARGET,
        "claimed":bool(d["claimed"]),
        "total_completed":int(d["total_completed"])
    }

func _daily_complete(d: Dictionary) -> bool:
    return int(d["harvest"]) >= DAILY_HARVEST_TARGET and int(d["explore"]) >= DAILY_EXPLORE_TARGET and int(d["sell"]) >= DAILY_SELL_TARGET

func track_daily_action(s: Dictionary, kind: String, facility: String = "") -> Dictionary:
    ensure_product_fields(s)
    var d: Dictionary = s["daily"]
    if kind == "collect" and facility != "mountain":
        d["harvest"] = int(d["harvest"]) + 1
    if facility == "mountain":
        d["explore"] = int(d["explore"]) + 1
    if kind == "sell":
        d["sell"] = int(d["sell"]) + 1

    if _daily_complete(d) and not bool(d["claimed"]):
        d["claimed"] = true
        d["total_completed"] = int(d["total_completed"]) + 1
        var rank: int = land_rank(s)
        var bonus: int = 2200 + rank * 550
        s["money"] += bonus
        s["reputation"] += 1
        s["loop_score"] = mini(100,int(s["loop_score"])+5)
        var growth: Dictionary = _add_prosperity(s,16)
        add_log(s,"里山手帳を達成！ +¥%d" % bonus)
        return {"completed_now":true,"bonus":bonus,"rank_up":bool(growth["rank_up"])}
    return {"completed_now":false}

# --- Basket selling -----------------------------------------------------------

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

# --- Mountain routes ----------------------------------------------------------

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

# --- Market projection --------------------------------------------------------

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

# --- Village projection -------------------------------------------------------

func request_status(s: Dictionary, request: Dictionary) -> Dictionary:
    var ready: bool = true
    var need_parts := PackedStringArray()
    var missing_parts := PackedStringArray()
    for key in request.get("need",{}):
        var required: int = int(request["need"][key])
        var owned: int = int(s["inventory"].get(key,0))
        var product: Dictionary = data.get_table("products").get(key,{})
        var product_name: String = str(product.get("name",key))
        need_parts.append("%s %d" % [product_name,required])
        if owned < required:
            ready = false
            missing_parts.append("%s あと%d" % [product_name,required-owned])
    return {
        "ready":ready and not bool(request.get("done",false)),
        "need":"・".join(need_parts),
        "missing":" / ".join(missing_parts),
        "done":bool(request.get("done",false))
    }

func relation_progress(points: int) -> Dictionary:
    if points >= 50:
        return {"tier":"里山の仲間","next":"MAX","current":50,"target":50,"ratio":1.0}
    if points >= 25:
        return {"tier":"頼れる相手","next":"里山の仲間","current":points-25,"target":25,"ratio":clampf(float(points-25)/25.0,0.0,1.0)}
    if points >= 10:
        return {"tier":"顔なじみ","next":"頼れる相手","current":points-10,"target":15,"ratio":clampf(float(points-10)/15.0,0.0,1.0)}
    return {"tier":"知り合い","next":"顔なじみ","current":points,"target":10,"ratio":clampf(float(points)/10.0,0.0,1.0)}

func ready_request_count(s: Dictionary) -> int:
    var count: int = 0
    for request in s["village_requests"]:
        if bool(request_status(s,request)["ready"]):
            count += 1
    return count
