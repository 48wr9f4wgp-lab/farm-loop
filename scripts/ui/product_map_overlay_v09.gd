class_name ProductMapOverlayV09
extends "res://scripts/ui/product_map_overlay_v08.gd"

func _draw_asset_layer(s: Vector2) -> void:
    var map_ref = get_parent()
    if map_ref == null:
        return
    var facilities_value = map_ref.get("facilities")
    if not (facilities_value is Dictionary):
        return
    var facilities: Dictionary = facilities_value
    var selected: String = str(map_ref.get("selected_facility"))

    _draw_living_asset(s,facilities,"compost",COMPOST_TEX,Vector2(80,80),Vector2(0,-9),selected,0.2)
    _draw_living_asset(s,facilities,"coop",COOP_TEX,Vector2(84,84),Vector2(0,-8),selected,0.7)
    _draw_living_asset(s,facilities,"mushroom",MUSHROOM_TEX,Vector2(88,82),Vector2(0,-7),selected,1.3)
    _draw_living_asset(s,facilities,"sansai",SANSAI_TEX,Vector2(92,82),Vector2(0,-5),selected,1.9)
    _draw_living_asset(s,facilities,"bee",BEE_TEX,Vector2(88,82),Vector2(0,-5),selected,2.5)

    var player_value = map_ref.get("player_pos")
    if player_value is Vector2:
        var n: Vector2 = player_value
        var p := Vector2(n.x*s.x,n.y*s.y)
        var walking: bool = bool(map_ref.get("walking"))
        var bob: float = 0.0 if reduced_motion else (abs(sin(t*8.5))*3.0 if walking else sin(t*1.6)*0.8)
        _shadow(p+Vector2(0,22),18.0,0.15)
        var rect := Rect2(p+Vector2(-25,-42-bob),Vector2(50,66))
        draw_texture_rect(PLAYER_TEX,rect,false,Color.WHITE)

    _draw_action_flash(s,map_ref,facilities)

func _draw_living_asset(s: Vector2, facilities: Dictionary, id: String, texture: Texture2D, base_size: Vector2, offset: Vector2, selected: String, phase: float) -> void:
    if not facilities.has(id):
        return
    var n: Vector2 = facilities[id]["p"]
    var p := Vector2(n.x*s.x,n.y*s.y)+offset
    var breathe: float = 1.0
    var lift: float = 0.0
    if not reduced_motion:
        breathe += sin(t*1.15+phase)*0.008
        lift = sin(t*1.35+phase)*0.7
    if selected == id:
        breathe += 0.035
    var draw_size := base_size*breathe
    _shadow(p+Vector2(0,draw_size.y*0.33),draw_size.x*0.24,0.16)
    var rect := Rect2(p-draw_size*0.5+Vector2(0,lift),draw_size)
    draw_texture_rect(texture,rect,false,Color.WHITE)

func _shadow(p: Vector2, radius: float, alpha: float) -> void:
    draw_set_transform(p,0.0,Vector2(1.7,0.40))
    draw_circle(Vector2.ZERO,radius,Color(0.05,0.12,0.08,alpha))
    draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE)

func _draw_action_flash(s: Vector2, map_ref: Node, facilities: Dictionary) -> void:
    var id: String = str(map_ref.get("action_facility"))
    var timer: float = float(map_ref.get("action_timer"))
    if id == "" or timer <= 0.0 or not facilities.has(id):
        return
    var n: Vector2 = facilities[id]["p"]
    var p := Vector2(n.x*s.x,n.y*s.y)
    var progress: float = 1.0-clampf(timer/0.62,0.0,1.0)
    draw_arc(p,36.0+progress*22.0,0,TAU,52,Color(1.0,0.88,0.35,1.0-progress),4.0)
    for i in range(6):
        var a: float = TAU*float(i)/6.0
        var q := p+Vector2(cos(a),sin(a))*(28.0+progress*22.0)
        draw_circle(q,3.0-progress,Color(1.0,0.91,0.52,0.9-progress*0.7))
