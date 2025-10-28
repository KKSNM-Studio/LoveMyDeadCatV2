extends Control

@onready var title_label = $VBoxContainer/TitleLabel
@onready var message_label = $VBoxContainer/MessageLabel
@onready var continue_button = $VBoxContainer/ContinueButton

func _ready():
	title_label.text = "Good Ending"
	message_label.text = "Even broken things can be loved.\nYou stayed. And that was enough."
	continue_button.text = "Return to Title"
	continue_button.pressed.connect(_on_return)

func _on_return():
	get_tree().change_scene_to_file("res://Scenes/Main/MainMenu.tscn")
