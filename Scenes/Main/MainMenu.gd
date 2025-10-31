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
	AudioManager.play_bgm("res://Assets/Audio/bgm/Hooman Me Hungry.wav", true)

func _on_start_pressed():
	# ไปฉาก Living Room (เราจะสร้างใน Part 3)
	AudioManager.play_sfx("res://Assets/Audio/sfx/click.wav")
	get_tree().change_scene_to_file("res://Scenes/Main/LivingRoom.tscn")

func _on_options_pressed():
	print("Options not implemented yet.")  # ไว้สร้าง Part หลัง
	AudioManager.play_sfx("res://Assets/Audio/sfx/click.wav")

func _on_exit_pressed():
	AudioManager.play_sfx("res://Assets/Audio/sfx/click.wav")
	get_tree().quit()
