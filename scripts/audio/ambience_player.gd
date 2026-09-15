class_name AmbiencePlayer
extends Node

var enabled: bool = true
var player: AudioStreamPlayer
var current_season: String = ""
var current_weather: String = ""
var stream_cache: Dictionary = {}

func _ready() -> void:
    player = AudioStreamPlayer.new()
    player.bus = "Master"
    player.volume_db = -27.0
    add_child(player)

func set_enabled(value: bool) -> void:
    enabled = value
    if player == null:
        return
    if not enabled:
        player.stop()
    else:
        ensure_playing()

func set_scene(season_key: String, weather: String) -> void:
    var normalized_weather := weather if not weather.is_empty() else "晴れ"
    if season_key == current_season and normalized_weather == current_weather and player != null and player.stream != null:
        return
    current_season = season_key
    current_weather = normalized_weather
    if player == null:
        return
    var cache_key := "%s|%s" % [current_season,current_weather]
    if not stream_cache.has(cache_key):
        stream_cache[cache_key] = _make_loop(current_season,current_weather)
    player.stream = stream_cache[cache_key]
    if enabled:
        player.play()

func ensure_playing() -> void:
    if enabled and player != null and player.stream != null and not player.playing:
        player.play()

func _make_loop(season_key: String, weather: String) -> AudioStreamWAV:
    var rate := 11025
    var seconds := 6.0
    var samples := int(float(rate) * seconds)
    var bytes := PackedByteArray()
    bytes.resize(samples * 2)

    var is_winter := season_key == "winter"
    var is_summer := season_key == "summer"
    var is_autumn := season_key == "autumn"
    var rain_factor := 1.35 if ("雨" in weather or "嵐" in weather) else 1.0
    var snow_quiet := 0.55 if (is_winter and "雪" in weather) else 1.0

    for i in range(samples):
        var t := float(i) / float(rate)
        var hash_value := sin(float(i * 73 + 19) * 12.9898) * 43758.5453
        var noise := (hash_value - floor(hash_value)) * 2.0 - 1.0

        var wind_env := 0.58 + 0.24 * sin(TAU * 0.11 * t) + 0.12 * sin(TAU * 0.23 * t + 1.7)
        var wind := noise * 0.050 * wind_env * rain_factor

        var water_tone := sin(TAU * (176.0 + 10.0 * sin(TAU * 0.31 * t)) * t)
        var water := water_tone * 0.018 + noise * 0.012
        if is_winter:
            water *= 0.48

        var bird := 0.0
        if not is_winter:
            var bird_cycle := fmod(t + 0.37,2.35)
            if bird_cycle < 0.18:
                var bird_env := sin(PI * bird_cycle / 0.18)
                var bird_freq := 920.0 + 840.0 * (bird_cycle / 0.18)
                bird = sin(TAU * bird_freq * t) * bird_env * (0.026 if is_summer else 0.020)

        var bee := 0.0
        if is_summer:
            var bee_env := 0.5 + 0.5 * sin(TAU * 0.17 * t + 0.9)
            bee = sin(TAU * 146.0 * t) * 0.009 * bee_env

        var leaf_rustle := 0.0
        if is_autumn:
            leaf_rustle = noise * (0.012 + 0.010 * maxf(0.0,sin(TAU * 0.43 * t)))

        var sample := (wind + water + bird + bee + leaf_rustle) * snow_quiet
        sample = clampf(sample,-0.22,0.22)
        var sample_value := int(sample * 32767.0)
        if sample_value < 0:
            sample_value += 65536
        bytes[i * 2] = sample_value & 0xff
        bytes[i * 2 + 1] = (sample_value >> 8) & 0xff

    var wav := AudioStreamWAV.new()
    wav.format = AudioStreamWAV.FORMAT_16_BITS
    wav.mix_rate = rate
    wav.stereo = false
    wav.data = bytes
    wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
    wav.loop_begin = 0
    wav.loop_end = samples
    return wav
