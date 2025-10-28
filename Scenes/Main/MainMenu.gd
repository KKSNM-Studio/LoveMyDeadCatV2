extends Control
"""
Main Menu Scene
"""

@onready var start_button = $VBoxContainer/StartButton
@onready var options_button = $VBoxContainer/OptionsButton
@onready var exit_button = $VBoxContainer/ExitButton

func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	options_button.pressed.connect(_on_options_pressed)
	exit_button.pressed.connect(_on_exit_pressed)

func _on_start_pressed():
	# ไปฉาก Living Room (เราจะสร้างใน Part 3)
	get_tree().change_scene_to_file("res://Scenes/Main/LivingRoom.tscn")

func _on_options_pressed():
	print("Options not implemented yet.")  # ไว้สร้าง Part หลัง

func _on_exit_pressed():
	get_tree().quit()
