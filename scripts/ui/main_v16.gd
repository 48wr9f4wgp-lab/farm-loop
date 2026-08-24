extends "res://scripts/ui/main_v15.gd"

const FarmScreenClass = preload("res://scripts/ui/screens/farm_screen.gd")
const B5CurrentRulesClass = preload("res://scripts/core/game_rules_current.gd")
const B5SfxClass = preload("res://scripts/audio/sfx_player.gd")

func _ready() -> void:
    # B5 runtime boot: bypass the historical version-by-version _ready chain.
    # The inherited methods remain available for rollback while the active app
    # initializes only the current domain, save state, shell and screen once.
    get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
    get_tree().root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
    get_tree().root.content_scale_stretch = Window.CONTENT_SCALE_STRETCH_FRACTIONAL

    _install_ui_font()
    data = GameDataClass.new()
    rules = B5CurrentRulesClass.new(data)
    save_service = SaveServiceClass.new()
    state = save_service.load_or_default(GameStateClass.create(data))
    _ensure_v03_fields()
    rules.ensure_product_fields(state)
    rules.ensure_route_fields(state)
    rules.ensure_requests(state)

    # Historical boot guards are presentation concerns. They must be opened
    # before the single intentional first render below.
    _v09_boot_guard = false
    _v10_boot_guard = false

    _build_shell()
    selected_facility = str(state["ui"].get("selected_facility","coop"))
    current_tab = str(state["ui"].get("last_tab","farm"))

    sfx = B5SfxClass.new()
    add_child(sfx)
    sfx.set_enabled(bool(state["settings"].get("sound",true)))
    _polish_mobile_shell()

    state["version"] = "godot-1.6-motion-audio"
    save_service.save(state)
    _header()
    _show_tab(current_tab)

func _show_tab(tab: String) -> void:
    super._show_tab(tab)
    if content == null or not is_node_ready():
        return
    var reduce: bool = bool(state.get("settings",{}).get("reduced_motion",false))
    if reduce:
        content.modulate.a = 1.0
        return
    content.modulate.a = 0.38
    var tw := create_tween()
    tw.set_trans(Tween.TRANS_QUAD)
    tw.set_ease(Tween.EASE_OUT)
    tw.tween_property(content,"modulate:a",1.0,0.14)

func _build_farm() -> void:
    FarmScreenClass.new().build(self)
