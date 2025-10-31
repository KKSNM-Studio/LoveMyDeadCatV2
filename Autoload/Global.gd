extends Node
"""
Global Game State System (Core)
- Affinity / Injury / Hearts / Days
- Daily Preference (random per day)
- Minigame Result plumbing

(อัปเดต)
- START_AFFINITY = 50
- ENDING_THRESHOLD = 70
- did_shower_today (ต้องอาบน้ำทุกวัน)
- daily_gestures (อารมณ์แมวรายวันต่อ activity)
- decide_ending() ตัดสิน Good/Bad
"""

signal affinity_changed(value)
signal injury_changed(value)
signal day_changed(value)
signal cat_state_changed(state)

const MAX_AFFINITY := 100
const MIN_AFFINITY := 0
const MAX_HEARTS := 3
const MAX_DAYS := 3

# ===== Added (ตามบรีฟ) =====
const START_AFFINITY := 50              # ค่าเริ่มต้นความผูกพัน
const ENDING_THRESHOLD := 70            # เกณฑ์ Good Ending
var did_shower_today: bool = false      # ต้องอาบน้ำก่อนจบวัน
var daily_gestures := {                 # อารมณ์แมวรายวันต่อกิจกรรม
	"feed": "neutral",
	"stroke": "neutral",
	"shower": "happy",  # อาบน้ำให้ผลบวกเสมอ
	"fix": "neutral",
}

# ===== Game State =====
var affinity := START_AFFINITY
var injury := 0
var hearts := MAX_HEARTS
var current_day := 1
var minigames_played_today := 0
var last_minigame_activity := ""
var last_minigame_score := 0
var cat_state := "normal"  # "normal"|"injury"|"demon" (ถ้ามีใช้)

func _ready():
	randomize()
	_generate_daily_gestures()

# ===== Reset / Day Flow =====
func reset_game_state():
	affinity = START_AFFINITY
	injury = 0
	hearts = MAX_HEARTS
	current_day = 1
	minigames_played_today = 0
	did_shower_today = false
	_generate_daily_gestures()
	emit_signal("affinity_changed", affinity)
	emit_signal("injury_changed", injury)
	emit_signal("day_changed", current_day)

func reset_hearts():
	hearts = MAX_HEARTS

func lose_heart() -> int:
	hearts = max(0, hearts - 1)
	return hearts

func record_minigame_played():
	minigames_played_today += 1

func set_minigame_result(activity: String, score_band: int, hearts_left: int):
	last_minigame_activity = activity
	last_minigame_score = score_band
	# สามารถเพิ่มบันทึกอื่น ๆ ได้ที่นี่

func advance_day():
	current_day += 1
	minigames_played_today = 0
	did_shower_today = false
	reset_hearts()
	_generate_daily_gestures()
	emit_signal("day_changed", current_day)

# ===== Daily gestures =====
func _generate_daily_gestures():
	var moods = ["happy","disliked","angry"]
	daily_gestures = {
		"feed": moods.pick_random(),
		"stroke": moods.pick_random(),
		"shower": "happy",
		"fix": moods.pick_random(),
	}

# ===== Scoring =====
func add_affinity(v: int):
	affinity = clamp(affinity + v, MIN_AFFINITY, MAX_AFFINITY)
	emit_signal("affinity_changed", affinity)

func add_injury(v: int):
	injury = max(0, injury + v)
	emit_signal("injury_changed", injury)
	if injury > 0:
		cat_state = "injury"
		emit_signal("cat_state_changed", cat_state)

func heal_injury(v: int):
	injury = max(0, injury - v)
	emit_signal("injury_changed", injury)
	if injury == 0 and cat_state == "injury":
		cat_state = "normal"
		emit_signal("cat_state_changed", cat_state)

func apply_minigame_score(activity: String, score: int) -> void:
	match activity:
		"stroke":
			add_affinity(int(round(score * 1.5)))
		"feed":
			add_affinity(score * 2)
		"fix":
			if score == 0:
				add_injury(1)
			elif score >= 4:
				heal_injury(1)
		"shower":
			# อาบน้ำให้ผลบวกเสมอ (กันคะแนนติดลบ)
			add_affinity(max(0, score) + 1)
	record_minigame_played()

# ===== Shower flag =====
func mark_shower_done():
	did_shower_today = true

# ===== Ending =====
func decide_ending():
	if affinity >= ENDING_THRESHOLD:
		get_tree().change_scene_to_file("res://Scenes/Endings/GoodEnding.tscn")
	else:
		get_tree().change_scene_to_file("res://Scenes/Endings/BadEnding.tscn")
