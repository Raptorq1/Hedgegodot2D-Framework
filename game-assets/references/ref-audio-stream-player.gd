extends Reference
class_name SoundMachineStreamPlayer
signal finished

enum MixTarget {
	MIX_TARGET_STEREO,
	MIX_TARGET_SURROUND,
	MIX_TARGET_CENTER
}
var _is_processing:bool = false setget set_process, is_processing

var stream : AudioStreamSample setget set_stream
var stream_playbacks : Array
var bus : String setget set_bus
var mix_target : int = MixTarget.MIX_TARGET_STEREO
var main_volume_db = 0.0
var main_pitch_scale = 1.0

func play(p_from_pos:float) -> void:
	if is_processing() and stream.is_monophonic():return
	var stream_playback : AudioStreamPlayback = stream.call("instance_playback")
	assert(stream_playback.is_null(), "Failed to instantiate playback.")
	
	AudioServer.start_playback_stream(stream_playback, bus, [], 1.0)
	stream_playbacks.append(stream_playback)
	set_process(true)
	while stream_playbacks.size() > 1:
		AudioServer.stop_playback_stream(stream_playbacks[0])
		stream_playbacks.remove(0)

func stop():
	for i in stream_playbacks:
		AudioServer.stop_playback_stream(i)
	stream_playbacks.clear()
	set_process(false)

func set_process(val : bool) -> void:
	_is_processing = val

func is_processing() -> bool: return _is_processing

func intern_process(delta):
	var playback_to_remove : Array
	for i in stream_playbacks:
		if i.is_valid() and !AudioServer.is_playback_active(i) and !AudioServer.is_playback_paused(i):
			playback_to_remove.push_back(i)
	
	for i in playback_to_remove:
		stream_playbacks.erase(i)
	
	if playback_to_remove.empty() and stream_playbacks.empty():
		set_process(false)
	
	if !playback_to_remove.empty():
		emit_signal("finished")

func set_stream(val : AudioStreamSample) -> void:
	stream = val

func set_bus(val : String) -> void:
	bus = val
