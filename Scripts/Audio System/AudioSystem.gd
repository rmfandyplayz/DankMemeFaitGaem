extends Node

signal AudioFinished(audioPlayer)

@export var musicNode : Node
@export var sfxNode : Node

var _audioTimers = {}  # tracks timers for non-looping audio

# plays global music under the "Music" node
func PlayMusic(audioStream: AudioStream, volume: float = 0.0, pitch: float = 1.0, looping: bool = false, startFromDuration : float = 0) -> AudioStreamPlayer:
	var player = AudioStreamPlayer.new()
	player.stream = audioStream
	player.volume_db = linear_to_db(volume)
	player.pitch_scale = pitch
	player.bus = "Music_Master"
	# sets the audiostream to loop if it's set to looping in the file
	if audioStream.has_method("set_loop"):
		audioStream.loop = looping
	add_child(player)
	player.play(startFromDuration)
	
	if not looping:
		var timer = Timer.new()
		timer.one_shot = true
		timer.wait_time = audioStream.get_length()
		timer.connect("timeout", _OnAudioFinished.bind(player, timer))
		add_child(timer)
		timer.start()
		_audioTimers[player] = timer
	
	return player

# plays SFX under the sound category
func PlaySound(audioStream: AudioStream, category: String = "SFX", volume: float = 0.0, pitch: float = 1.0, looping: bool = false) -> AudioStreamPlayer:
	var player = AudioStreamPlayer.new()
	player.stream = audioStream
	player.volume_db = linear_to_db(volume)
	player.pitch_scale = pitch
	
	match category:
		"UI":
			player.bus = "UI_Master"
		"SFX":
			player.bus = "SFX_Master"
		_:
			player.bus = "SFX_Master"
	
	add_child(player)
	player.play()
	
	if not looping:
		var timer = Timer.new()
		timer.one_shot = true
		timer.wait_time = audioStream.get_length()
		timer.connect("timeout", _OnAudioFinished.bind(player, timer))
		add_child(timer)
		timer.start()
		_audioTimers[player] = timer
	
	return player

# stops given audio player and emits signal
func StopAudio(audioPlayer: AudioStreamPlayer, fade: bool = false, fadeTime: float = 0.0) -> float:
	if not is_instance_valid(audioPlayer):
		return -1
	# if there was a timer on this audio player, stop it
	if _audioTimers.has(audioPlayer):
		var timer = _audioTimers[audioPlayer]
		if is_instance_valid(timer):
			timer.stop()
			timer.queue_free()
		_audioTimers.erase(audioPlayer)
	
	
	if fade and fadeTime > 0:
		var tween = create_tween()
		tween.tween_property(audioPlayer, "volume_db", -80, fadeTime)
		var fadeTimer = Timer.new()
		fadeTimer.one_shot = true
		fadeTimer.wait_time = fadeTime
		fadeTimer.connect("timeout", _OnFadeCompleted.bind(audioPlayer, tween, fadeTimer))
		add_child(fadeTimer)
		fadeTimer.start()
		_audioTimers[audioPlayer] = fadeTimer
	else:
		audioPlayer.get_playback_position()
		audioPlayer.stop()
		emit_signal("AudioFinished", audioPlayer)
		audioPlayer.queue_free()
	
	return audioPlayer.get_playback_position()

# called when a non looping audio finishes playing
func _OnAudioFinished(audioPlayer : AudioStreamPlayer, timer : Timer) -> void:
	if _audioTimers.has(audioPlayer):
		_audioTimers.erase(audioPlayer)
	if is_instance_valid(audioPlayer):
		emit_signal("AudioFinished", audioPlayer)
		audioPlayer.queue_free()
	if is_instance_valid(timer):
		timer.queue_free()

# called when audio finishes fading
func _OnFadeCompleted(audioPlayer : AudioStreamPlayer, tween : Tween, timer : Timer) -> void:
	#print(tween)
	#if(tween != null and is_instance_valid(tween)):
		#print(tween)
		#tween.queue_free()
	if(_audioTimers.has(audioPlayer)):
		_audioTimers.erase(audioPlayer)
	if is_instance_valid(audioPlayer):
		audioPlayer.stop()
		emit_signal("AudioFinished", audioPlayer)
		audioPlayer.queue_free()
	if is_instance_valid(timer):
		timer.queue_free()
