class_name FarmMap
extends Control

signal facility_selected(facility_id: String)
signal player_arrived(facility_id: String)

const FOREST := Color("#315a43")
const FOREST_MID := Color("#4f8058")
const LEAF := Color("#7eb35e")
const EARTH := Color("#8a6444")
const WOOD := Color("#9b6d47")
const WOOD_DARK := Color("#5d4635")
const PATH := Color("#c8b388")
const WATER := Color("#6ba9b2")
const WATER_LIGHT := Color("#a6d6d8")
const SNOW := Color("#eef5f3")
const INK := Color("#193126")
const GOLD := Color("#e1b84d")
const PAPER := Color("#fff8e9")

var season := "spring"
var weather := "晴れ"
var readiness: Dictionary = {}
var selected_facility := ""
var player_pos := Vector2(0.50, 0.86)
var target_pos := player_pos
var target_facility := ""
var action_facility := ""
var action_timer := 0.0
var arrival_emitted := true
var reduced_motion := false
var ambient_time := 0.0
var walking := false

var facilities := {
    "coop": {"p":Vector2(0.18,0.59),"name":"鶏舎"},
    "compost": {"p":Vector2(0.47,0.48),"name":"堆肥舎"},
    "mushroom": {"p":Vector2(0.80,0.58),"name":"原木林"},
    "sansai": {"p":Vector2(0.31,0.79),"name":"山菜区画"},
    "bee": {"p":Vector2(0.71,0.79),"name":"蜂場"}
}

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_STOP
    set_process(true)
    queue_redraw()

func set_state(new_season: String, new_weather: String, ready_state: Dictionary, selected: String = "", reduce_motion: bool = false) -> void:
    season = new_season
    weather = new_weather
    readiness = ready_state.duplicate(true)
    selected_facility = selected
    reduced_motion = reduce_motion
    queue_redraw()

func focus_facility(id: String) -> void:
    if not facilities.has(id):
        return
    selected_facility = id
    target_facility = id
    var f: Dictionary = facilities[id]
    target_pos = f["p"]
    arrival_emitted = false
    if reduced_motion:
        player_pos = target_pos
        walking = false
        arrival_emitted = true
        player_arrived.emit(id)
    queue_redraw()

func play_action_feedback(id: String) -> void:
    action_facility = id
    action_timer = 0.62
    queue_redraw()

func _gui_input(event: InputEvent) -> void:
    var point := Vector2.ZERO
    var accepted := false
    if event is InputEventScreenTouch and event.pressed:
        point = event.position
        accepted = true
    elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
        point = event.position
        accepted = true
    if not accepted:
        return
    var norm := Vector2(point.x / maxf(size.x, 1.0), point.y / maxf(size.y, 1.0))
    var nearest := ""
    var nearest_d := 999.0
    for id in facilities:
        var f: Dictionary = facilities[id]
        var fp: Vector2 = f["p"]
        var d: float = norm.distance_to(fp)
        if d < nearest_d:
            nearest_d = d
            nearest = id
    if nearest_d <= 0.125:
        selected_facility = nearest
        facility_selected.emit(nearest)
        focus_facility(nearest)
    else:
        selected_facility = ""
        target_facility = ""
        target_pos = Vector2(clampf(norm.x,0.07,0.93), clampf(norm.y,0.47,0.91))
        arrival_emitted = true
    queue_redraw()
    accept_event()

func _process(delta: float) -> void:
    if not reduced_motion:
        ambient_time += delta
    if action_timer > 0.0:
        action_timer = maxf(0.0, action_timer - delta)
    walking = false
    if not reduced_motion and player_pos.distance_to(target_pos) > 0.004:
        walking = true
        player_pos = player_pos.move_toward(target_pos, delta * 0.56)
    elif not arrival_emitted and target_facility != "":
        arrival_emitted = true
        player_arrived.emit(target_facility)
    queue_redraw()

func _draw() -> void:
    var s: Vector2 = size
    if s.x <= 0.0 or s.y <= 0.0:
        return
    _draw_environment(s)
    _draw_terrain_details(s)
    _draw_ambient_life(s)
    for id in facilities:
        _draw_facility(id, s)
    _draw_player(s)
    _draw_weather(s)

func _ground_color() -> Color:
    if season == "summer":
        return Color("#4e8650")
    if season == "autumn":
        return Color("#9a824e")
    if season == "winter":
        return Color("#d9e5e1")
    return Color("#72a060")

func _sky_color() -> Color:
    if season == "summer":
        return Color("#8fc3d0")
    if season == "autumn":
        return Color("#a8c4c7")
    if season == "winter":
        return Color("#cbdadd")
    return Color("#9dc8d1")

func _draw_environment(s: Vector2) -> void:
    var sky: Color = _sky_color()
    var ground: Color = _ground_color()
    draw_rect(Rect2(Vector2.ZERO, s), sky)
    draw_circle(Vector2(s.x*0.81,s.y*0.145), 24.0, Color("#fff0a9"))
    draw_circle(Vector2(s.x*0.81,s.y*0.145), 34.0, Color(1.0,0.93,0.58,0.10))

    draw_colored_polygon(PackedVector2Array([
        Vector2(-30,s.y*.43),Vector2(s.x*.22,s.y*.12),Vector2(s.x*.51,s.y*.43)
    ]), Color("#60786a"))
    draw_colored_polygon(PackedVector2Array([
        Vector2(s.x*.18,s.y*.43),Vector2(s.x*.59,s.y*.15),Vector2(s.x*1.10,s.y*.43)
    ]), Color("#708a77"))
    if season == "winter":
        draw_colored_polygon(PackedVector2Array([
            Vector2(s.x*.39,s.y*.30),Vector2(s.x*.59,s.y*.15),Vector2(s.x*.78,s.y*.31)
        ]), SNOW)
        draw_colored_polygon(PackedVector2Array([
            Vector2(s.x*.07,s.y*.29),Vector2(s.x*.22,s.y*.12),Vector2(s.x*.34,s.y*.29)
        ]), Color("#f6f8f7"))

    draw_rect(Rect2(0,s.y*.39,s.x,s.y*.61), ground)
    draw_colored_polygon(PackedVector2Array([
        Vector2(s.x*.02,s.y*.70),Vector2(s.x*.94,s.y*.54),Vector2(s.x*.99,s.y*.64),Vector2(s.x*.06,s.y*.83)
    ]), PATH)
    draw_colored_polygon(PackedVector2Array([
        Vector2(s.x*.55,s.y),Vector2(s.x*.68,s.y*.60),Vector2(s.x*.84,s.y*.59),Vector2(s.x*.75,s.y)
    ]), WATER)

func _draw_terrain_details(s: Vector2) -> void:
    _draw_rice_beds(s)
    _draw_tree_belt(s)
    _draw_creek(s)
    _draw_path_stones(s)
    if season == "winter":
        _draw_snow_banks(s)

func _draw_rice_beds(s: Vector2) -> void:
    for i in range(4):
        var y: float = s.y * (0.53 + float(i)*0.052)
        var bed_color := Color("#d7c77c")
        if season == "summer":
            bed_color = Color("#89b75d")
        elif season == "autumn":
            bed_color = Color("#c7a54d")
        elif season == "winter":
            bed_color = Color("#d2ddd8")
        draw_line(Vector2(s.x*.035,y), Vector2(s.x*.32,y-18), bed_color.darkened(0.12), 8.0)
        draw_line(Vector2(s.x*.04,y-2), Vector2(s.x*.31,y-20), bed_color, 4.0)
        for j in range(5):
            var t: float = float(j)/4.0
            var p: Vector2 = Vector2(s.x*.04,y-2).lerp(Vector2(s.x*.31,y-20),t)
            draw_line(p, p+Vector2(0,-5), bed_color.lightened(0.15), 1.6)

func _draw_tree_belt(s: Vector2) -> void:
    for i in range(10):
        var x: float = s.x * (0.53 + float(i)*0.052)
        var y: float = s.y * (0.405 + float(i%3)*0.018)
        var sway: float = 0.0 if reduced_motion else sin(ambient_time*0.9 + float(i))*1.4
        var c := FOREST
        if season == "spring":
            c = FOREST_MID if i%3 else LEAF
        elif season == "autumn":
            c = Color("#8c653d") if i%2==0 else Color("#a47a43")
        elif season == "winter":
            c = Color("#647970")
        draw_rect(Rect2(Vector2(x-2,y+7),Vector2(4,12)),WOOD_DARK)
        draw_circle(Vector2(x+sway,y), 12.0, c.darkened(0.12))
        draw_circle(Vector2(x+sway,y-7), 14.0, c)
        draw_circle(Vector2(x-7+sway,y-2), 9.0, c.lightened(0.04))
        if season == "winter":
            draw_circle(Vector2(x+sway,y-12),7.0,Color(0.96,0.98,0.97,0.85))

func _draw_creek(s: Vector2) -> void:
    var flow: float = 0.0 if reduced_motion else fmod(ambient_time*26.0,34.0)
    for i in range(6):
        var y: float = s.y*(0.66 + float(i)*0.06)
        var x: float = s.x*(0.68 + float(i%2)*0.035)
        draw_line(Vector2(x-flow*0.12,y),Vector2(x+18-flow*0.12,y-5),WATER_LIGHT,2.0)

func _draw_path_stones(s: Vector2) -> void:
    for i in range(7):
        var x: float = s.x*(0.39 + float(i)*0.075)
        var y: float = s.y*(0.73 - float(i)*0.024)
        draw_circle(Vector2(x,y),5.5,Color("#b2a58b"))
        draw_circle(Vector2(x-1,y-1),4.0,Color("#d2c8b4"))

func _draw_snow_banks(s: Vector2) -> void:
    for i in range(7):
        draw_circle(Vector2(s.x*(0.08+float(i)*.145),s.y*(0.67+float(i%2)*.025)), 14.0, Color("#f1f6f4"))

func _draw_ambient_life(s: Vector2) -> void:
    _draw_chickens(s)
    _draw_bees(s)
    _draw_smoke(s)

func _draw_chickens(s: Vector2) -> void:
    var base: Vector2 = Vector2(s.x*.13,s.y*.67)
    for i in range(3):
        var drift: float = 0.0 if reduced_motion else sin(ambient_time*1.7+float(i)*1.9)*5.0
        var p: Vector2 = base + Vector2(float(i)*13.0+drift, float(i%2)*7.0)
        draw_circle(p,4.3,Color("#f6efe0"))
        draw_circle(p+Vector2(3,-3),2.4,Color("#f6efe0"))
        draw_colored_polygon(PackedVector2Array([p+Vector2(5,-3),p+Vector2(8,-2),p+Vector2(5,-1)]),Color("#d9a13b"))

func _draw_bees(s: Vector2) -> void:
    if season not in ["spring","summer","autumn"]:
        return
    var center: Vector2 = Vector2(s.x*.72,s.y*.75)
    for i in range(4):
        var angle: float = ambient_time*(0.9+float(i)*0.08)+float(i)*1.55
        if reduced_motion:
            angle = float(i)*1.55
        var p: Vector2 = center + Vector2(cos(angle)*18.0,sin(angle)*9.0)
        draw_circle(p,2.0,Color("#e7b83f"))
        draw_line(p+Vector2(-1.5,0),p+Vector2(1.5,0),INK,1.0)

func _draw_smoke(s: Vector2) -> void:
    var p: Vector2 = Vector2(s.x*.455,s.y*.42)
    for i in range(3):
        var rise: float = float(i)*10.0
        var wobble: float = 0.0 if reduced_motion else sin(ambient_time*0.8+float(i))*3.0
        draw_circle(p+Vector2(wobble,-rise),5.5+float(i)*1.5,Color(0.92,0.92,0.88,0.16-float(i)*0.03))

func _facility_position(id: String, s: Vector2) -> Vector2:
    var f: Dictionary = facilities[id]
    var n: Vector2 = f["p"]
    return Vector2(n.x*s.x,n.y*s.y)

func _draw_facility(id: String, s: Vector2) -> void:
    var p: Vector2 = _facility_position(id,s)
    if selected_facility == id:
        draw_circle(p+Vector2(0,8),39.0,Color(1.0,0.88,0.42,0.22))
        draw_arc(p+Vector2(0,8),38.0,0,TAU,40,Color("#ffe49a"),3.0)
    if action_facility == id and action_timer > 0.0:
        var t: float = 1.0-action_timer/0.62
        draw_arc(p+Vector2(0,4),34.0+t*18.0,0,TAU,40,Color(1.0,0.95,0.72,1.0-t),4.0)

    if id == "coop":
        _draw_coop(p)
    elif id == "compost":
        _draw_compost(p)
    elif id == "mushroom":
        _draw_mushroom(p)
    elif id == "sansai":
        _draw_sansai(p)
    elif id == "bee":
        _draw_hives(p)

    var ready: bool = bool(readiness.get(id,false))
    if id == "compost":
        ready = true
    if ready:
        _draw_ready_marker(p+Vector2(26,-28))

func _draw_building_shadow(p: Vector2, width: float) -> void:
    draw_set_transform(p+Vector2(0,23),0.0,Vector2(1.7,0.45))
    draw_circle(Vector2.ZERO,width,Color(0,0,0,0.16))
    draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE)

func _draw_coop(p: Vector2) -> void:
    _draw_building_shadow(p,17.0)
    draw_rect(Rect2(p+Vector2(-21,-3),Vector2(42,28)),Color("#c98548"))
    draw_colored_polygon(PackedVector2Array([p+Vector2(-25,-3),p+Vector2(0,-23),p+Vector2(25,-3)]),Color("#7b4937"))
    draw_rect(Rect2(p+Vector2(-7,7),Vector2(14,18)),Color("#5a3e31"))
    draw_circle(p+Vector2(0,12),4.5,Color("#f2d18c"))
    draw_line(p+Vector2(-27,25),p+Vector2(27,25),Color("#e5d7b7"),3.0)
    for x in [-22.0,-11.0,0.0,11.0,22.0]:
        draw_line(p+Vector2(x,18),p+Vector2(x,31),Color("#e5d7b7"),2.0)

func _draw_compost(p: Vector2) -> void:
    _draw_building_shadow(p,18.0)
    draw_colored_polygon(PackedVector2Array([p+Vector2(-25,-7),p+Vector2(0,-20),p+Vector2(25,-7)]),Color("#66523c"))
    draw_line(p+Vector2(-21,-5),p+Vector2(-21,23),WOOD_DARK,5.0)
    draw_line(p+Vector2(21,-5),p+Vector2(21,23),WOOD_DARK,5.0)
    draw_rect(Rect2(p+Vector2(-20,4),Vector2(40,20)),Color("#756344"))
    draw_rect(Rect2(p+Vector2(-17,7),Vector2(34,5)),Color("#5e7f4d"))
    draw_rect(Rect2(p+Vector2(-17,13),Vector2(34,5)),Color("#9b744b"))
    draw_rect(Rect2(p+Vector2(-17,19),Vector2(34,4)),Color("#443d31"))

func _draw_mushroom(p: Vector2) -> void:
    _draw_building_shadow(p,19.0)
    for i in range(4):
        var y: float = -10.0+float(i)*9.0
        draw_line(p+Vector2(-23,y),p+Vector2(20,y+4),Color("#6b523c"),7.0)
        draw_circle(p+Vector2(-23,y),3.3,Color("#baa078"))
        draw_circle(p+Vector2(20,y+4),3.3,Color("#baa078"))
    draw_circle(p+Vector2(-8,-17),7.0,Color("#bf6c53"))
    draw_rect(Rect2(p+Vector2(-10,-14),Vector2(4,8)),Color("#e8dcc4"))
    draw_circle(p+Vector2(13,-12),6.0,Color("#d39a61"))
    draw_rect(Rect2(p+Vector2(11,-10),Vector2(4,7)),Color("#e8dcc4"))

func _draw_sansai(p: Vector2) -> void:
    _draw_building_shadow(p,20.0)
    for row in range(3):
        var y: float = -5.0+float(row)*10.0
        draw_line(p+Vector2(-27,y),p+Vector2(27,y-5),EARTH,8.0)
        for i in range(5):
            var x: float = -22.0+float(i)*11.0
            var base: Vector2 = p+Vector2(x,y-4.0-float(i%2)*2.0)
            draw_line(base,base+Vector2(0,-7),FOREST,1.5)
            draw_circle(base+Vector2(-3,-7),3.5,LEAF)
            draw_circle(base+Vector2(3,-8),3.5,LEAF.lightened(0.08))

func _draw_hives(p: Vector2) -> void:
    _draw_building_shadow(p,19.0)
    for i in range(3):
        var x: float = -22.0+float(i)*22.0
        draw_rect(Rect2(p+Vector2(x,-6),Vector2(17,25)),Color("#d6aa4c"))
        draw_rect(Rect2(p+Vector2(x-2,-10),Vector2(21,5)),Color("#79523a"))
        draw_line(p+Vector2(x+3,1),p+Vector2(x+14,1),Color("#f0d978"),2.0)
        draw_line(p+Vector2(x+3,8),p+Vector2(x+14,8),Color("#f0d978"),2.0)
        draw_rect(Rect2(p+Vector2(x+6,15),Vector2(5,3)),INK)

func _draw_ready_marker(p: Vector2) -> void:
    var pulse: float = 0.0 if reduced_motion else (sin(ambient_time*3.0)+1.0)*1.8
    draw_circle(p,10.0+pulse,Color(1.0,0.78,0.22,0.18))
    draw_circle(p,8.5,GOLD)
    draw_circle(p,5.8,PAPER)
    draw_circle(p,2.5,GOLD)

func _draw_player(s: Vector2) -> void:
    var p: Vector2 = Vector2(player_pos.x*s.x,player_pos.y*s.y)
    var bob: float = 0.0
    if walking and not reduced_motion:
        bob = abs(sin(ambient_time*8.5))*3.0
    p.y -= bob
    _draw_player_shadow(p,bob)
    var step: float = 0.0 if reduced_motion else sin(ambient_time*8.5)*3.0 if walking else 0.0
    draw_line(p+Vector2(-4,15),p+Vector2(-5-step,27),INK,4.0)
    draw_line(p+Vector2(4,15),p+Vector2(5+step,27),INK,4.0)
    draw_circle(p+Vector2(0,-9),8.5,Color("#efc5a1"))
    draw_rect(Rect2(p+Vector2(-9,-1),Vector2(18,19)),Color("#355f48"))
    draw_rect(Rect2(p+Vector2(7,2),Vector2(6,13)),Color("#9b6d47"))
    draw_colored_polygon(PackedVector2Array([p+Vector2(-12,-15),p+Vector2(0,-25),p+Vector2(13,-15)]),Color("#b88943"))
    draw_line(p+Vector2(-13,-15),p+Vector2(14,-15),Color("#8a633d"),3.0)

func _draw_player_shadow(p: Vector2, bob: float) -> void:
    var alpha: float = 0.18-maxf(0.0,bob)*0.012
    draw_set_transform(p+Vector2(0,29),0.0,Vector2(1.5,0.42))
    draw_circle(Vector2.ZERO,9.0,Color(0,0,0,alpha))
    draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE)

func _draw_weather(s: Vector2) -> void:
    var offset: float = 0.0 if reduced_motion else ambient_time*28.0
    if weather in ["雨","強雨"]:
        var count: int = 28 if weather == "雨" else 42
        for i in range(count):
            var x: float = fmod(float(i*71)+offset*0.35,s.x+20.0)-10.0
            var y: float = fmod(float(i*43)+offset,s.y+20.0)-10.0
            draw_line(Vector2(x,y),Vector2(x-4,y+12),Color("#d9eef4aa"),2.0)
    elif weather in ["雪","大雪"]:
        var count: int = 36 if weather == "雪" else 58
        for i in range(count):
            var x: float = fmod(float(i*67)+sin(float(i))*18.0+offset*0.12,s.x+20.0)-10.0
            var y: float = fmod(float(i*41)+offset*0.38,s.y+20.0)-10.0
            draw_circle(Vector2(x,y),2.2,Color("#ffffffdd"))
