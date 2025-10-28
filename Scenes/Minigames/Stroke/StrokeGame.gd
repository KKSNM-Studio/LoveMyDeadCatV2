extends Control
"""
Stroke Minigame (Pet the Cat)
- 3 QTE rounds
- Uses unified result system
"""

@onready var qte: Node = $QTECircle
@onready var info_label = $InfoLabel  # optional
var rounds := 3
var current_round := 0
var total_score := 0


func _ready():
	Global.reset_hearts()
	_connect_qte()
	_start_next_round()


func _connect_qte():
	if qte.has_signal("qte_completed"):
		qte.connect("qte_completed", _on_qte_completed)
	elif qte.has_signal("qte_finished"):
		qte.connect("qte_finished", _on_qte_finished_proxy)


func _start_next_round():
	if Global.is_out_of_hearts():
		_finish_game()
		return

	current_round += 1
	if current_round > rounds:
		_finish_game()
		return

	# set activity & preference
	if qte.has_method("set_activity"):
		qte.set_activity("stroke")
	if qte.has_method("set_preference_multiplier"):
		var pref = Global.get_daily_preference("stroke")
		var mul := 1.0
		if pref == "like":
			mul = 1.2
		elif pref == "hate":
			mul = 0.8
		qte.set_preference_multiplier(mul)

	# demon → harder
	if Global.cat_state == "demon" and qte.has_method("increase_difficulty"):
		qte.increase_difficulty()

	if qte.has_method("start_qte"):
		qte.start_qte()


func _on_qte_finished_proxy(result: String):
	# (แก้ ternary ให้เป็น GDScript รูปแบบ if-else)
	var score := 3 if result == "perfect" else (1 if result == "safe" else 0)
	_handle_score(score)


func _on_qte_completed(result: String, score: int):
	_handle_score(score)


func _handle_score(score: int):
	total_score += score
	_start_next_round()


func _finish_game():
	var band := 0
	if total_score >= 7:
		band = 3
	elif total_score >= 3:
		band = 1
	else:
		band = 0

	Global.set_minigame_result("stroke", band, Global.hearts)
	Global.apply_minigame_score("stroke", band)
	get_tree().change_scene_to_file("res://Scenes/UI/ResultScreen.tscn")
