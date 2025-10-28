extends Control

@onready var text_label = $Label
@onready var continue_button = $Button

func _ready():
	# จดหมายหลังจบวันที่ 3
	text_label.text = "A letter arrived.\nNo sender.\nThe handwriting is familiar..."
	continue_button.text = "Continue"
	continue_button.pressed.connect(_go_next)

func _go_next():
	# ต่อไปสู่ Ending เลย (จะไปทำใน Batch4)
	if Global.determine_ending() == "good":
		get_tree().change_scene_to_file("res://Scenes/Endings/GoodEnding.tscn")
	else:
		get_tree().change_scene_to_file("res://Scenes/Endings/BadEnding.tscn")
