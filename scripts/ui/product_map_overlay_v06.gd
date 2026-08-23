class_name ProductMapOverlayV06
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
    _draw_cloud_shadows(s)
    _draw_motes(s)
    _draw_foreground(s)
    _draw_rank_flourish(s)

func _draw_cloud_shadows(s: Vector2) -> void:
    var drift: float = 0.0 if reduced_motion else fmod(t*4.0,s.x+180.0)-90.0
    for i in range(3):
        var x: float = drift + float(i)*155.0
        var y: float = s.y*(0.28+float(i%2)*0.10)
        draw_circle(Vector2(x,y),38.0,Color(0.10,0.18,0.13,0.035))
        draw_circle(Vector2(x+34.0,y+7.0),29.0,Color(0.10,0.18,0.13,0.028))

func _draw_motes(s: Vector2) -> void:
    var count: int = 8 + rank*2
    for i in range(count):
        var phase: float = float(i)*1.91
        var x: float = fmod(float(i)*53.0 + (0.0 if reduced_motion else t*(7.0+float(i%3))),s.x+16.0)-8.0
        var y: float = s.y*(0.42 + 0.48*abs(sin(phase*0.73)))
        var bob: float = 0.0 if reduced_motion else sin(t*1.2+phase)*4.0
        var c := Color("#f1db70")
        if season == "spring": c = Color("#f4d9d8")
        elif season == "summer": c = Color("#e4d461")
        elif season == "autumn": c = Color("#d7904c")
        elif season == "winter": c = Color("#f7fbff")
        draw_circle(Vector2(x,y+bob),1.5+float(i%2),Color(c.r,c.g,c.b,0.55))

func _draw_foreground(s: Vector2) -> void:
    var base_y: float = s.y*0.965
    for i in range(10):
        var x: float = float(i)*s.x/9.0
        var h: float = 18.0 + float((i*7)%13)
        var green := Color("#315d42") if season != "autumn" else Color("#6e5638")
        if season == "winter": green = Color("#64786f")
        draw_circle(Vector2(x,base_y),h,Color(green.r,green.g,green.b,0.95))
        draw_circle(Vector2(x+8.0,base_y-7.0),h*0.62,Color(green.lightened(0.08).r,green.lightened(0.08).g,green.lightened(0.08).b,0.95))
    draw_rect(Rect2(0,s.y-5.0,s.x,8.0),Color("#244331"))

func _draw_rank_flourish(s: Vector2) -> void:
    if rank < 2:
        return
    var left := Vector2(s.x*0.07,s.y*0.90)
    var right := Vector2(s.x*0.92,s.y*0.90)
    for p in [left,right]:
        draw_line(p,p+Vector2(0,-24),Color("#6c5237"),2.0)
        for k in range(rank-1):
            var a: float = -1.9 + float(k)*0.52
            var leaf: Vector2 = p+Vector2(cos(a),sin(a))*float(9+k*4)
            draw_circle(leaf,3.5,Color("#8bb866") if season != "autumn" else Color("#cc8b4e"))
    if rank >= 4:
        var pulse: float = 0.65 if reduced_motion else 0.55+sin(t*2.1)*0.12
        draw_circle(Vector2(s.x*0.50,s.y*0.105),3.0+float(rank),Color(1.0,0.82,0.32,pulse))
