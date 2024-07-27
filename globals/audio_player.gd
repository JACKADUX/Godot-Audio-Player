extends AudioStreamPlayer

signal audio_changed
signal audio_played
signal audio_stoped
signal time_changed

var current_file:String = ""
var current_time:float = 0

func _ready():
	finished.connect(stop_audio)

func _process(delta):
	if playing:
		current_time = get_playback_position()
		time_changed.emit()

## Interface
func init_audio(file_path:String):
	if file_path.get_extension() not in AudioManager.AudioFormats:
		return 
	current_file = file_path
	current_time = 0
	stream = load_audio_stream(file_path)
	seek(0)
	audio_changed.emit()

func get_duration() -> float:
	"""音乐总长度"""
	return 0 if not current_file or not stream else stream.get_length()

func get_current_time() -> float:
	"""音乐当前进度"""
	return current_time

func set_time(position:float=0):
	"""修改播放进度"""
	if floor(position) == floor(get_duration()):
		stop_audio()
	else:
		current_time = position
		seek(position)
	time_changed.emit()

func get_audio_name():
	return current_file.get_file().get_basename()

func play_audio():
	if not current_file:
		return 
	if floor(current_time) != floor(get_duration()):
		play(current_time)
	else:
		play(0)
	audio_played.emit()

func stop_audio():
	stop()
	audio_stoped.emit()

func load_audio_stream(file_path:String):
	var file = FileAccess.open(file_path, FileAccess.READ)
	var sound:AudioStream
	match file_path.get_extension():
		"mp3": sound = AudioStreamMP3.new()
		"wav": sound = AudioStreamWAV.new()
		"ogg": return AudioStreamOggVorbis.load_from_file(file_path)
		_: 
			return 
	sound.data = file.get_buffer(file.get_length())
	return sound

























	

