extends Node
const SAVE_PATH := "user://save.json"

func auto_save():
	var data = {
		"affinity": Global.affinity,
		"injury": Global.injury,
		"day": Global.current_day,
		"state": Global.cat_state
	}
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))

func load_save():
	if not FileAccess.file_exists(SAVE_PATH):
		return false

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var json = JSON.parse_string(file.get_as_text())

	if typeof(json) == TYPE_DICTIONARY:
		Global.affinity = json.affinity
		Global.injury = json.injury
		Global.current_day = json.day
		Global.cat_state = json.state
		return true
	else:
		return false
