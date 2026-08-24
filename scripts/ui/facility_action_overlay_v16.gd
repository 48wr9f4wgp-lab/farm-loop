class_name FacilityActionOverlayV16
extends Control

var t: float = 0.0

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    set_process(true)

func _process(delta: float) -> void:
    var map_ref = get_parent()
    if map_ref == null:
        return
    if not bool(map_ref.get("reduced_motion")):
        t += delta
    queue_redraw()

func _draw() -> void:
    var map_ref = get_parent()
    if map_ref == null:
        return
    var id: String = str(map_ref.get("action_facility"))
    var timer: float = float(map_ref.get("action_timer"))
    if id == "" or timer <= 0.0:
        return
    var facilities_value = map_ref.get("facilities")
    if not (facilities_value is Dictionary) or not facilities_value.has(id):
        return
    var n: Vector2 = facilities_value[id]["p"]
    var p := Vector2(n.x*size.x,n.y*size.y)
    var progress: float = 1.0-clampf(timer/0.62,0.0,1.0)
    match id:
        "coop": _draw_coop_action(p,progress)
        "compost": _draw_compost_action(p,progress)
        "mushroom": _draw_mushroom_action(p,progress)
        "sansai": _draw_sansai_action(p,progress)
        "bee": _draw_bee_action(p,progress)

func _fade(progress: float) -> float:
    return clampf(1.0-progress,0.0,1.0)

func _draw_coop_action(p: Vector2, progress: float) -> void:
    var alpha := _fade(progress)
    for i in range(5):
        var a: float = -PI*0.85 + float(i)*PI*0.42
        var q := p+Vector2(cos(a),sin(a))*(18.0+progress*(28.0+float(i)*3.0))+Vector2(0,-8)
        draw_circle(q,3.2,Color(1.0,0.97,0.84,alpha*0.9))
        draw_line(q,q+Vector2(cos(a+0.8),sin(a+0.8))*6.0,Color(0.93,0.84,0.62,alpha*0.7),1.6)

func _draw_compost_action(p: Vector2, progress: float) -> void:
    var alpha := _fade(progress)
    for i in range(4):
        var x: float = float(i-2)*8.0 + sin(t*3.0+float(i))*3.0
        var y: float = -18.0-progress*(25.0+float(i)*5.0)
        draw_circle(p+Vector2(x,y),6.0+progress*3.0,Color(0.92,0.94,0.86,alpha*0.26))

func _draw_mushroom_action(p: Vector2, progress: float) -> void:
    var alpha := _fade(progress)
    for i in range(8):
        var a: float = TAU*float(i)/8.0 + t*0.18
        var q := p+Vector2(cos(a),sin(a)*0.65)*(16.0+progress*34.0)
        draw_circle(q,2.2+float(i%2),Color(0.93,0.86,0.67,alpha*0.75))

func _draw_sansai_action(p: Vector2, progress: float) -> void:
    var alpha := _fade(progress)
    for i in range(6):
        var a: float = -PI+float(i)*PI/5.0
        var q := p+Vector2(cos(a),sin(a))*(15.0+progress*32.0)+Vector2(0,-10)
        draw_set_transform(q,a+progress*2.0,Vector2(1.0,0.55))
        draw_circle(Vector2.ZERO,4.0,Color(0.55,0.78,0.34,alpha*0.75))
        draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE)

func _draw_bee_action(p: Vector2, progress: float) -> void:
    var alpha := _fade(progress)
    for i in range(7):
        var a: float = TAU*float(i)/7.0+t*(1.8+float(i%3)*0.15)
        var radius: float = 19.0+progress*24.0+float(i%2)*5.0
        var q := p+Vector2(cos(a)*radius,sin(a)*radius*0.55)-Vector2(0,8)
        draw_circle(q,2.4,Color(0.96,0.75,0.18,alpha))
        draw_line(q+Vector2(-2,0),q+Vector2(2,0),Color(0.16,0.20,0.13,alpha),1.0)
