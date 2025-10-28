extends Control

@onready var qte = $QTE
@onready var hearts_label = $UI/HeartsLabel
@onready var score_label = $UI/ScoreLabel
@onready var help_label = $UI/HelpLabel

var Controller = preload("res://Scripts/MinigameController.gd")
var score := 0

func _ready():
	_update_ui()
	help_label.text = "Click when pointer hits!"

	# โหลด controller
	var c = Controller.new()
	add_child(c)

	# daily preference multiplier
	var pref = Global.get_daily_preference("feed")
	var mul := 1.0
	if pref == "like":
		mul = 1.2
	elif pref == "hate":
		mul = 0.8

	# รับสัญญาณ QTE และเริ่มเกม
	if qte.has_signal("qte_completed"):
		qte.connect("qte_completed", _on_qte_feedback)

	c.minigame_finished.connect(_on_feed_done)
	c.setup(qte, "feed", mul)

func _update_ui():
	hearts_label.text = "Hearts: %d" % Global.hearts
	score_label.text = "Score: %d" % score

func _on_qte_feedback(result, _qte_score):
	match result:
		"perfect":
			help_label.text = "Perfect!"
			score += 2
		"safe":
			help_label.text = "Good!"
			score += 1
		"danger":
			help_label.text = "Miss!"
	_update_ui()

func _on_feed_done(payload):
	# ส่งผล Feed เข้า Global
	Global.set_minigame_result("feed", score, Global.hearts)
	Global.apply_minigame_score("feed", score)

	get_tree().change_scene_to_file("res://Scenes/UI/ResultScreen.tscn")
