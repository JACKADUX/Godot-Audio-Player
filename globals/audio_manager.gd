extends Node

signal index_changed
signal audio_datas_changed

const AudioFormats := ["mp3", "wav"]

var audio_datas = []
var current_index = -1


func get_audio_datas():
	return audio_datas

func set_current_index(value:int):
	value = clamp(value, 0, audio_datas.size()-1)
	if value == current_index:
		return 
	current_index = value
	index_changed.emit()

func get_current_index():
	return current_index
	
func get_audio_count():
	return audio_datas.size()

func next_audio():
	set_current_index(current_index+1)

func prev_audio():
	set_current_index(current_index-1)
	

func get_current_audio_path():
	return audio_datas[current_index].path


func load_audio_folder(path:String):
	audio_datas = []
	current_index = -1
	for file in DirAccess.get_files_at(path):
		if file.get_extension() not in AudioFormats:
			continue
		var file_path = path.path_join(file)
		var file_stream :AudioStream= load(file_path)
		var audio_data = {}
		audio_data["path"] = file_path
		audio_data["title"] = file.get_file().get_basename()
		audio_data["author"] = "-"
		audio_data["duration"] = file_stream.get_length()
		audio_datas.append(audio_data)
	audio_datas_changed.emit()

## Statics
static func convert_format(value:float) -> String:
	"""将秒转换成 00：00 的形式， 超过1小时的音频会多加一个 00 """
	var m = floor(value / 60.0)
	var h = floor(m / 60.0)
	if h > 0:
		m = m - h*60 
	var s = value - m*60 - h*3600
	if not h:
		return str("%02d:%02d" % [m, s])
	else:
		return str("%02d:%02d:%02d" % [h, m, s])
	
