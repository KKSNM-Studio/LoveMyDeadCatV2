extends Control
"""
Living Room Final Flow Version
- Care limit 3/day
- End Day by CLOCK
- NotePopup on objects
"""

@onready var day_label         = $HUD/DayLabel
@onready var affinity_label    = $HUD/AffinityLabel
@onready var injury_label      = $HUD/InjuryLabel
@onready var state_label       = $HUD/StateLabel
@onready var care_label        = $HUD/CareLabel
@onready var warning_label     = $HUD/WarningLabel

@onready var note_popup        = $NotePopup
@onready var confirm_end       = $ConfirmEndDayDialog

var care_limit_per_day := 3

func _ready():
	_refresh_status()

	# Signals from Global
	Global.connect("affinity_changed", _refresh_status)
	Global.connect("injury_changed", _refresh_status)
	Global.connect("cat_state_changed", _refresh_status)

	# Room interactions
	_connect_room_items()

	# End Day Confirm UI
	confirm_end.get_ok_button().text = "Yes"
	confirm_end.get_cancel_button().text = "No"
	confirm_end.confirmed.connect(_on_confirm_yes)

func _connect_room_items():
	if $ClickLayer.has_node("CatButton"):
		$ClickLayer/CatButton.pressed.connect(_on_cat_clicked)

	if $ClickLayer.has_node("Clock"):
		$ClickLayer/Clock.pressed.connect(_on_clock_clicked)

	# ✅ NOTES — object interactions
	_connect_note_button("SofaButton", "The sofa smells... strange.")
	_connect_note_button("LampButton", "The lamp flickers like it's alive...")
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

func _refresh_status(_v = null):
	day_label.text = "Day: %d / 3" % Global.current_day
	affinity_label.text = "Affinity: %d" % Global.affinity
	injury_label.text = "Injury: %d" % Global.injury
	state_label.text = "State: %s" % Global.cat_state
	care_label.text = "Care Used: %d / 3" % Global.minigames_played_today

	# Disable cat when care limit reached
	if Global.minigames_played_today >= care_limit_per_day:
		$ClickLayer/CatButton.disabled = true
		warning_label.text = "You feel watched. Better stop for today."
	else:
		$ClickLayer/CatButton.disabled = false
		warning_label.text = ""

func _on_cat_clicked():
	if Global.minigames_played_today < care_limit_per_day:
		get_tree().change_scene_to_file("res://Scenes/UI/CareMenu.tscn")
	else:
		_show_note("Not today. Let it rest.")

func _on_clock_clicked():
	if Global.minigames_played_today < care_limit_per_day:
		_show_note("You should take care of the cat first.")
		return
	confirm_end.popup_centered()

func _on_confirm_yes():
	Global.advance_day()

	# Day 3 → go to letter
	if Global.current_day > Global.MAX_DAYS:
		get_tree().change_scene_to_file("res://Scenes/Cutscenes/LetterScene.tscn")
	else:
		get_tree().reload_current_scene()

func _show_note(text: String):
	note_popup.show_note(text)
