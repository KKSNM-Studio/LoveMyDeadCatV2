# res://Scripts/MinigameResult.gd
extends Node

func apply_result(result: Dictionary) -> void:
	var score: int = int(result.get("score", 0))
	var activity := String(result.get("activity", ""))

	match activity:
		"stroke":
			Global.add_affinity(roundi(score * 1.5))
		"feed":
			Global.add_affinity(score * 2)
		"fix": # FixWound
			if score >= 4:
				Global.heal_injury(1)
				Global.add_affinity(3)
			else:
				Global.add_injury(1)
		"shower":
			Global.add_affinity(score + 2)

	Global.record_minigame_played()
