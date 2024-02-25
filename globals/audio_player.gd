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
	stream = load(file_path)
	seek(0)
	audio_changed.emit()

func get_duration() -> float:
	"""音乐总长度"""
	return stream.get_length() if current_file else 0

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


























	

