class_name FarmDioramaV8
extends "res://scripts/ui/farm_diorama_v7.gd"

# Visual Pass 6: preserve guided emphasis without cropping the diorama.
# The whole playable island must remain inside the portrait hero viewport.

func _build_world() -> void:
    super._build_world()
    visual_pass = 6
    visual_target_id = "satoyama-premium-2026-09-15-v6"
    if world_root != null:
        world_root.name = "SatoyamaDioramaV8"
        var marker := Node3D.new()
        marker.name = "VisualPass6FramingMarker"
        world_root.add_child(marker)

func _apply_guided_focus() -> void:
    super._apply_guided_focus()
    if guided_focus != "sansai" or camera == null:
        return

    # V7 zoomed and shifted far enough that the right side of the island was
    # visibly clipped on tall iPhones. Keep the restoration patch emphasized
    # with markers and scale, but frame the entire playable diorama.
    camera.size = 11.35
    camera.look_at(Vector3(-0.18,0.46,0.92),Vector3.UP)

    if restore_root != null and is_instance_valid(restore_root):
        restore_root.scale = Vector3(1.12,1.0,1.12)
