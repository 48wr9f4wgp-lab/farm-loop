extends "res://scripts/ui/main_v15.gd"

const FarmScreenClass = preload("res://scripts/ui/screens/farm_screen.gd")
const B5CurrentRulesClass = preload("res://scripts/core/game_rules_current.gd")
const B5SfxClass = preload("res://scripts/audio/sfx_player.gd")
const FtueServiceClass = preload("res://scripts/core/ftue_service.gd")

var ftue_service

func _ready() -> void:
    # Current runtime boot: bypass the historical version-by-version _ready chain.
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

    ftue_service = FtueServiceClass.new(data)
    ftue_service.ensure_state(state)
    if ftue_service.active(state) and ftue_service.step(state) == 7:
        ftue_service.ensure_starter_request(state)

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
    _record_event("session_start",_slice_props())
    if ftue_service.mark_step_started(state):
        _record_event("ftue_step_started",_slice_props({"step":ftue_service.step(state)}))
    save_service.save(state)
    _header()
    _show_tab(current_tab)

func _next_objective() -> String:
    if ftue_service != null and ftue_service.active(state):
        return "はじめての里山｜%s" % ftue_service.objective(state)
    return super._next_objective()

func _show_tab(tab: String) -> void:
    super._show_tab(tab)

    if ftue_service != null:
        var transition: Dictionary = ftue_service.on_tab(state,tab)
        if bool(transition.get("advanced",false)):
            _record_event("village_request_viewed",_slice_props({"step":int(transition.get("from_step",7))}))
            _apply_ftue_transition(transition)

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

func _commit(result: Dictionary, return_tab: String, facility: String = "") -> void:
    var ok: bool = bool(result.get("ok",false))
    var kind: String = str(result.get("feedback","work"))
    var transition: Dictionary = {"advanced":false}
    if ftue_service != null:
        transition = ftue_service.on_action(state,kind,facility,result)

    if ok:
        _record_slice_action(result,kind,facility)

    # Preserve mature product feedback/daily/chain behavior while FTUE is now
    # orchestrated by the current service above.
    super._commit(result,return_tab,facility)

    if bool(transition.get("advanced",false)):
        _apply_ftue_transition(transition)

func _apply_ftue_transition(transition: Dictionary) -> void:
    if ftue_service == null or not bool(transition.get("advanced",false)):
        return
    var from_step: int = int(transition.get("from_step",-1))
    _record_event("ftue_step_completed",_slice_props({
        "step":from_step,
        "step_elapsed_seconds":float(transition.get("step_elapsed_seconds",0.0))
    }))

    if bool(transition.get("completed",false)):
        _record_event("ftue_complete",_slice_props({"step":from_step}))
        _record_event("full_loop_complete",_slice_props())
        if feedback != null:
            feedback.pop("はじめての里山 完成！ ここからは自由に育てよう",5)
            feedback.fly_tokens("major",12)
        if sfx != null:
            sfx.play_kind("major",5)
    elif ftue_service.mark_step_started(state):
        _record_event("ftue_step_started",_slice_props({"step":ftue_service.step(state)}))

    save_service.save(state)
    _header()

func _record_slice_action(result: Dictionary, kind: String, facility: String) -> void:
    var route: String = str(result.get("route",""))
    if facility == "coop" and kind == "collect":
        if not bool(state["analytics"].get("first_facility_action_recorded",false)):
            state["analytics"]["first_facility_action_recorded"] = true
            _record_event("first_facility_action",_slice_props({"facility":"coop"}))
        _record_event("farm_harvest",_slice_props({"facility":"coop"}))
    elif facility == "materials" and kind == "work":
        _record_event("material_gather",_slice_props({"facility":"materials"}))
    elif facility == "compost" and kind == "work":
        _record_event("compost_create",_slice_props({"facility":"compost"}))
    elif kind in ["month","hazard"]:
        _record_event("month_advance",_slice_props())
    elif facility == "sansai" and kind == "loop":
        _record_event("compost_use",_slice_props({"facility":"sansai"}))
    elif facility == "sansai" and kind == "collect":
        _record_event("sansai_harvest",_slice_props({"facility":"sansai"}))
    elif facility == "mountain" and not route.is_empty():
        _record_event("mountain_route_selected",_slice_props({"route":route}))
        _record_event("mountain_result",_slice_props({
            "route":route,
            "rare":bool(result.get("rare",false)),
            "find":str(result.get("find",""))
        }))
    elif kind == "sell":
        _record_event("market_sell",_slice_props({"channel":selected_channel}))

func _slice_props(extra: Dictionary = {}) -> Dictionary:
    if ftue_service == null:
        return extra.duplicate(true)
    return ftue_service.event_properties(state,extra)

func _on_gather_leaves() -> void:
    _commit(rules.gather_leaves(state),"work","materials")

func _on_route_explore(route_id: String) -> void:
    if not rules.has_method("explore_route"):
        return
    _commit(rules.explore_route(state,route_id),"work","mountain")

func _on_channel(id: String) -> void:
    selected_channel = id
    _record_event("market_channel_selected",_slice_props({"channel":id}))
    _show_tab("market")
