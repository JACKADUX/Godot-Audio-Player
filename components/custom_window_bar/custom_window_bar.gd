extends PanelContainer

signal folder_open_pressed
signal claps_pressed

@onready var btn_minimize_window = %BtnMinimizeWindow
@onready var btn_close_window = %BtnCloseWindow

@onready var button_open = %ButtonOpen
@onready var button_claps = %ButtonClaps

@onready var window_state_component = %WindowStateComponent
@onready var window_drag_component = %WindowDragComponent

@onready var control_title_area = %ControlTitleArea
@onready var label_window_title = %LabelWindowTitle
@onready var label_audio_title = %LabelAudioTitle


var _fold_state:= true

func _ready():
	btn_minimize_window.pressed.connect(window_state_component.set_minimized)
	btn_close_window.pressed.connect(window_state_component.quit)
	button_open.pressed.connect(emit_signal.bind("folder_open_pressed"))
	button_claps.pressed.connect(func():
		_fold_state = not _fold_state
		button_claps.flip_v = not _fold_state
		emit_signal("claps_pressed")
	)
	
	control_title_area.mouse_entered.connect(func():
		if window_drag_component.is_dragging():
			return 
		var tween = get_tree().create_tween()
		tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC).set_parallel(true)
		tween.tween_property(label_window_title, "position", Vector2(0,0),0.2).from(Vector2(0,-32))
		tween.tween_property(label_audio_title, "position", Vector2(0,32),0.2).from(Vector2(0,0))
	)
	control_title_area.mouse_exited.connect(func():
		if window_drag_component.is_dragging():
			return 
		var tween = get_tree().create_tween()
		tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC).set_parallel(true)
		tween.tween_property(label_window_title, "position", Vector2(0,-32),0.2).from(Vector2(0,0))
		tween.tween_property(label_audio_title, "position", Vector2(0,0),0.2).from(Vector2(0,32))
		
	)	
	
	bind_in_out_tween(btn_minimize_window)
	bind_in_out_tween(btn_close_window)
	bind_in_out_tween(button_open)
	bind_in_out_tween(button_claps)

func get_fold_state():
	return _fold_state
			
func _notification(what):
	if what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		if window_drag_component.is_dragging():
			window_drag_component.stop_drag()
			
func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				pass
			elif window_drag_component.is_dragging():
				window_drag_component.stop_drag()
		
	if event is InputEventMouseMotion:
		if event.button_mask == MOUSE_BUTTON_MASK_LEFT:
			if not window_drag_component.is_dragging():
				window_drag_component.start_drag()
			

func set_audio_title(value:String):
	label_audio_title.text = value
	
func bind_in_out_tween(node:Node):
	node.mouse_entered.connect(func():
		var tween = get_tree().create_tween()
		tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(node, "modulate:a", 1, 0.2).from(0)
	)
	node.mouse_exited.connect(func():
		var tween = get_tree().create_tween()
		tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(node, "modulate:a", 0, 0.2).from(1)
	)	
	node.modulate.a = 0

