extends Control

@onready var title_label = $VBox/TitleLabel
@onready var image_frame = $VBox/ImageFrame
@onready var flavor_text = $VBox/FlavorText
@onready var continue_button = $VBox/ContinueButton

func _ready():
	# ✅ ย้ายบันทึก Care มาไว้ที่ _ready() เพื่อกัน count พัง
	Global.record_minigame_played()
	_setup_screen()
	continue_button.pressed.connect(_on_continue)

func _setup_screen():
	var act = Global.last_minigame_activity
	var score = Global.last_minigame_score

	# Title
	match act:
		"feed": title_label.text = "FEED RESULT"
		"stroke": title_label.text = "PETTING RESULT"
		"fix": title_label.text = "WOUND TREATMENT"
		"shower": title_label.text = "SHOWER RESULT"
		_: title_label.text = "RESULT"

	# Flavor Text (Dark Minimal Style)
	flavor_text.text = _get_dark_message(act, score)

	# Placeholder for image (คุณใส่รูปทีหลัง)
	image_frame.texture = null

func _get_dark_message(act, score):
	var aff = Global.affinity
	var mood = ""

	# Affinity tone
	if aff >= 70:
		mood = "It feels a little closer to you now."
	elif aff >= 40:
		mood = "It watches you silently."
	else:
		mood = "It seems distant… like it doesn't recognize you anymore."

	# Activity result overlay
	match act:
		"stroke":
			match score:
				3: return "Its fur felt warm for a moment.\n" + mood
				1: return "It allowed your touch.\n" + mood
				0: return "It flinched.\nDid it hate that?\n" + mood

		"feed":
			match score:
				3: return "It ate calmly.\nTrust doesn't need words.\n" + mood
				1: return "It hesitated before eating.\n" + mood
				0: return "It didn't want what you gave.\nYou forced it.\n" + mood

		"fix":
			match score:
				2,1: return "It blinked slowly.\nIt endures the pain.\n" + mood
				0: return "You hurt it.\nIts eyes were empty.\n" + mood

		"shower":
			match score:
				3,2,1: return "The water washed its fur, not its past.\n" + mood
				0: return "It resisted, but you continued.\n" + mood

		_:
			return "Something feels wrong.\n" + mood


func _on_continue():
	get_tree().change_scene_to_file("res://Scenes/Main/LivingRoom.tscn")
