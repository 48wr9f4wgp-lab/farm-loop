class_name FarmDioramaV9
extends "res://scripts/ui/farm_diorama_v8.gd"

# Visual Pass 7: hard portrait-safe framing.
# The previous pass still placed important content too close to the right edge
# on physical iPhone. Preserve guided focus through markers, not camera crop.

func _build_world() -> void:
    super._build_world()
    visual_pass = 7
    visual_target_id = "satoyama-premium-2026-09-15-v7"
    if world_root != null:
        world_root.name = "SatoyamaDioramaV9"
        var marker := Node3D.new()
        marker.name = "VisualPass7SafeFrameMarker"
        world_root.add_child(marker)

func _apply_guided_focus() -> void:
    super._apply_guided_focus()
    if guided_focus != "sansai" or camera == null:
        return

    # Keep a real visual gutter on both sides of the island. The restoration
    # target remains prominent through the restrained world-space brackets and
    # suppression of unrelated readiness markers.
    camera.size = 12.55
    camera.look_at(Vector3(0.05,0.46,0.72),Vector3.UP)

    if restore_root != null and is_instance_valid(restore_root):
        restore_root.scale = Vector3(1.08,1.0,1.08)
