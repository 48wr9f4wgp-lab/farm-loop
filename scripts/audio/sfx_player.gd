class_name SfxPlayer
extends Node

var enabled := true
var players: Array[AudioStreamPlayer] = []
var voice_index: int = 0

func _ready() -> void:
    for i in range(3):
        var voice := AudioStreamPlayer.new()
        voice.bus = "Master"
        add_child(voice)
        players.append(voice)

func set_enabled(value: bool) -> void:
    enabled = value
    if not enabled:
        for voice in players:
            if voice.playing:
                voice.stop()

func play_kind(kind: String, tier: int = 1) -> void:
    if not enabled or players.is_empty():
        return
    var freqs: Array[float] = [520.0]
    var duration: float = 0.12
    var volume: float = 0.18
    match kind:
        "collect":
            freqs = [690.0,840.0]
            duration = 0.14
            volume = 0.16
        "work", "craft":
            freqs = [290.0,390.0]
            duration = 0.15
            volume = 0.18
        "loop":
            freqs = [510.0,670.0,880.0]
            duration = 0.23
            volume = 0.19
        "sell":
            freqs = [880.0,1170.0,1450.0]
            duration = 0.20
            volume = 0.19
        "mission", "upgrade":
            freqs = [560.0,760.0,1010.0]
            duration = 0.25
            volume = 0.20
        "major", "season":
            freqs = [470.0,650.0,870.0,1160.0]
            duration = 0.34
            volume = 0.21
        "hazard":
            freqs = [215.0,168.0]
            duration = 0.26
            volume = 0.18
        "month":
            freqs = [390.0,520.0]
            duration = 0.17
            volume = 0.16
    if tier >= 4 and kind not in ["hazard","season","major"]:
        freqs.append(1260.0)
    var voice := players[voice_index % players.size()]
    voice_index = (voice_index + 1) % players.size()
    voice.stream = _make_sound(kind,freqs,duration,volume)
    voice.play()

func _make_sound(kind: String, freqs: Array[float], total_duration: float, amplitude: float) -> AudioStreamWAV:
    var rate: int = 22050
    var samples: int = maxi(1,int(float(rate)*total_duration))
    var bytes := PackedByteArray()
    bytes.resize(samples*2)
    var segment: float = maxf(1.0,float(samples)/float(maxi(1,freqs.size())))
    for i in range(samples):
        var segment_index: int = mini(freqs.size()-1,int(float(i)/segment))
        var freq: float = freqs[segment_index]
        var time: float = float(i)/float(rate)
        var progress: float = float(i)/float(samples)
        var attack: float = clampf(progress/0.035,0.0,1.0)
        var decay: float = pow(maxf(0.0,1.0-progress),1.75)
        var envelope: float = attack*decay
        var fundamental: float = sin(TAU*freq*time)
        var harmonic: float = sin(TAU*freq*2.0*time)*0.18 + sin(TAU*freq*3.01*time)*0.07
        var noise_seed: float = sin(float(i*127 + 31)*12.9898)*43758.5453
        var noise: float = (noise_seed-floor(noise_seed))*2.0-1.0
        var wave: float = fundamental*0.78 + harmonic
        if kind in ["work","craft"]:
            var transient: float = maxf(0.0,1.0-progress*12.0)
            wave = fundamental*0.62 + sin(TAU*freq*0.5*time)*0.22 + noise*transient*0.18
        elif kind == "collect":
            wave = fundamental*0.66 + sin(TAU*freq*2.02*time)*0.20 + noise*maxf(0.0,1.0-progress*18.0)*0.06
        elif kind == "sell":
            wave = fundamental*0.54 + sin(TAU*freq*2.7*time)*0.27 + sin(TAU*freq*4.1*time)*0.10
        elif kind in ["mission","upgrade","major","season","loop"]:
            wave = fundamental*0.62 + sin(TAU*freq*2.0*time)*0.19 + sin(TAU*freq*3.0*time)*0.08
        elif kind == "hazard":
            wave = sin(TAU*freq*time)*0.72 + noise*0.12
        var sample_value: int = int(clampf(wave*amplitude*envelope,-1.0,1.0)*32767.0)
        if sample_value < 0:
            sample_value += 65536
        bytes[i*2] = sample_value & 0xff
        bytes[i*2+1] = (sample_value >> 8) & 0xff
    var wav := AudioStreamWAV.new()
    wav.format = AudioStreamWAV.FORMAT_16_BITS
    wav.mix_rate = rate
    wav.stereo = false
    wav.data = bytes
    return wav
