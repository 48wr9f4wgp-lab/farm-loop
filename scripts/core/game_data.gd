class_name GameData
extends RefCounted

const FILES := {
    "products": "res://data/products.json",
    "facilities": "res://data/facilities.json",
    "sansai": "res://data/sansai.json",
    "recipes": "res://data/recipes.json",
    "channels": "res://data/channels.json",
    "projects": "res://data/projects.json",
    "milestones": "res://data/milestones.json",
    "villagers": "res://data/villagers.json",
    "requests": "res://data/requests.json",
    "seasons": "res://data/seasons.json",
    "quests": "res://data/quests.json",
}

var tables: Dictionary = {}

func _init() -> void:
    reload()

func reload() -> void:
    tables.clear()
    for key in FILES:
        tables[key] = _load_json(FILES[key])

func _load_json(path: String) -> Variant:
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        push_error("Farm Loop data missing: %s" % path)
        return {}
    var parsed: Variant = JSON.parse_string(file.get_as_text())
    if parsed == null:
        push_error("Farm Loop JSON invalid: %s" % path)
        return {}
    return parsed

func get_table(name: String) -> Variant:
    return tables.get(name, {})
