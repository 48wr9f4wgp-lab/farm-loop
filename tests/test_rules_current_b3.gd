extends SceneTree

const GameDataClass = preload("res://scripts/core/game_data.gd")
const GameStateClass = preload("res://scripts/core/game_state.gd")
const LegacyRulesClass = preload("res://scripts/core/game_rules_v14.gd")
const CurrentRulesClass = preload("res://scripts/core/game_rules_current.gd")

var failures: int = 0

func _ok(condition: bool, message: String) -> void:
    if condition:
        print("PASS: ", message)
    else:
        failures += 1
        printerr("FAIL: ", message)

func _canon(value: Variant) -> String:
    return JSON.stringify(value, "", true, false)

func _same(a: Variant, b: Variant, message: String) -> void:
    var equal := _canon(a) == _canon(b)
    _ok(equal, message)
    if not equal:
        printerr("  LEGACY: ", _canon(a))
        printerr("  CURRENT: ", _canon(b))

func _state(data) -> Dictionary:
    return GameStateClass.create(data)

func _prepare(rules, s: Dictionary) -> void:
    rules.ensure_product_fields(s)
    rules.ensure_route_fields(s)

func _init() -> void:
    var data = GameDataClass.new()
    var legacy = LegacyRulesClass.new(data)
    var current = CurrentRulesClass.new(data)

    var base := _state(data)
    _prepare(legacy, base)
    var base_current := _state(data)
    _prepare(current, base_current)
    _same(base, base_current, "field initialization is equivalent")

    # Pure projections.
    _same(legacy.land_progress(base), current.land_progress(base_current), "land progress projection matches")
    _same(legacy.daily_summary(base), current.daily_summary(base_current), "daily notebook projection matches")
    for route_id in ["stream", "beech", "ridge", "unknown"]:
        _ok(legacy.route_name(route_id) == current.route_name(route_id), "route name matches: " + route_id)
    for points in [0, 9, 10, 24, 25, 49, 50, 75]:
        _same(legacy.relation_progress(points), current.relation_progress(points), "relationship projection matches at %d" % points)

    # Controlled market projection.
    var market_legacy := _state(data)
    var market_current := _state(data)
    _prepare(legacy, market_legacy)
    _prepare(current, market_current)
    for pair in [["eggs",7],["taranome",3],["shiitake",4],["honey",2]]:
        market_legacy["inventory"][pair[0]] = pair[1]
        market_current["inventory"][pair[0]] = pair[1]
    for channel in ["roadside", "farmers", "giftshop"]:
        for product in ["eggs", "taranome", "shiitake", "honey"]:
            _ok(legacy.preview_price(market_legacy, product, channel) == current.preview_price(market_current, product, channel), "preview price matches: %s/%s" % [product, channel])
        _same(legacy.basket_preview(market_legacy, channel), current.basket_preview(market_current, channel), "basket preview matches: " + channel)
    _ok(legacy.best_channel(market_legacy) == current.best_channel(market_current), "best channel projection matches")

    # Village request readiness projection.
    var request := {
        "id":"equivalence_request",
        "villager":"mio",
        "label":"等価テスト",
        "need":{"eggs":5,"shiitake":2},
        "reward":2000,
        "relation":3,
        "done":false
    }
    market_legacy["inventory"]["eggs"] = 3
    market_current["inventory"]["eggs"] = 3
    _same(legacy.request_status(market_legacy, request), current.request_status(market_current, request), "request missing-item projection matches")
    market_legacy["inventory"]["eggs"] = 6
    market_current["inventory"]["eggs"] = 6
    _same(legacy.request_status(market_legacy, request), current.request_status(market_current, request), "request ready projection matches")

    # Daily state mutation.
    var daily_legacy := _state(data)
    var daily_current := _state(data)
    _prepare(legacy, daily_legacy)
    _prepare(current, daily_current)
    for step in [["collect","coop"],["collect","sansai"],["collect","mountain"],["sell",""]]:
        var lr: Dictionary = legacy.track_daily_action(daily_legacy, step[0], step[1])
        var cr: Dictionary = current.track_daily_action(daily_current, step[0], step[1])
        _same(lr, cr, "daily action result matches: %s/%s" % [step[0],step[1]])
        _same(daily_legacy, daily_current, "daily action state matches: %s/%s" % [step[0],step[1]])

    # Ecology-chain mutation.
    var chain_legacy := _state(data)
    var chain_current := _state(data)
    _prepare(legacy, chain_legacy)
    _prepare(current, chain_current)
    for step in [["collect","coop"],["work","compost"],["month",""],["loop",""],["collect","sansai"],["sell",""]]:
        var lr: Dictionary = legacy.register_loop_action(chain_legacy, step[0], step[1])
        var cr: Dictionary = current.register_loop_action(chain_current, step[0], step[1])
        _same(lr, cr, "ecology-chain result matches: %s/%s" % [step[0],step[1]])
        _same(chain_legacy, chain_current, "ecology-chain state matches: %s/%s" % [step[0],step[1]])

    # Randomized route behavior: identical seed, independent fresh states.
    var route_seed := 424242
    for route_id in ["stream", "beech", "ridge"]:
        var route_legacy := _state(data)
        var route_current := _state(data)
        _prepare(legacy, route_legacy)
        _prepare(current, route_current)
        legacy.rng.seed = route_seed
        current.rng.seed = route_seed
        var lr: Dictionary = legacy.explore_route(route_legacy, route_id)
        var cr: Dictionary = current.explore_route(route_current, route_id)
        _same(lr, cr, "seeded route result matches: " + route_id)
        _same(route_legacy, route_current, "seeded route state matches: " + route_id)
        route_seed += 101

    # Batch sale uses randomized live quote_price; seed both before the operation.
    var sell_legacy := _state(data)
    var sell_current := _state(data)
    _prepare(legacy, sell_legacy)
    _prepare(current, sell_current)
    for pair in [["eggs",9],["taranome",3],["shiitake",4]]:
        sell_legacy["inventory"][pair[0]] = pair[1]
        sell_current["inventory"][pair[0]] = pair[1]
    legacy.rng.seed = 998877
    current.rng.seed = 998877
    var sell_lr: Dictionary = legacy.sell_basket(sell_legacy, "roadside")
    var sell_cr: Dictionary = current.sell_basket(sell_current, "roadside")
    _same(sell_lr, sell_cr, "seeded batch-sale result matches")
    _same(sell_legacy, sell_current, "seeded batch-sale state matches")

    print("B3 RULES EQUIVALENCE TESTS COMPLETE failures=", failures)
    quit(1 if failures > 0 else 0)
