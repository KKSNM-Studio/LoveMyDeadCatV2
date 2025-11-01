extends Control
"""
Living Room Final Flow Version
- Care limit 3/day
- End Day by CLOCK (ต้องอาบน้ำก่อน)
- NotePopup on objects
"""

@onready var day_label         = $HUD/DayLabel
@onready var affinity_label    = $HUD/AffinityLabel
@onready var injury_label      = $HUD/InjuryLabel
@onready var state_label       = $HUD/StateLabel
@onready var care_label        = $HUD/CareLabel
@onready var warning_label     = $HUD/WarningLabel

@onready var note_popup        = $NotePopup
@onready var confirm_end       = $ConfirmEnd

func _ready():
	_update_hud()
	warning_label.hide()
	AudioManager.play_bgm("res://Assets/Audio/bgm/Hooman Me Hungry.wav", true)

func _update_hud():
	day_label.text = "Day: %d / %d" % [Global.current_day, Global.MAX_DAYS]
	affinity_label.text = "Affinity: %d" % Global.affinity
	injury_label.text = "Injury: %d" % Global.injury
	state_label.text = "State: %s" % Global.cat_state
	care_label.text = "Care used: %d / 3" % Global.minigames_played_today
	
# Room interactions
	_connect_room_items()

	

# ✅ NOTES — object interactions
	_connect_note_button("Sofa", "The sofa smells... strange.")
	_connect_note_button("Lamp", "The lamp flickers like it's alive...")
	_connect_note_button("Door", "It's locked. Why?")
	_connect_note_button("Box", "Something is moving inside the box...")
	_connect_note_button("Tree", "Dead tree. No leaves. No life.")
	_connect_note_button("Pic", "Someone scratched out a face in this photo.")
	_connect_note_button("Mail", "A letter... but it's sealed.")

func _connect_note_button(node_name: String, text: String):
	if $ClickLayer.has_node(node_name):
		var node = $ClickLayer.get_node(node_name)
		if node.has_signal("pressed"):
			node.pressed.connect(func(): _show_note(text))
			AudioManager.play_sfx("res://Assets/Audio/sfx/click.wav")

func _show_note(text: String):
	note_popup.show_note(text)

# ==== Flow ====
func _connect_room_items():
	if $ClickLayer.has_node("Cat"):
		$ClickLayer/Cat.pressed.connect(_on_cat_clicked)

	if $ClickLayer.has_node("Clock"):
		$ClickLayer/Clock.pressed.connect(_on_clock_clicked)
		

func _on_cat_clicked():
		get_tree().change_scene_to_file("res://Scenes/UI/CareMenu.tscn")
		AudioManager.play_sfx("res://Assets/Audio/sfx/click.wav")


func _on_clock_clicked():
	# ต้องอาบน้ำก่อนจบวัน
	if not Global.did_shower_today:
		warning_label.text = "You must bathe the cat before ending the day."
		warning_label.show()
		return
	confirm_end.popup_centered()
	AudioManager.play_sfx("res://Assets/Audio/sfx/click.wav")

func _on_confirm_yes():
	Global.advance_day()

	# Day 3 → go to letter
	if Global.current_day > Global.MAX_DAYS:
		get_tree().change_scene_to_file("res://Scenes/Cutscenes/LetterScene.tscn")
	else:
		get_tree().reload_current_scene()

func _on_confirm_no():
	confirm_end.hide()
