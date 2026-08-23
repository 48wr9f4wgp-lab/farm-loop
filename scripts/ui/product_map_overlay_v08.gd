class_name ProductMapOverlayV08
extends "res://scripts/ui/product_map_overlay_v07.gd"

const COOP_TEX: Texture2D = preload("res://assets/art/coop_v08.svg")
const COMPOST_TEX: Texture2D = preload("res://assets/art/compost_v08.svg")
const MUSHROOM_TEX: Texture2D = preload("res://assets/art/mushroom_v08.svg")
const SANSAI_TEX: Texture2D = preload("res://assets/art/sansai_v08.svg")
const BEE_TEX: Texture2D = preload("res://assets/art/bee_v08.svg")
const PLAYER_TEX: Texture2D = preload("res://assets/art/player_v08.svg")

func _draw() -> void:
    var s: Vector2 = size
    if s.x <= 0.0 or s.y <= 0.0:
        return
    _draw_horizon_haze(s)
    _draw_birds(s)
    _draw_field_texture(s)
    _draw_water_glints(s)
    _draw_motes(s)
    _draw_asset_layer(s)
    _draw_selected_focus(s)
    _draw_ready_badges(s)
    _draw_foreground(s)
    _draw_frame(s)

func _draw_asset_layer(s: Vector2) -> void:
    var map_ref = get_parent()
    if map_ref == null:
        return
    var facilities_value = map_ref.get("facilities")
    if not (facilities_value is Dictionary):
        return
    var facilities: Dictionary = facilities_value
    _draw_facility_texture(s,facilities,"coop",COOP_TEX,Vector2(78,78),Vector2(0,-8))
    _draw_facility_texture(s,facilities,"compost",COMPOST_TEX,Vector2(76,76),Vector2(0,-8))
    _draw_facility_texture(s,facilities,"mushroom",MUSHROOM_TEX,Vector2(82,76),Vector2(0,-6))
    _draw_facility_texture(s,facilities,"sansai",SANSAI_TEX,Vector2(86,76),Vector2(0,-4))
    _draw_facility_texture(s,facilities,"bee",BEE_TEX,Vector2(82,76),Vector2(0,-4))

    var player_value = map_ref.get("player_pos")
    if player_value is Vector2:
        var n: Vector2 = player_value
        var p := Vector2(n.x*s.x,n.y*s.y)
        var bob: float = 0.0
        var walking_value = map_ref.get("walking")
        if bool(walking_value) and not reduced_motion:
            bob = abs(sin(t*8.5))*2.5
        var rect := Rect2(p+Vector2(-23,-38-bob),Vector2(46,61))
        draw_texture_rect(PLAYER_TEX,rect,false,Color.WHITE)

func _draw_facility_texture(s: Vector2, facilities: Dictionary, id: String, texture: Texture2D, draw_size: Vector2, offset: Vector2) -> void:
    if not facilities.has(id):
        return
    var n: Vector2 = facilities[id]["p"]
    var p := Vector2(n.x*s.x,n.y*s.y)+offset
    var rect := Rect2(p-draw_size*0.5,draw_size)
    draw_texture_rect(texture,rect,false,Color.WHITE)

func _draw_ready_badges(s: Vector2) -> void:
    var map_ref = get_parent()
    if map_ref == null:
        return
    var facilities_value = map_ref.get("facilities")
    var ready_value = map_ref.get("readiness")
    if not (facilities_value is Dictionary) or not (ready_value is Dictionary):
        return
    var facilities: Dictionary = facilities_value
    var readiness: Dictionary = ready_value
    for id in facilities:
        var ready: bool = true if id == "compost" else bool(readiness.get(id,false))
        if not ready:
            continue
        var n: Vector2 = facilities[id]["p"]
        var p := Vector2(n.x*s.x,n.y*s.y)+Vector2(29,-30)
        var pulse: float = 0.0 if reduced_motion else (sin(t*3.1+float(id.hash()%7))+1.0)*1.4
        draw_circle(p,10.5+pulse,Color(1.0,0.78,0.22,0.18))
        draw_circle(p,8.0,Color("#e1b84d"))
        draw_circle(p,4.6,Color("#fff8e9"))
        draw_circle(p,2.1,Color("#e1b84d"))
