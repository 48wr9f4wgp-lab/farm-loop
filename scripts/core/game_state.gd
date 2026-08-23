class_name GameState
extends RefCounted

static func create(data: GameData) -> Dictionary:
    var levels := {}
    for key in data.get_table("facilities"):
        levels[key] = int(data.get_table("facilities")[key].get("start_level", 1))
    var inventory := {}
    for key in data.get_table("products"):
        inventory[key] = 0
    inventory["leaves"] = 4
    return {
        "schema_version": 4,
        "version": "godot-0.3.2-mobile-ci",
        "year": 1,
        "month": 4,
        "money": 85000,
        "reputation": 6,
        "loop_score": 16,
        "xp": 0,
        "level": 1,
        "yearly_sales": 0,
        "lifetime_sales": 0,
        "weather": "晴れ",
        "inventory": inventory,
        "facility_levels": levels,
        "ready": {"coop":true,"sansai":true,"mushroom":true,"bee":true},
        "buffs": {"field":0,"pollination":0},
        "projects": {},
        "compost_queue": 0,
        "mushroom_batches": [
            {"id":"starter-mature","type":"shiitake","age":18,"count":36,"health":92},
            {"id":"starter-nameko","type":"nameko","age":20,"count":12,"health":88},
            {"id":"starter-hiratake","type":"hiratake","age":16,"count":10,"health":86}
        ],
        "relation": {"mio":0,"takumi":0,"gen":0},
        "village_requests": [],
        "discovered": ["eggs","taranome","udo","kogomi","shiitake"],
        "counters": {"harvest":0,"sales":0,"craft":0},
        "quests": [],
        "tutorial_step": 0,
        "log": ["Farm Loop Godot移植版を開始。鶏舎から循環を始めよう。"],
        "analytics": {"session_actions":0,"events":[]},
        "settings": {"haptics":true,"reduced_motion":false},
        "ui": {"selected_facility":"coop","last_tab":"farm"}
    }
