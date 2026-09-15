class_name FarmDioramaV2
extends "res://scripts/ui/farm_diorama_v1.gd"

# V1 proved the 3D direction and interaction contract. V2 keeps that geometry
# but fixes lifecycle details found by CI before the renderer reaches Pages.

func _notification(_what: int) -> void:
    # SubViewportContainer owns the child viewport size while stretch is true.
    # Manual resize caused warnings and is intentionally disabled in V2.
    pass

func _build_world() -> void:
    world_root = Node3D.new()
    world_root.name = "SatoyamaDiorama"
    viewport_3d.add_child(world_root)

    var env_node := WorldEnvironment.new()
    var env := Environment.new()
    env.background_mode = Environment.BG_COLOR
    env.background_color = C_SKY
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color("#dbe5d6")
    env.ambient_light_energy = 0.82
    env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
    env_node.environment = env
    world_root.add_child(env_node)

    sun = DirectionalLight3D.new()
    sun.light_color = Color("#fff1c4")
    sun.light_energy = 1.45
    sun.shadow_enabled = true
    sun.rotation_degrees = Vector3(-54,-32,0)
    world_root.add_child(sun)

    camera = Camera3D.new()
    camera.projection = Camera3D.PROJECTION_ORTHOGONAL
    camera.size = 11.8
    # Add the camera to the tree before look_at. Godot requires a tree/global
    # transform for look_at and V1 logged an error here in headless CI.
    world_root.add_child(camera)
    camera.position = Vector3(9.6,10.7,13.2)
    camera.look_at(Vector3(0.0,0.45,0.7),Vector3.UP)
    camera.current = true

    _build_landscape()
    _build_facilities()
    _build_player()
    _rebuild_restore_patch()
