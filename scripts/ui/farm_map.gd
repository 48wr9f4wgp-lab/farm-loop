class_name FarmMap
extends Control

signal facility_selected(facility_id: String)
signal player_arrived(facility_id: String)

const GREEN := Color("#4f8058")
const DARK_GREEN := Color("#315a43")
const PATH := Color("#c8b388")
const WATER := Color("#6ba9b2")
const OUTLINE := Color("#203d31")

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

var facilities := {
    "coop": {"p":Vector2(0.18,0.57),"name":"鶏舎","mark":"鶏","color":Color("#d99a50")},
    "compost": {"p":Vector2(0.47,0.48),"name":"堆肥","mark":"堆","color":Color("#7b6a4a")},
    "mushroom": {"p":Vector2(0.80,0.57),"name":"原木林","mark":"茸","color":Color("#756354")},
    "sansai": {"p":Vector2(0.31,0.78),"name":"山菜","mark":"菜","color":Color("#5e994f")},
    "bee": {"p":Vector2(0.70,0.79),"name":"蜂場","mark":"蜂","color":Color("#cca23f")}
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
    target_pos = facilities[id]["p"]
    arrival_emitted = false
    if reduced_motion:
        player_pos = target_pos
        arrival_emitted = true
        player_arrived.emit(id)
    queue_redraw()

func play_action_feedback(id: String) -> void:
    action_facility = id
    action_timer = 0.52
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
        var d: float = norm.distance_to(facilities[id]["p"])
        if d < nearest_d:
            nearest_d = d
            nearest = id
    if nearest_d <= 0.115:
        selected_facility = nearest
        facility_selected.emit(nearest)
        focus_facility(nearest)
    else:
        selected_facility = ""
        target_facility = ""
        target_pos = Vector2(clampf(norm.x,0.07,0.93), clampf(norm.y,0.48,0.91))
        arrival_emitted = true
    queue_redraw()
    accept_event()

func _process(delta: float) -> void:
    if action_timer > 0.0:
        action_timer = maxf(0.0, action_timer - delta)
        queue_redraw()
    if reduced_motion:
        return
    if player_pos.distance_to(target_pos) > 0.004:
        player_pos = player_pos.move_toward(target_pos, delta * 0.56)
        queue_redraw()
    elif not arrival_emitted and target_facility != "":
        arrival_emitted = true
        player_arrived.emit(target_facility)

func _draw() -> void:
    var s := size
    if s.x <= 0.0 or s.y <= 0.0:
        return
    _draw_environment(s)
    _draw_land_details(s)
    for id in facilities:
        _draw_facility(id, s)
    _draw_player(s)
    _draw_weather(s)

func _draw_environment(s: Vector2) -> void:
    var sky := Color("#9dc8d1")
    var ground := Color("#72a060")
    if season == "summer":
        sky = Color("#8fc3d0"); ground = Color("#4e8650")
    elif season == "autumn":
        sky = Color("#a9c6ca"); ground = Color("#9b824e")
    elif season == "winter":
        sky = Color("#c7d7db"); ground = Color("#d7e2df")
    draw_rect(Rect2(Vector2.ZERO, s), sky)
    draw_circle(Vector2(s.x*0.81,s.y*0.16), 25.0, Color("#fff0a9"))
    draw_colored_polygon(PackedVector2Array([
        Vector2(-35,s.y*.45),Vector2(s.x*.23,s.y*.13),Vector2(s.x*.54,s.y*.45)
    ]), Color("#587461"))
    draw_colored_polygon(PackedVector2Array([
        Vector2(s.x*.20,s.y*.45),Vector2(s.x*.61,s.y*.16),Vector2(s.x*1.10,s.y*.45)
    ]), Color("#6d8874"))
    if season == "winter":
        draw_colored_polygon(PackedVector2Array([
            Vector2(s.x*.39,s.y*.31),Vector2(s.x*.61,s.y*.16),Vector2(s.x*.80,s.y*.33)
        ]), Color("#f1f5f3"))
    draw_rect(Rect2(0,s.y*.40,s.x,s.y*.60), ground)
    draw_colored_polygon(PackedVector2Array([
        Vector2(s.x*.04,s.y*.69),Vector2(s.x*.96,s.y*.55),Vector2(s.x*.98,s.y*.64),Vector2(s.x*.08,s.y*.82)
    ]), PATH)
    draw_colored_polygon(PackedVector2Array([
        Vector2(s.x*.56,s.y),Vector2(s.x*.70,s.y*.62),Vector2(s.x*.84,s.y*.60),Vector2(s.x*.74,s.y)
    ]), WATER)

func _draw_land_details(s: Vector2) -> void:
    for i in range(4):
        var y := s.y * (0.54 + i*0.052)
        draw_line(Vector2(s.x*.04,y), Vector2(s.x*.32,y-18), Color("#d3c27f").lerp(GREEN,0.25), 5.0)
    for i in range(7):
        var x := s.x * (0.58 + i*0.058)
        var y := s.y * (0.42 + (i%2)*0.025)
        var c := DARK_GREEN
        if season == "autumn":
            c = Color("#8c653d") if i%2==0 else Color("#a47a43")
        elif season == "winter":
            c = Color("#6f8278")
        draw_circle(Vector2(x,y), 12.0, c.darkened(0.14))
        draw_circle(Vector2(x,y-6), 14.0, c)
    if season == "winter":
        for i in range(5):
            draw_circle(Vector2(s.x*(0.10+i*.19),s.y*.67), 13.0, Color("#eef4f2"))

func _draw_facility(id: String, s: Vector2) -> void:
    var f: Dictionary = facilities[id]
    var p: Vector2 = Vector2(f["p"].x*s.x, f["p"].y*s.y)
    var radius := 27.0
    if selected_facility == id:
        draw_circle(p, radius+7.0, Color("#fff0a3"))
    if action_facility == id and action_timer > 0.0:
        var pulse := 7.0 + (1.0-action_timer/0.52)*12.0
        draw_arc(p, radius+pulse, 0, TAU, 36, Color("#fff5c8"), 4.0)
    var ready := bool(readiness.get(id, false))
    if id == "compost":
        ready = true
    var base: Color = f["color"]
    draw_circle(p, radius, OUTLINE.lightened(0.02))
    draw_circle(p-Vector2(0,4), radius-3.0, base if ready else base.darkened(0.28))
    draw_rect(Rect2(p+Vector2(-17,4),Vector2(34,13)), base.darkened(0.18))
    draw_colored_polygon(PackedVector2Array([
        p+Vector2(-20,4), p+Vector2(0,-14), p+Vector2(20,4)
    ]), base.lightened(0.18))
    var font := ThemeDB.fallback_font
    draw_string(font, p+Vector2(-10,9), str(f["mark"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)
    if ready:
        draw_circle(p+Vector2(20,-21), 7.0, Color("#efbf4c"))
        draw_circle(p+Vector2(20,-21), 3.0, Color.WHITE)

func _draw_player(s: Vector2) -> void:
    var p := Vector2(player_pos.x*s.x, player_pos.y*s.y)
    draw_ellipse_shadow(p)
    draw_circle(p+Vector2(0,-10), 9.0, Color("#f0c8a7"))
    draw_circle(p+Vector2(0,7), 12.0, Color("#355f48"))
    draw_colored_polygon(PackedVector2Array([
        p+Vector2(-10,-16),p+Vector2(0,-25),p+Vector2(11,-16)
    ]), Color("#b88943"))

func draw_ellipse_shadow(p: Vector2) -> void:
    draw_set_transform(p,0.0,Vector2(1.5,0.45))
    draw_circle(Vector2(0,28), 10.0, Color(0,0,0,0.18))
    draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE)

func _draw_weather(s: Vector2) -> void:
    if weather in ["雨","強雨"]:
        for i in range(24):
            var x := float((i*71)%389)/389.0*s.x
            var y := float((i*43)%251)/251.0*s.y
            draw_line(Vector2(x,y),Vector2(x-4,y+12),Color("#d9eef4aa"),2.0)
    elif weather in ["雪","大雪"]:
        var count := 34 if weather == "雪" else 58
        for i in range(count):
            var x := float((i*67)%389)/389.0*s.x
            var y := float((i*41)%257)/257.0*s.y
            draw_circle(Vector2(x,y),2.2,Color("#ffffffdd"))
