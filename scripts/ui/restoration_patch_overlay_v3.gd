class_name RestorationPatchOverlayV3
extends Control

var stage: int = 0
var reduced_motion: bool = false
var t: float = 0.0

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    set_process(true)
    queue_redraw()

func set_restore_state(value: int, reduce_motion: bool = false) -> void:
    stage = clampi(value,0,2)
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

    # The proof patch sits around the sansai terrace. It deliberately changes
    # terrain, vegetation and ambient life so restoration is readable without
    # relying on a progress number.
    var center := Vector2(s.x * 0.31,s.y * 0.79)
    _draw_terrain(center,s)
    _draw_vegetation(center)
    _draw_life(center)

func _draw_terrain(center: Vector2, s: Vector2) -> void:
    var width: float = minf(136.0,s.x * 0.38)
    var height: float = 70.0
    var rect := Rect2(center.x-width*0.5,center.y-height*0.42,width,height)

    if stage == 0:
        draw_style_box(_patch_box(Color("#806d55"),Color("#5d5649")),rect)
        for i in range(5):
            var y: float = rect.position.y + 15.0 + float(i)*10.0
            draw_line(Vector2(rect.position.x+12.0,y),Vector2(rect.end.x-12.0,y-5.0),Color(0.28,0.25,0.20,0.36),2.0)
        for i in range(4):
            var x: float = rect.position.x + 25.0 + float(i)*25.0
            draw_line(Vector2(x,rect.position.y+14.0),Vector2(x+6.0,rect.end.y-12.0),Color(0.35,0.30,0.24,0.28),1.4)
    elif stage == 1:
        draw_style_box(_patch_box(Color("#657c4d"),Color("#45613d")),rect)
        draw_rect(Rect2(rect.position+Vector2(8,8),rect.size-Vector2(16,16)),Color(0.34,0.50,0.29,0.18))
        for i in range(4):
            var y2: float = rect.position.y + 18.0 + float(i)*11.0
            draw_line(Vector2(rect.position.x+12.0,y2),Vector2(rect.end.x-12.0,y2-4.0),Color("#78975c"),2.2)
    else:
        draw_style_box(_patch_box(Color("#5e8a4f"),Color("#315a43")),rect)
        draw_rect(Rect2(rect.position+Vector2(6,6),rect.size-Vector2(12,12)),Color(0.48,0.68,0.35,0.16))
        for i in range(5):
            var y3: float = rect.position.y + 14.0 + float(i)*10.0
            draw_line(Vector2(rect.position.x+10.0,y3),Vector2(rect.end.x-10.0,y3-4.0),Color("#86ad62"),2.4)

func _patch_box(fill: Color, line: Color) -> StyleBoxFlat:
    var box := StyleBoxFlat.new()
    box.bg_color = fill
    box.border_color = line
    box.border_width_left = 2
    box.border_width_right = 2
    box.border_width_top = 2
    box.border_width_bottom = 2
    box.corner_radius_top_left = 18
    box.corner_radius_top_right = 18
    box.corner_radius_bottom_left = 22
    box.corner_radius_bottom_right = 22
    return box

func _draw_vegetation(center: Vector2) -> void:
    if stage == 0:
        for i in range(5):
            var x: float = center.x - 48.0 + float(i)*24.0
            var y: float = center.y + 23.0 - float(i%2)*5.0
            draw_line(Vector2(x,y),Vector2(x-2.0,y-12.0),Color("#746950"),2.0)
            draw_line(Vector2(x-2.0,y-8.0),Vector2(x-8.0,y-13.0),Color("#746950"),1.5)
        return

    var plant_count: int = 9 if stage == 1 else 16
    for i in range(plant_count):
        var row: int = i / 8
        var col: int = i % 8
        var x2: float = center.x - 54.0 + float(col)*15.5 + float(row)*5.0
        var y2: float = center.y + 24.0 + float(row)*10.0 - float(col%2)*3.0
        var sway: float = 0.0 if reduced_motion else sin(t*1.4+float(i))*1.2
        var h: float = 9.0 + float((i*3)%6)
        var stem := Color("#426b3d") if stage == 1 else Color("#315f38")
        var leaf := Color("#79a95f") if stage == 1 else Color("#8abe67")
        draw_line(Vector2(x2,y2),Vector2(x2+sway,y2-h),stem,1.8)
        draw_circle(Vector2(x2-3.0+sway,y2-h+3.0),3.5,leaf)
        draw_circle(Vector2(x2+3.0+sway,y2-h+1.0),3.3,leaf.lightened(0.06))

    if stage >= 2:
        var flower_colors := [Color("#f0d56a"),Color("#f4d9dd"),Color("#f6f0dc")]
        for j in range(7):
            var fx: float = center.x - 46.0 + float(j)*15.0
            var fy: float = center.y + 8.0 + float(j%2)*9.0
            draw_circle(Vector2(fx,fy),2.6,flower_colors[j%flower_colors.size()])

func _draw_life(center: Vector2) -> void:
    if stage == 0:
        return

    # Returning life is intentionally sparse at stage 1 and unmistakable at 2.
    var mote_count: int = 3 if stage == 1 else 7
    for i in range(mote_count):
        var phase: float = float(i)*1.31
        var dx: float = -45.0 + float(i)*15.0
        var drift: float = 0.0 if reduced_motion else sin(t*1.5+phase)*4.0
        var lift: float = 0.0 if reduced_motion else cos(t*1.2+phase)*3.0
        draw_circle(center+Vector2(dx+drift,-30.0-float(i%3)*8.0+lift),1.8,Color(0.96,0.82,0.32,0.70))

    if stage < 2:
        return

    for i in range(2):
        var phase2: float = float(i)*PI
        var angle: float = phase2 if reduced_motion else t*(0.65+float(i)*0.12)+phase2
        var p := center+Vector2(cos(angle)*42.0,-38.0+sin(angle)*13.0)
        var wing: float = 4.0 if reduced_motion else 4.0+sin(t*6.0+phase2)*1.5
        draw_line(p,p+Vector2(-wing,-3),Color("#f5efe5"),2.0)
        draw_line(p,p+Vector2(wing,-3),Color("#f5efe5"),2.0)
        draw_circle(p,1.8,Color("#4c5b48"))
