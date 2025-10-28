extends PopupPanel

@onready var label = $Label

func show_note(text: String):
	label.text = text
	popup_centered()

func _ready():
	hide()
