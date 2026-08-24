class_name GameRulesV14
extends "res://scripts/core/game_rules_v13.gd"

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
