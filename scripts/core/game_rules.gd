class_name GameRules
extends RefCounted

var data: GameData
var rng := RandomNumberGenerator.new()

func _init(game_data: GameData) -> void:
    data = game_data
    rng.randomize()

func season_key(month: int) -> String:
    for key in data.get_table("seasons"):
        if month in data.get_table("seasons")[key]["months"]:
            return key
    return "spring"

func season_name(month: int) -> String:
    return str(data.get_table("seasons")[season_key(month)]["name"])

func add_log(s: Dictionary, text: String) -> void:
    s["log"].push_front("Y%d %d月｜%s" % [s["year"], s["month"], text])
    if s["log"].size() > 60:
        s["log"].resize(60)

func _discover(s: Dictionary, key: String) -> void:
    if data.get_table("products").has(key) and key not in s["discovered"]:
        s["discovered"].append(key)

func _give(s: Dictionary, out: Dictionary) -> void:
    for key in out:
        s["inventory"][key] = int(s["inventory"].get(key, 0)) + int(out[key])
        if int(out[key]) > 0:
            _discover(s, key)

func _has(s: Dictionary, need: Dictionary) -> bool:
    for key in need:
        if int(s["inventory"].get(key, 0)) < int(need[key]):
            return false
    return true

func _take(s: Dictionary, need: Dictionary) -> void:
    for key in need:
        s["inventory"][key] = int(s["inventory"].get(key, 0)) - int(need[key])

func _result(ok: bool, msg: String, tier: int = 1, feedback: String = "work") -> Dictionary:
    return {"ok":ok,"msg":msg,"tier":tier,"feedback":feedback}

func check_level(s: Dictionary) -> bool:
    var changed := false
    for m in data.get_table("milestones"):
        if int(s["xp"]) >= int(m["xp"]) and int(s["level"]) < int(m["level"]):
            s["level"] = int(m["level"])
            s["money"] += int(m["reward"])
            s["reputation"] += 2
            add_log(s, "農場Lv%dへ。%s／報奨 ¥%d" % [m["level"], m["text"], m["reward"]])
            changed = true
    return changed

func harvest(s: Dictionary, facility: String) -> Dictionary:
    if facility != "compost" and not bool(s["ready"].get(facility, false)):
        return _result(false, "今月は回収済み")
    var lv := int(s["facility_levels"].get(facility, 1))
    if facility == "coop":
        var winter := season_key(int(s["month"])) == "winter"
        var eggs: int = maxi(2, (4 + lv * 2) - (2 if winter else 0))
        _give(s, {"eggs":eggs,"manure":3+lv})
        s["ready"]["coop"] = false
        s["xp"] += 5; s["loop_score"] = mini(100, int(s["loop_score"])+1); s["counters"]["harvest"] += 1
        add_log(s, "鶏舎：卵%d個、鶏糞%d回収" % [eggs, 3+lv])
        return _result(true, "卵 +%d / 鶏糞 +%d" % [eggs,3+lv], 2, "collect")
    if facility == "compost":
        if int(s["inventory"]["manure"]) < 4 or int(s["inventory"]["leaves"]) < 2:
            return _result(false, "鶏糞4＋落ち葉/籾殻2が必要")
        s["inventory"]["manure"] -= 4; s["inventory"]["leaves"] -= 2; s["compost_queue"] += 1; s["xp"] += 4
        add_log(s, "堆肥舎：鶏糞＋落ち葉/籾殻を仕込み。来月完成予定")
        return _result(true, "堆肥を仕込んだ", 2, "work")
    if facility == "sansai":
        var eligible: Array = []
        for key in data.get_table("sansai"):
            var g: Dictionary = data.get_table("sansai")[key]
            if int(s["month"]) in g["months"] and int(g["unlock"]) <= int(s["level"]):
                eligible.append([key,g])
        if eligible.is_empty():
            return _result(false, "今月は山菜の主収穫期ではない")
        var slots: int = mini(eligible.size(), 2 + int((lv-1)/2.0))
        var out := {}
        var boost := int(s["buffs"]["field"]) + int(s["buffs"]["pollination"])
        for i in range(slots):
            var key: String = eligible[i][0]
            var guide: Dictionary = eligible[i][1]
            var rarity_penalty := 1 if int(guide["rarity"]) >= 3 else 0
            out[key] = maxi(1, 1 + int(lv/2.0) + boost - rarity_penalty + (1 if i == 0 else 0))
        _give(s,out); s["buffs"]["field"] = 0; s["buffs"]["pollination"] = 0; s["ready"]["sansai"] = false
        s["xp"] += 7 + slots; s["counters"]["harvest"] += 1
        add_log(s, "山菜区画：旬の山菜%d種を収穫" % slots)
        check_level(s)
        return _result(true, "旬の山菜 %d種を収穫" % slots, 3 if slots >= 3 else 2, "collect")
    if facility == "mushroom":
        var sh := 0; var na := 0; var hi := 0
        var sk := season_key(int(s["month"]))
        for batch in s["mushroom_batches"]:
            if int(batch["age"]) < 10 or int(batch["health"]) < 45: continue
            var seasonal := 0.18
            if batch["type"] == "shiitake": seasonal = 1.7 if sk == "autumn" else (0.8 if sk == "spring" else 0.25)
            elif batch["type"] == "nameko": seasonal = 1.9 if sk == "autumn" else 0.10
            elif batch["type"] == "hiratake": seasonal = 0.9 if sk == "summer" else (1.25 if sk == "autumn" else 0.18)
            var qty: int = maxi(0, int(floor((float(batch["count"])/18.0)*(float(batch["health"])/100.0)*seasonal*(0.85+rng.randf()*0.3))))
            if batch["type"] == "shiitake": sh += qty
            elif batch["type"] == "nameko": na += qty
            else: hi += qty
        if sh + na + hi == 0: return _result(false, "今月は発生が少ない")
        _give(s,{"shiitake":sh,"nameko":na,"hiratake":hi}); s["ready"]["mushroom"] = false; s["xp"] += 6; s["counters"]["harvest"] += 1
        add_log(s,"原木林：シイタケ%d・なめこ%d・ヒラタケ%d収穫" % [sh,na,hi])
        return _result(true,"シイタケ +%d / なめこ +%d / ヒラタケ +%d" % [sh,na,hi],2,"collect")
    if facility == "bee":
        var sk := season_key(int(s["month"]))
        if sk not in ["summer","autumn"]: return _result(false,"採蜜期ではない。群の維持を優先")
        var q: int = maxi(1, int(floor(lv*(1.4 if sk == "summer" else 0.8))))
        _give(s,{"honey":q}); s["buffs"]["pollination"] = 1; s["ready"]["bee"] = false; s["xp"] += 8; s["loop_score"] = mini(100,int(s["loop_score"])+3); s["counters"]["harvest"] += 1
        add_log(s,"蜂場：百花蜜%d瓶。受粉ボーナス獲得" % q)
        return _result(true,"百花蜜 +%d" % q,2,"collect")
    return _result(false,"未対応")

func gather_leaves(s: Dictionary) -> Dictionary:
    var q := 2 + int(s["facility_levels"]["compost"])
    s["inventory"]["leaves"] += q; s["xp"] += 1
    add_log(s,"林床・田んぼ周りから落ち葉/籾殻%d回収" % q)
    return _result(true,"資材 +%d" % q,2,"work")

func apply_compost(s: Dictionary) -> Dictionary:
    if int(s["inventory"]["compost"]) < 1: return _result(false,"完成堆肥がない")
    s["inventory"]["compost"] -= 1; s["buffs"]["field"] = mini(3,int(s["buffs"]["field"])+1); s["loop_score"] = mini(100,int(s["loop_score"])+6); s["reputation"] += 1; s["xp"] += 3
    add_log(s,"発酵堆肥を山菜区画へ還元。次回収量アップ")
    return _result(true,"次回の山菜収量 +1",3,"loop")

func craft(s: Dictionary, recipe_id: String) -> Dictionary:
    for r in data.get_table("recipes"):
        if r["id"] != recipe_id: continue
        if int(s["facility_levels"]["workshop"]) < int(r["level"]): return _result(false,"加工小屋Lv%dが必要" % r["level"])
        if not _has(s,r["input"]): return _result(false,"材料不足")
        if int(s["money"]) < int(r["cost"]): return _result(false,"資金不足")
        _take(s,r["input"]); _give(s,r["output"]); s["money"] -= int(r["cost"]); s["xp"] += 6; s["counters"]["craft"] += 1
        add_log(s,"%sを加工" % r["name"]); check_level(s)
        return _result(true,"%s 完成" % r["name"],2,"craft")
    return _result(false,"レシピ不明")

func quote_price(s: Dictionary, product_id: String, channel_id: String) -> int:
    var p: Dictionary = data.get_table("products").get(product_id,{})
    var c: Dictionary = data.get_table("channels").get(channel_id,{})
    if p.is_empty() or c.is_empty(): return 0
    var season_bonus := 1.22 if p.get("season","") == season_key(int(s["month"])) else 1.0
    var quality: float = 0.94 + minf(0.18,float(s["reputation"])/300.0) + minf(0.10,float(s["loop_score"])/500.0)
    var noise: float = 0.96 + rng.randf()*0.08
    var processed := 1.12 if p["category"] == "processed" and channel_id == "giftshop" else 1.0
    return maxi(1,int(round(float(p["base"])*float(c["price"])*season_bonus*quality*noise*processed)))

func sell_all(s: Dictionary, product_id: String, channel_id: String) -> Dictionary:
    var p: Dictionary = data.get_table("products").get(product_id,{})
    var c: Dictionary = data.get_table("channels").get(channel_id,{})
    if p.is_empty() or not bool(p.get("sellable",false)): return _result(false,"販売対象外")
    if c.is_empty() or int(s["level"]) < int(c["unlock"]): return _result(false,"販路未解放")
    var n := int(s["inventory"].get(product_id,0));
    if n <= 0: return _result(false,"在庫なし")
    var net: int = maxi(0, quote_price(s,product_id,channel_id)*n-int(c["fee"]))
    s["inventory"][product_id] = 0; s["money"] += net; s["yearly_sales"] += net; s["lifetime_sales"] += net; s["reputation"] += int(c["rep"])+int(n/6.0); s["xp"] += maxi(2,int(net/900.0)); s["counters"]["sales"] += net
    add_log(s,"%sへ%s×%d販売：¥%d" % [c["name"],p["name"],n,net]); check_level(s)
    return _result(true,"売上 ¥%d" % net,3,"sell")

func upgrade_facility(s: Dictionary, facility_id: String) -> Dictionary:
    var f: Dictionary = data.get_table("facilities").get(facility_id,{})
    if f.is_empty(): return _result(false,"施設不明")
    var lv := int(s["facility_levels"][facility_id]); var cost := int(round(float(f["upgrade_base"])*pow(1.55,lv-1)))
    if int(s["money"]) < cost: return _result(false,"資金不足")
    s["money"] -= cost; s["facility_levels"][facility_id] = lv+1; s["reputation"] += 2; s["xp"] += 10
    add_log(s,"%sをLv%dへ強化" % [f["name"],lv+1]); check_level(s)
    return _result(true,"%s Lv%d" % [f["name"],lv+1],3,"upgrade")

func buy_project(s: Dictionary, project_id: String) -> Dictionary:
    for p in data.get_table("projects"):
        if p["id"] != project_id: continue
        if bool(s["projects"].get(project_id,false)): return _result(false,"導入済み")
        if int(s["level"]) < int(p["unlock"]): return _result(false,"農場Lv%dで解放" % p["unlock"])
        if int(s["money"]) < int(p["cost"]): return _result(false,"資金不足")
        s["money"] -= int(p["cost"]); s["projects"][project_id] = true; s["xp"] += 14; s["reputation"] += 2
        add_log(s,"%sを導入" % p["name"]); check_level(s)
        return _result(true,"設備導入完了",4,"major")
    return _result(false,"設備不明")

func inoculate_logs(s: Dictionary, kind: String) -> Dictionary:
    var specs := {"shiitake":[7500,20],"nameko":[5200,14],"hiratake":[4800,12]}
    if not specs.has(kind): return _result(false,"菌種不明")
    var cost: int = specs[kind][0]; var count: int = specs[kind][1]
    if int(s["money"]) < cost: return _result(false,"資金不足")
    s["money"] -= cost; s["mushroom_batches"].append({"id":"%s-%d" % [kind,Time.get_ticks_msec()],"type":kind,"age":0,"count":count,"health":100}); s["xp"] += 5
    add_log(s,"%s用の原木%d本を新規植菌" % [data.get_table("products")[kind]["name"],count])
    return _result(true,"原木%d本を植菌" % count,2,"work")

func relation_tier(points: int) -> String:
    if points >= 50: return "里山の仲間"
    if points >= 25: return "頼れる相手"
    if points >= 10: return "顔なじみ"
    return "知り合い"

func ensure_requests(s: Dictionary) -> void:
    if not s["village_requests"].is_empty(): return
    var eligible: Array = []
    for r in data.get_table("requests"):
        if int(r["min_level"]) <= int(s["level"]) and (not r.has("months") or int(s["month"]) in r["months"]): eligible.append(r.duplicate(true))
    eligible.shuffle()
    for r in eligible:
        if s["village_requests"].size() >= 2: break
        r["done"] = false; s["village_requests"].append(r)

func fulfill_request(s: Dictionary, request_id: String) -> Dictionary:
    for r in s["village_requests"]:
        if r["id"] != request_id: continue
        if bool(r.get("done",false)): return _result(false,"この依頼は完了済み")
        if not _has(s,r["need"]): return _result(false,"必要な品が足りない")
        var before := int(s["relation"][r["villager"]]); _take(s,r["need"]); r["done"] = true; s["money"] += int(r["reward"]); s["reputation"] += 1; s["xp"] += 7; s["relation"][r["villager"]] = before + int(r["relation"])
        add_log(s,"村の依頼「%s」を納品 +¥%d" % [r["label"],r["reward"]]); check_level(s)
        return _result(true,"依頼達成 +¥%d" % r["reward"],4 if relation_tier(before)!=relation_tier(s["relation"][r["villager"]]) else 3,"mission")
    return _result(false,"依頼不明")

func next_month(s: Dictionary) -> Dictionary:
    var before_season := season_key(int(s["month"]))
    if int(s["compost_queue"]) > 0:
        s["inventory"]["compost"] += int(s["compost_queue"]); add_log(s,"発酵堆肥%d完成" % s["compost_queue"]); s["compost_queue"] = 0; s["loop_score"] = mini(100,int(s["loop_score"])+4)
    for b in s["mushroom_batches"]:
        b["age"] += 1
        if rng.randf() < 0.12: b["health"] = maxi(20,int(b["health"])-3)
    if not bool(s["projects"].get("coldStorage",false)):
        for key in ["eggs","taranome","udo","kogomi","sansho","nameko"]:
            var n := int(s["inventory"].get(key,0)); var loss := int(floor(n*0.20))
            if loss > 0: s["inventory"][key] -= loss; add_log(s,"%s%dが鮮度低下でロス" % [data.get_table("products")[key]["name"],loss])
    var risk := _roll_risk(s)
    if risk.is_empty():
        var bonus := 500 + int(s["loop_score"])*24; s["money"] += bonus; add_log(s,"循環運営ボーナス ¥%d" % bonus)
    else:
        s["money"] = maxi(0,int(s["money"])-int(risk["cost"])); add_log(s,"%s ¥%d" % [risk["text"],risk["cost"]])
    s["month"] += 1
    if s["month"] > 12: s["month"] = 1; s["year"] += 1; s["yearly_sales"] = 0; add_log(s,"新しい年が始まった")
    var sk := season_key(int(s["month"])); var weather: Array = data.get_table("seasons")[sk]["weather"]; s["weather"] = weather[rng.randi_range(0,weather.size()-1)]
    s["ready"] = {"coop":true,"sansai":true,"mushroom":true,"bee":true}; s["counters"] = {"harvest":0,"sales":0,"craft":0}; s["village_requests"] = []; ensure_requests(s); s["loop_score"] = maxi(0,int(s["loop_score"])-1)
    return _result(true,"%d年%d月・%sへ" % [s["year"],s["month"],season_name(s["month"])],5 if not risk.is_empty() else 3,"hazard" if not risk.is_empty() else "month")

func _roll_risk(s: Dictionary) -> Dictionary:
    var sk := season_key(int(s["month"])); var roll := rng.randf()
    if sk == "winter" and roll < 0.24:
        var severe := s["weather"] == "大雪"; var cost := 11000 if severe else 6500
        if bool(s["projects"].get("snowRoof",false)): cost = int(cost*0.28)
        return {"type":"snow","cost":cost,"text":"大雪対応費" if severe else "積雪対応費"}
    if roll < 0.34:
        var cost := 7200
        if bool(s["projects"].get("bearFence",false)): cost = int(cost*0.25)
        return {"type":"bear","cost":cost,"text":"熊対策・設備補修"}
    if sk in ["summer","autumn"] and roll < 0.43:
        var cost := 4600
        if int(s["facility_levels"]["bee"]) >= 3: cost = int(cost*0.45)
        return {"type":"wasp","cost":cost,"text":"スズメバチ対策"}
    if roll < 0.50:
        var cost := 5200
        if bool(s["projects"].get("bioGate",false)): cost = int(cost*0.30)
        return {"type":"bio","cost":cost,"text":"防疫強化費"}
    return {}
