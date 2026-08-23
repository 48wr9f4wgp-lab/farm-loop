class_name ProductMapOverlayV07
extends Control

var season := "spring"
var rank := 1
var reduced_motion := false
var t := 0.0

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    set_process(true)
    queue_redraw()

func set_product_state(new_season: String, new_rank: int, reduce_motion: bool) -> void:
    season = new_season
    rank = clampi(new_rank,1,5)
    reduced_motion = reduce_motion
    queue_redraw()

func _process(delta: float) -> void:
    if not reduced_motion:
        t += delta
        queue_redraw()

func _draw() -> void:
    var s: Vector2 = size
    if s.x <= 0.0 or s.y <= 0.0:
        return
    _draw_horizon_haze(s)
    _draw_birds(s)
    _draw_field_texture(s)
    _draw_water_glints(s)
    _draw_motes(s)
    _draw_selected_focus(s)
    _draw_foreground(s)
    _draw_frame(s)

func _draw_horizon_haze(s: Vector2) -> void:
    for i in range(7):
        var alpha: float = 0.045 - float(i)*0.004
        draw_rect(Rect2(0,s.y*(0.31+float(i)*0.017),s.x,s.y*0.025),Color(0.90,0.96,0.93,alpha))

func _draw_birds(s: Vector2) -> void:
    var drift: float = 0.0 if reduced_motion else fmod(t*5.0,s.x+90.0)-45.0
    for i in range(3):
        var p := Vector2(s.x*(0.18+float(i)*0.20)+drift*0.08,s.y*(0.14+float(i%2)*0.045))
        var wing: float = 2.0 if reduced_motion else 2.0+sin(t*4.0+float(i))*1.2
        draw_line(p,p+Vector2(-5,-wing),Color(0.12,0.23,0.18,0.44),1.4)
        draw_line(p,p+Vector2(5,-wing),Color(0.12,0.23,0.18,0.44),1.4)

func _draw_field_texture(s: Vector2) -> void:
    var tint := Color(0.98,0.92,0.62,0.13)
    if season == "summer": tint = Color(0.77,0.93,0.54,0.12)
    elif season == "autumn": tint = Color(0.96,0.67,0.32,0.12)
    elif season == "winter": tint = Color(0.95,0.98,1.0,0.18)
    for i in range(18):
        var x: float = fmod(float(i*61),s.x)
        var y: float = s.y*(0.46+0.43*abs(sin(float(i)*1.37)))
        draw_circle(Vector2(x,y),1.2+float(i%3)*0.5,tint)

func _draw_water_glints(s: Vector2) -> void:
    var offset: float = 0.0 if reduced_motion else fmod(t*18.0,36.0)
    for i in range(5):
        var y: float = s.y*(0.70+float(i)*0.055)
        var x: float = s.x*(0.67+float(i%2)*0.025)
        draw_line(Vector2(x-offset*0.10,y),Vector2(x+14-offset*0.10,y-3),Color(0.90,0.98,1.0,0.58),2.0)

func _draw_motes(s: Vector2) -> void:
    var count: int = 7 + rank
    for i in range(count):
        var phase: float = float(i)*1.77
        var x: float = fmod(float(i)*71.0 + (0.0 if reduced_motion else t*(4.0+float(i%3))),s.x+12.0)-6.0
        var y: float = s.y*(0.50+0.39*abs(sin(phase)))
        var bob: float = 0.0 if reduced_motion else sin(t*1.4+phase)*3.0
        var c := Color("#f1d76c")
        if season == "spring": c = Color("#f5dbde")
        elif season == "autumn": c = Color("#d88c48")
        elif season == "winter": c = Color("#ffffff")
        draw_circle(Vector2(x,y+bob),1.6,Color(c.r,c.g,c.b,0.52))

func _draw_selected_focus(s: Vector2) -> void:
    var map_ref = get_parent()
    if map_ref == null:
        return
    var selected: String = str(map_ref.get("selected_facility"))
    var facilities_value = map_ref.get("facilities")
    if selected == "" or not (facilities_value is Dictionary):
        return
    var facilities: Dictionary = facilities_value
    if not facilities.has(selected):
        return
    var n: Vector2 = facilities[selected]["p"]
    var p := Vector2(n.x*s.x,n.y*s.y)
    var pulse: float = 0.0 if reduced_motion else (sin(t*3.4)+1.0)*2.5
    draw_circle(p+Vector2(0,8),45.0+pulse,Color(1.0,0.85,0.37,0.075))
    draw_arc(p+Vector2(0,8),43.0+pulse,0,TAU,48,Color(1.0,0.91,0.56,0.62),2.0)
    draw_line(p+Vector2(0,-42-pulse),p+Vector2(0,-32),Color(1.0,0.91,0.56,0.70),2.0)

func _draw_foreground(s: Vector2) -> void:
    var base_y: float = s.y*0.985
    for i in range(13):
        var x: float = float(i)*s.x/12.0
        var h: float = 9.0+float((i*5)%8)
        var c := Color("#2f5a40")
        if season == "autumn": c = Color("#68543a")
        elif season == "winter": c = Color("#687c73")
        draw_circle(Vector2(x,base_y),h,Color(c.r,c.g,c.b,0.72))
        draw_line(Vector2(x,base_y),Vector2(x-3,base_y-h-7),Color(c.r,c.g,c.b,0.62),1.4)

func _draw_frame(s: Vector2) -> void:
    draw_rect(Rect2(1,1,s.x-2,s.y-2),Color(0.10,0.22,0.15,0.26),false,2.0)
