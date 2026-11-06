extends Node

const SAMPLE_RATE := 22050
const AREA_CHORDS := {
	"crossing": [110.0, 165.0, 220.0],
	"ruins": [82.4, 164.8, 246.9],
	"orchard": [98.0, 146.8, 196.0, 293.7],
	"archive": [73.42, 110.0, 220.0, 293.66],
	"observatory": [55.0, 110.0, 164.8, 261.6]
}

var _ambience_player: AudioStreamPlayer
var _effect_player: AudioStreamPlayer
var _effects: Dictionary = {}
var _area_streams: Dictionary = {}
var _area_name := "crossing"

func _ready() -> void:
	_ambience_player = AudioStreamPlayer.new()
	_ambience_player.volume_db = -22.0
	_ambience_player.stream = _get_area_stream(_area_name)
	add_child(_ambience_player)
	if RunState.settings.get("ambient_audio", true):
		_ambience_player.play()
	_effect_player = AudioStreamPlayer.new()
	_effect_player.volume_db = -10.0
	add_child(_effect_player)
	_effects["pickup"] = _make_tone([660.0, 880.0], 0.26, 0.10)
	_effects["wake"] = _make_tone([523.0, 659.0, 784.0], 0.72, 0.13)
	_effects["journal"] = _make_tone([440.0, 660.0], 0.30, 0.08)
	_effects["resonance"] = _make_tone([392.0, 523.0], 0.34, 0.10)
	_effects["complete"] = _make_tone([392.0, 494.0, 587.0, 784.0], 1.1, 0.12)
	_effects["soft_fade"] = _make_tone([246.0, 293.0], 0.42, 0.07)
	_effects["hint"] = _make_tone([349.0, 523.0], 0.48, 0.065)

func play_event(event_name: String) -> void:
	if not _effects.has(event_name) or not is_instance_valid(_effect_player):
		return
	_effect_player.stream = _effects[event_name]
	_effect_player.play()

func set_ambience_enabled(enabled: bool) -> void:
	if not is_instance_valid(_ambience_player):
		return
	if enabled and not _ambience_player.playing:
		_ambience_player.play()
	elif not enabled and _ambience_player.playing:
		_ambience_player.stop()

func set_area(area_name: String) -> void:
	if not AREA_CHORDS.has(area_name):
		area_name = "ruins"
	_area_name = area_name
	if not is_instance_valid(_ambience_player):
		return
	_ambience_player.stream = _get_area_stream(_area_name)
	if RunState.settings.get("ambient_audio", true):
		_ambience_player.play()

func _get_area_stream(area_name: String) -> AudioStreamWAV:
	if not _area_streams.has(area_name):
		_area_streams[area_name] = _make_ambience(AREA_CHORDS.get(area_name, AREA_CHORDS["ruins"]))
	return _area_streams[area_name]

func _make_tone(frequencies: Array[float], duration: float, amplitude: float) -> AudioStreamWAV:
	var frame_count := int(SAMPLE_RATE * duration)
	var samples := PackedByteArray()
	samples.resize(frame_count * 2)
	for index in range(frame_count):
		var time := float(index) / SAMPLE_RATE
		var envelope := pow(maxf(0.0, 1.0 - float(index) / frame_count), 2.2)
		var wave := 0.0
		for frequency in frequencies:
			wave += sin(TAU * frequency * time)
		wave /= maxf(1.0, float(frequencies.size()))
		var sample := int(roundf(clampf(wave * envelope * amplitude, -1.0, 1.0) * 32767.0))
		samples[index * 2] = sample & 255
		samples[index * 2 + 1] = (sample >> 8) & 255
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = SAMPLE_RATE
	stream.stereo = false
	stream.data = samples
	return stream

func _make_ambience(frequencies: Array) -> AudioStreamWAV:
	var frame_count := SAMPLE_RATE * 10
	var samples := PackedByteArray()
	samples.resize(frame_count * 2)
	for index in range(frame_count):
		var time := float(index) / SAMPLE_RATE
		var slow_breath := 0.84 + 0.16 * sin(TAU * 0.2 * time)
		var wave := 0.0
		for note_index in range(frequencies.size()):
			var strength := 0.48 / float(note_index + 1)
			wave += sin(TAU * frequencies[note_index] * time) * strength
		wave /= 1.0 + float(frequencies.size()) * 0.18
		var air := sin(TAU * 0.3 * time) * sin(TAU * 2.7 * time) * 0.045
		wave = (wave + air) * slow_breath * 0.075
		var sample := int(roundf(clampf(wave, -1.0, 1.0) * 32767.0))
		samples[index * 2] = sample & 255
		samples[index * 2 + 1] = (sample >> 8) & 255
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = SAMPLE_RATE
	stream.stereo = false
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = frame_count
	stream.data = samples
	return stream

