# res://Scripts/MinigameController.gd
extends Node
signal minigame_finished(payload)


const MAX_ROUNDS := 3
var current_round := 0
var score := 0
var activity_name := ""
var qte: Node = null

func setup(qte_node: Node, activity: String, pref_mul: float = 1.0) -> void:
	activity_name = activity
	qte = qte_node

	# set activity + preference multiplier if available
	if qte.has_method("set_activity"):
		qte.set_activity(activity)
	if qte.has_method("set_preference_multiplier"):
		qte.set_preference_multiplier(pref_mul)

	# connect QTE signals (prefer new one, fallback to old)
	if qte.has_signal("qte_finished"):
		qte.connect("qte_finished", Callable(self, "_on_qte_result"))
	elif qte.has_signal("qte_completed"):
		qte.connect("qte_completed", Callable(self, "_on_qte_result_legacy"))

	Global.reset_hearts()
	_start_round()

func _start_round():
	current_round += 1
	if qte.has_method("show_qte"):
		qte.show_qte()
	if qte.has_method("start_qte"):
		qte.start_qte()

func _on_qte_result(result: String) -> void:
	match result:
		"perfect":
			score += 2
		"safe":
			score += 1
		"danger":
			if Global.lose_heart() <= 0:
				return _end_minigame()
	if current_round < MAX_ROUNDS:
		_start_round()
	else:
		_end_minigame()

func _on_qte_result_legacy(result: String, _score: int) -> void:
	_on_qte_result(result)

func _end_minigame():
	if qte and qte.has_method("stop_qte"):
		qte.stop_qte()
	if qte and qte.has_method("hide_qte"):
		qte.hide_qte()

	# handoff to Global
	Global.set_minigame_result(activity_name, score, Global.hearts)
	Global.apply_minigame_score(activity_name, score)
	# emit signal to notify parent scene
	emit_signal("minigame_finished", {
		"activity": activity_name,
		"score": score,
		"hearts": Global.hearts
		})

	# go to Result
	get_tree().change_scene_to_file("res://Scenes/UI/ResultScreen.tscn")
