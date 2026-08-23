extends SceneTree

var failures: int = 0

func _ok(condition: bool, message: String) -> void:
    if condition:
        print("PASS: ",message)
    else:
        failures += 1
        printerr("FAIL: ",message)

func _init() -> void:
    var paths: Array[String] = [
        "res://assets/art/coop_v08.svg",
        "res://assets/art/compost_v08.svg",
        "res://assets/art/mushroom_v08.svg",
        "res://assets/art/sansai_v08.svg",
        "res://assets/art/bee_v08.svg",
        "res://assets/art/player_v08.svg"
    ]
    for path in paths:
        _ok(ResourceLoader.exists(path),"art exists: %s" % path)
        var resource = load(path)
        _ok(resource is Texture2D,"art imports as texture: %s" % path)
    var overlay = load("res://scripts/ui/product_map_overlay_v08.gd")
    _ok(overlay != null,"v0.8 map overlay loads")
    print("V0.8 ART TESTS COMPLETE failures=",failures)
    quit(1 if failures > 0 else 0)
