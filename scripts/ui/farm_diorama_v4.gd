class_name FarmDioramaV4
extends "res://scripts/ui/farm_diorama_v3.gd"

# Visual Pass 2: the approved target is warm and luminous, but not washed out.
# This pass restores material contrast, contact readability and vegetation
# density while preserving the existing interaction / FTUE contract.

var visual_pass: int = 2
var visual_target_id: String = "satoyama-premium-2026-09-15"

func _build_world() -> void:
    world_root = Node3D.new()
    world_root.name = "SatoyamaDioramaV4"
    viewport_3d.add_child(world_root)

    var env_node := WorldEnvironment.new()
    env_node.name = "PremiumEnvironment"
    var env := Environment.new()
    env.background_mode = Environment.BG_COLOR
    env.background_color = Color("#b9d4d8")
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color("#d7ddd1")
    # V3 was over-lit on iPhone WebGL and flattened nearly every material.
    env.ambient_light_energy = 0.36
    env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
    env_node.environment = env
    world_root.add_child(env_node)

    sun = DirectionalLight3D.new()
    sun.name = "WarmKeyLight"
    sun.light_color = Color("#f7ddb0")
    sun.light_energy = 0.88
    sun.shadow_enabled = true
    sun.rotation_degrees = Vector3(-51,-37,0)
    world_root.add_child(sun)

    var fill := DirectionalLight3D.new()
    fill.name = "CoolFillLight"
    fill.light_color = Color("#b8d0d2")
    fill.light_energy = 0.10
    fill.shadow_enabled = false
    fill.rotation_degrees = Vector3(-24,142,0)
    world_root.add_child(fill)

    camera = Camera3D.new()
    camera.name = "DioramaCamera"
    camera.projection = Camera3D.PROJECTION_ORTHOGONAL
    camera.size = 10.95
    world_root.add_child(camera)
    # Slightly lower / closer than V3. The farm should feel like a miniature
    # world the player can care for, not a distant planning board.
    camera.position = Vector3(9.6,9.1,14.8)
    camera.look_at(Vector3(0.0,0.54,0.62),Vector3.UP)
    camera.current = true

    _build_landscape()
    _build_facilities()
    _build_player()
    _rebuild_restore_patch()

func _build_landscape() -> void:
    super._build_landscape()

    # Mid-frequency vegetation fills the visual gap between large trees and
    # tiny flowers. This is what makes the diorama feel inhabited rather than
    # assembled from isolated primitives.
    var bush_positions := [
        Vector3(-5.10,0.05,-1.65), Vector3(-4.55,0.05,-0.90),
        Vector3(-4.95,0.05,1.85), Vector3(-3.75,0.05,3.70),
        Vector3(-2.70,0.05,-3.05), Vector3(-1.60,0.05,-3.22),
        Vector3(0.85,0.05,-3.20), Vector3(1.85,0.05,-3.05),
        Vector3(3.62,0.05,-0.55), Vector3(3.78,0.05,0.75),
        Vector3(4.10,0.05,2.18), Vector3(4.65,0.05,3.00)
    ]
    for i in range(bush_positions.size()):
        _bush(bush_positions[i],0.32+float(i%3)*0.045,i%4==0)

    # Soft grass clumps break up the large flat ground planes without making
    # the phone-size scene noisy.
    var grass_positions := [
        Vector3(-5.45,0.06,2.45), Vector3(-4.55,0.06,2.90),
        Vector3(-3.55,0.06,-2.35), Vector3(-2.35,0.06,-2.82),
        Vector3(-0.25,0.06,-3.18), Vector3(1.10,0.06,3.85),
        Vector3(3.70,0.06,3.80), Vector3(4.70,0.06,1.45),
        Vector3(4.52,0.06,-1.20), Vector3(-0.95,0.06,4.10)
    ]
    for i in range(grass_positions.size()):
        _grass_clump(grass_positions[i],i)

func _spring_tree(pos: Vector3, scale_value: float, blossom: bool) -> void:
    var root := Node3D.new()
    root.position = pos
    root.scale = Vector3.ONE * scale_value
    world_root.add_child(root)

    _cylinder_child(root,Vector3(0,0.40,0),0.085,0.82,Color("#624936"),9)
    var crown := Color("#dc9fa9") if blossom else Color("#4e7d49")
    var light := Color("#efc0c6") if blossom else Color("#78a25c")
    var dark := crown.darkened(0.12)

    # Five overlapping lobes read as a handcrafted canopy while remaining
    # cheap enough for the compatibility renderer on iPhone.
    _sphere_child(root,Vector3(0.00,0.98,0.00),0.38,crown)
    _sphere_child(root,Vector3(-0.29,0.88,0.06),0.27,dark)
    _sphere_child(root,Vector3(0.29,0.87,-0.04),0.28,crown)
    _sphere_child(root,Vector3(-0.08,1.23,0.02),0.27,light)
    _sphere_child(root,Vector3(0.18,1.12,0.15),0.24,light.darkened(0.04))

func _mountain(pos: Vector3, radius: float, height: float, body: Color, snow_ratio: float) -> void:
    # Muted mountain / snow values keep the background atmospheric instead of
    # competing with the interactive farm.
    _cone("MountainBodyV4",pos,radius,height,body.darkened(0.08))
    var snow_height := height * snow_ratio * 0.31
    var snow_y := pos.y + height * 0.5 - snow_height * 0.54
    _cone("MountainSnowV4",Vector3(pos.x,snow_y,pos.z),radius*0.33,snow_height,Color("#e5ece8"))

func _bush(pos: Vector3, radius: float, flowering: bool) -> void:
    var root := Node3D.new()
    root.position = pos
    world_root.add_child(root)
    var base := Color("#446f46")
    var light := Color("#6f9c55")
    _sphere_child(root,Vector3(-radius*0.45,radius*0.68,0),radius*0.78,base)
    _sphere_child(root,Vector3(radius*0.38,radius*0.72,0.04),radius*0.72,light)
    _sphere_child(root,Vector3(0,radius*1.02,-0.04),radius*0.66,light.darkened(0.04))
    if flowering:
        _sphere_child(root,Vector3(-radius*0.20,radius*1.20,0.10),radius*0.13,Color("#edc0c2"))
        _sphere_child(root,Vector3(radius*0.27,radius*1.08,-0.02),radius*0.11,Color("#f0dfad"))

func _grass_clump(pos: Vector3, seed_value: int) -> void:
    var root := Node3D.new()
    root.position = pos
    world_root.add_child(root)
    for i in range(3):
        var x := -0.055 + float(i)*0.055
        var h := 0.15 + float((seed_value+i)%3)*0.025
        var stem := _cylinder_child(root,Vector3(x,h*0.5,0.02*float(i%2)),0.012,h,Color("#527d49"),5)
        stem.rotation_degrees.z = -8.0 + float(i)*8.0

func _material(color: Color) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    # A small value compression keeps ivory / snow / path surfaces from
    # clipping to pure white under WebGL while preserving the approved palette.
    material.albedo_color = color.darkened(0.055)
    material.roughness = 0.94
    return material
