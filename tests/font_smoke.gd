extends SceneTree

func _fail(message: String) -> void:
    push_error(message)
    quit(1)

func _init() -> void:
    var path := "res://assets/fonts/farmloop-jp.woff2"
    if not ResourceLoader.exists(path):
        _fail("Japanese UI font resource is missing")
        return
    var font = load(path)
    if font == null or not (font is Font):
        _fail("Japanese UI font failed to load")
        return
    for ch in ["農","場","山","菜","循","環","鶏","雪","里","珍","品","販","売"]:
        if not font.has_char(ch.unicode_at(0)):
            _fail("Japanese UI font missing glyph: %s" % ch)
            return
    print("FONT_SMOKE PASS")
    quit(0)
