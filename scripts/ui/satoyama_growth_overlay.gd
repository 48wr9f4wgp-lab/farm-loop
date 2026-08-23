class_name SatoyamaGrowthOverlay
extends Control

var rank: int = 1
var ambient: float = 0.0
var reduced_motion: bool = false

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    set_process(true)
    queue_redraw()

func set_rank(value: int, reduce_motion: bool = false) -> void:
    rank = clampi(value,1,5)
    reduced_motion = reduce_motion
    queue_redraw()

func _process(delta: float) -> void:
    if not reduced_motion:
        ambient += delta
        queue_redraw()

func _draw() -> void:
    var s: Vector2 = size
    if s.x <= 0 or s.y <= 0:
        return
    if rank >= 2:
        _draw_flower_banks(s)
    if rank >= 3:
        _draw_bridge(s)
    if rank >= 4:
        _draw_lanterns(s)
    if rank >= 5:
        _draw_festival_banners(s)

func _draw_flower_banks(s: Vector2) -> void:
    var colors := [Color("#f2d675"),Color("#f2b4b4"),Color("#f7eee0"),Color("#9bc97f")]
    for i in range(12):
        var x: float = s.x*(0.08 + float(i%6)*0.055)
        var y: float = s.y*(0.87 + float(i/6)*0.035)
        var bob: float = 0.0 if reduced_motion else sin(ambient*1.3+float(i))*1.4
        draw_line(Vector2(x,y),Vector2(x,y-7+bob),Color("#4e7b4a"),1.3)
        draw_circle(Vector2(x,y-8+bob),2.7,colors[i%colors.size()])

func _draw_bridge(s: Vector2) -> void:
    var center := Vector2(s.x*.705,s.y*.70)
    draw_line(center+Vector2(-25,8),center+Vector2(25,-8),Color("#5d4635"),9.0)
    draw_line(center+Vector2(-25,5),center+Vector2(25,-11),Color("#b88958"),5.0)
    for i in range(5):
        var t: float = float(i)/4.0
        var p: Vector2 = (center+Vector2(-20,4)).lerp(center+Vector2(20,-9),t)
        draw_line(p+Vector2(-2,-5),p+Vector2(2,5),Color("#6e5138"),1.4)

func _draw_lanterns(s: Vector2) -> void:
    for i in range(4):
        var p := Vector2(s.x*(0.40+float(i)*0.105),s.y*(0.70-float(i)*0.032))
        draw_line(p,p+Vector2(0,-17),Color("#514537"),2.0)
        draw_rect(Rect2(p+Vector2(-4,-20),Vector2(8,8)),Color("#e7b94b"))
        if not reduced_motion:
            draw_circle(p+Vector2(0,-16),8.0+sin(ambient*2.0+float(i))*1.0,Color(1.0,0.78,0.30,0.08))

func _draw_festival_banners(s: Vector2) -> void:
    var start := Vector2(s.x*.42,s.y*.365)
    var end := Vector2(s.x*.79,s.y*.37)
    draw_line(start,end,Color("#5e4a37"),1.4)
    for i in range(8):
        var t: float = float(i)/7.0
        var p: Vector2 = start.lerp(end,t)
        var sway: float = 0.0 if reduced_motion else sin(ambient*1.6+float(i))*2.0
        var c := Color("#d05c4e") if i%2==0 else Color("#f0d26b")
        draw_colored_polygon(PackedVector2Array([p,p+Vector2(5+sway,9),p+Vector2(10,0)]),c)
