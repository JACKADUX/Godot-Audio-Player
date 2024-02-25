extends Control

@onready var button_prev = %ButtonPrev
@onready var button_play = %ButtonPlay
@onready var button_pause = %ButtonPause
@onready var button_next = %ButtonNext

@onready var label_before = %LabelBefore
@onready var slider_bar = %SliderBar
@onready var label_after = %LabelAfter

@onready var audio_infos_manager = %AudioInfosManager

@onready var custom_window_bar = %CustomWindowBar


const AUDIO_INFO_PANEL = preload("res://components/audio_info_panel/audio_info_panel.tscn")

var _drag := false

func _ready():
	button_play.pressed.connect(AudioPlayer.play_audio)
	button_pause.pressed.connect(AudioPlayer.stop_audio)
	button_prev.pressed.connect(AudioManager.prev_audio)
	button_next.pressed.connect(AudioManager.next_audio)
	
	AudioManager.index_changed.connect(func():
		AudioPlayer.init_audio(AudioManager.get_current_audio_path())
		AudioPlayer.play_audio()
		button_prev.disabled = false
		button_next.disabled = false
		var index = AudioManager.get_current_index()
		var count = AudioManager.get_audio_count()
		if index == 0:
			button_prev.disabled = true
		if index == count -1:
			button_next.disabled = true
			
	)
	
	AudioManager.audio_datas_changed.connect(func():
		AudioPlayer.stop()
		for child in audio_infos_manager.get_children():
			audio_infos_manager.remove_child(child)
			child.queue_free()
		var index = 0
		for audio_data in AudioManager.get_audio_datas():
			var audio_info_panel = AUDIO_INFO_PANEL.instantiate()
			audio_infos_manager.add_child(audio_info_panel)
			audio_info_panel.set_title(audio_data.title)
			audio_info_panel.set_author(audio_data.author)
			audio_info_panel.set_duration(AudioManager.convert_format(audio_data.duration))
			audio_info_panel.set_index(index)
			audio_info_panel.pressed.connect(func():
				if AudioPlayer.current_file != audio_data.path:
					AudioManager.set_current_index(index)
					return 
				if not AudioPlayer.playing:
					AudioPlayer.play_audio()
				else:
					AudioPlayer.stop_audio()
				)
			index += 1
		if audio_infos_manager.get_child_count() != 0:
			AudioManager.set_current_index(0)
		AudioPlayer.stop_audio()
	)
	
	AudioPlayer.audio_changed.connect(func():
		slider_bar.max_value = AudioPlayer.get_duration()
		custom_window_bar.set_audio_title(AudioPlayer.get_audio_name())
		_update_slider(0)
		_update_list_icon()
	)
	AudioPlayer.audio_played.connect(func():
		button_play.hide()
		button_pause.show()
		_update_list_icon()
	)
	AudioPlayer.audio_stoped.connect(func():
		button_pause.hide()
		button_play.show()
		_update_list_icon()
	)
	AudioPlayer.time_changed.connect(func():
		if _drag:
			return 
		_update_slider(AudioPlayer.get_current_time())
	)
	
	slider_bar.drag_started.connect(func():
		_drag = true
	)
	slider_bar.value_changed.connect(func(value:float):
		if not _drag:
			return 
		_update_slider(value)
	)
	slider_bar.drag_ended.connect(func(value):
		_drag = false
		AudioPlayer.set_time(slider_bar.value)
	)	
	
	custom_window_bar.folder_open_pressed.connect(func():
		var _on_folder_selected = func(status:bool, selected_paths:PackedStringArray, selected_filter_index:int):
			if not status:
				return 
			AudioManager.load_audio_folder(selected_paths[0])
			
		DisplayServer.file_dialog_show("open folder","","",false,
									DisplayServer.FILE_DIALOG_MODE_OPEN_DIR,
									[],
									_on_folder_selected)
	)
	
	custom_window_bar.claps_pressed.connect(func():
		if custom_window_bar.get_fold_state():
			fold()
		else:
			unfold()
	)
	
	#AudioManager.load_audio_folder("res://resource/audios")
	fold()
	

## Utils
func fold():
	audio_infos_manager.hide()
	DisplayServer.window_set_size(Vector2(400, 120), 0)
	
func unfold():
	audio_infos_manager.show()
	DisplayServer.window_set_size(Vector2(400, 400), 0)

func _update_list_icon():
	for child in audio_infos_manager.get_children():
		child.set_active(AudioManager.current_index == child.index, AudioPlayer.playing)

func _update_slider(pos):
	label_before.text = AudioManager.convert_format(pos)
	slider_bar.value = pos
	label_after.text = AudioManager.convert_format(AudioPlayer.get_duration())
	
	
