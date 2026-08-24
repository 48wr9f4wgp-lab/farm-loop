class_name FarmPolishOverlayV15
extends Control

var t: float = 0.0

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    set_process(true)
    queue_redraw()

func _process(delta: float) -> void:
    var map_ref = get_parent()
    if map_ref == null:
        return
    if not bool(map_ref.get("reduced_motion")):
        t += delta
    queue_redraw()

func _draw() -> void:
    var map_ref = get_parent()
    if map_ref == null or size.x <= 0.0 or size.y <= 0.0:
        return
    var facilities_value = map_ref.get("facilities")
    if not (facilities_value is Dictionary):
        return
    var facilities: Dictionary = facilities_value
    var selected: String = str(map_ref.get("selected_facility"))
    var reduced: bool = bool(map_ref.get("reduced_motion"))
    var player_value = map_ref.get("player_pos")
    var target_value = map_ref.get("target_pos")
    var walking: bool = bool(map_ref.get("walking"))

    if player_value is Vector2 and target_value is Vector2 and walking:
        _draw_footstep_route(player_value,target_value,reduced)

    if selected != "" and facilities.has(selected):
        var n: Vector2 = facilities[selected]["p"]
        _draw_target_beacon(Vector2(n.x*size.x,n.y*size.y),reduced)

func _draw_footstep_route(from_norm: Vector2, to_norm: Vector2, reduced: bool) -> void:
    var from := Vector2(from_norm.x*size.x,from_norm.y*size.y)
    var to := Vector2(to_norm.x*size.x,to_norm.y*size.y)
    var distance := from.distance_to(to)
    if distance < 18.0:
        return
    var steps: int = clampi(int(distance/34.0),3,9)
    var phase: float = 0.0 if reduced else fmod(t*1.8,1.0)
    for i in range(1,steps+1):
        var ratio: float = (float(i)-phase)/float(steps+1)
        if ratio <= 0.0 or ratio >= 1.0:
            continue
        var p := from.lerp(to,ratio)
        var dir := (to-from).normalized()
        var side := Vector2(-dir.y,dir.x) * (2.6 if i%2==0 else -2.6)
        var alpha := 0.16 + 0.30*ratio
        draw_circle(p+side,2.8,Color(1.0,0.92,0.62,alpha))
        draw_circle(p+side-dir*3.8,1.5,Color(1.0,0.97,0.78,alpha*0.78))

func _draw_target_beacon(p: Vector2, reduced: bool) -> void:
    var pulse: float = 0.0 if reduced else (sin(t*3.0)+1.0)*0.5
    var radius: float = 43.0 + pulse*7.0
    draw_arc(p,radius,0.25,PI*0.85,18,Color(1.0,0.89,0.43,0.35),2.2)
    draw_arc(p,radius,PI*1.25,PI*1.85,18,Color(1.0,0.89,0.43,0.35),2.2)
    for i in range(3):
        var a: float = float(i)*TAU/3.0 + (0.0 if reduced else t*0.22)
        var q := p+Vector2(cos(a),sin(a))*radius
        draw_circle(q,2.2,Color(1.0,0.95,0.70,0.55))
