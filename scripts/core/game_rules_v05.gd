class_name GameRulesV05
extends "res://scripts/core/game_rules.gd"

const LAND_THRESHOLDS := [0, 45, 115, 210, 340]
const LAND_NAMES := ["芽吹く里", "育つ里", "実る里", "賑わう里", "豊かな雪里"]

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
        _give(s,{key:qty})
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
    return {"advanced":true,"complete":true,"stage":6,"bonus":bonus,"rank_up":bool(growth["rank_up"]) }

func next_month(s: Dictionary) -> Dictionary:
    ensure_entertainment_fields(s)
    var result: Dictionary = super.next_month(s)
    s["entertainment"]["explores_this_month"] = 0
    _add_prosperity(s,3)
    return result
