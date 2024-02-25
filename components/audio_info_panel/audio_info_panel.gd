extends PanelContainer

signal pressed

const ICON_PLAY_BUTTON_01 = preload("res://resource/icons/play-button-01.png")
const ICON_PAUSE_01 = preload("res://resource/icons/pause-01.png")

@onready var texture_rect_status = %TextureRectStatus
@onready var label_title = %LabelTitle
@onready var label_author = %LabelAuthor
@onready var label_duration = %LabelDuration

@onready var button = %Button

var index :int= -1

func _ready():
	button.pressed.connect(emit_signal.bind("pressed"))

func set_index(value:int):
	index = value

func set_title(value:String):
	label_title.text = value

func set_author(value:String):
	label_author.text = value

func set_duration(value:String):
	label_duration.text = value

func set_active(value:bool, state:bool):
	if not value:
		texture_rect_status.texture = null
	else:
		var icon = ICON_PLAY_BUTTON_01
		if state:
			icon = ICON_PAUSE_01
		texture_rect_status.texture = icon
