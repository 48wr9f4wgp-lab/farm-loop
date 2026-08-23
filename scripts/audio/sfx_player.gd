class_name SfxPlayer
extends Node

var enabled := true
var player: AudioStreamPlayer

func _ready() -> void:
    player = AudioStreamPlayer.new()
    player.bus = "Master"
    add_child(player)

func set_enabled(value: bool) -> void:
    enabled = value
    if not enabled and player and player.playing:
        player.stop()

func play_kind(kind: String, tier: int = 1) -> void:
    if not enabled or player == null:
        return
    var freqs: Array[float] = [520.0]
    var duration := 0.10
    var volume := 0.18
    match kind:
        "collect":
            freqs = [610.0, 760.0]
            duration = 0.12
        "work", "craft":
            freqs = [430.0, 520.0]
            duration = 0.11
        "loop":
            freqs = [520.0, 680.0, 860.0]
            duration = 0.18
            volume = 0.20
        "sell":
            freqs = [760.0, 980.0, 1220.0]
            duration = 0.16
            volume = 0.22
        "mission", "upgrade":
            freqs = [600.0, 820.0, 1040.0]
            duration = 0.20
            volume = 0.22
        "major", "season":
            freqs = [520.0, 700.0, 920.0, 1180.0]
            duration = 0.28
            volume = 0.24
        "hazard":
            freqs = [230.0, 185.0]
            duration = 0.22
            volume = 0.20
        "month":
            freqs = [420.0, 560.0]
            duration = 0.14
    if tier >= 4 and kind not in ["hazard", "season", "major"]:
        freqs.append(1180.0)
    player.stream = _make_tone(freqs, duration, volume)
    player.play()

func _make_tone(freqs: Array[float], total_duration: float, amplitude: float) -> AudioStreamWAV:
    var rate := 22050
    var samples := maxi(1, int(float(rate) * total_duration))
    var bytes := PackedByteArray()
    bytes.resize(samples * 2)
    var segment := maxf(1.0, float(samples) / float(maxi(1, freqs.size())))
    for i in range(samples):
        var segment_index := mini(freqs.size() - 1, int(float(i) / segment))
        var freq: float = freqs[segment_index]
        var t := float(i) / float(rate)
        var progress := float(i) / float(samples)
        var envelope := sin(PI * clampf(progress, 0.0, 1.0))
        var sample := int(sin(TAU * freq * t) * amplitude * envelope * 32767.0)
        if sample < 0:
            sample += 65536
        bytes[i * 2] = sample & 0xff
        bytes[i * 2 + 1] = (sample >> 8) & 0xff
    var wav := AudioStreamWAV.new()
    wav.format = AudioStreamWAV.FORMAT_16_BITS
    wav.mix_rate = rate
    wav.stereo = false
    wav.data = bytes
    return wav
