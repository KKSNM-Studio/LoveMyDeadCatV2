extends Node
"""
Global Game State System (Core)
- Affinity / Injury / Hearts / Days
- Daily Preference (random per day)
- Minigame Result plumbing
"""

signal affinity_changed(value)
signal injury_changed(value)
signal day_changed(value)
signal cat_state_changed(state)

const MAX_AFFINITY := 100
const MIN_AFFINITY := 0
const MAX_HEARTS := 3
const MAX_DAYS := 3
const GOOD_ENDING_THRESHOLD := 70

const DEMON_AFFINITY_THRESHOLD := 30
const DEMON_INJURY_THRESHOLD := 3
const INJURY_AFFINITY_PENALTY := 5

var affinity: int = 50
var injury: int = 0
var current_day: int = 1
var hearts: int = MAX_HEARTS
var cat_state: String = "normal"

var daily_preference := {
	"feed": "neutral",
	"stroke": "neutral",
	"fix": "neutral",
	"shower": "must"
}

var minigames_played_today: int = 0
var last_minigame_activity: String = ""
var last_minigame_score: int = 0
var last_minigame_hearts_left: int = MAX_HEARTS

func _ready():
	randomize_daily_preference()
	_update_cat_state()

# ---- Affinity / Injury ----
func add_affinity(amount: int) -> void:
	affinity = clamp(affinity + amount, MIN_AFFINITY, MAX_AFFINITY)
	emit_signal("affinity_changed", affinity)
	_update_cat_state()

func remove_affinity(amount: int) -> void:
	add_affinity(-amount)

func add_injury(amount: int = 1) -> void:
	injury += amount
	emit_signal("injury_changed", injury)
	_update_cat_state()

func heal_injury(amount: int = 1) -> void:
	injury = max(injury - amount, 0)
	emit_signal("injury_changed", injury)
	_update_cat_state()

# ---- Hearts ----
func reset_hearts() -> void:
	hearts = MAX_HEARTS

func lose_heart() -> int:
	hearts = max(0, hearts - 1)
	return hearts

func is_out_of_hearts() -> bool:
	return hearts <= 0

# ---- Cat State ----
func _update_cat_state() -> void:
	var new_state := "normal"
	if injury >= DEMON_INJURY_THRESHOLD or affinity < DEMON_AFFINITY_THRESHOLD:
		new_state = "demon"
	elif injury > 0:
		new_state = "injury"
	if new_state != cat_state:
		cat_state = new_state
		emit_signal("cat_state_changed", cat_state)

func get_cat_state() -> String:
	return cat_state

# ---- Day Flow ----
func reset_care_today() -> void:
	minigames_played_today = 0

func advance_day() -> void:
	if injury > 0:
		remove_affinity(injury * INJURY_AFFINITY_PENALTY)
	reset_care_today()
	current_day += 1
	randomize_daily_preference()
	emit_signal("day_changed", current_day)

func is_final_day() -> bool:
	return current_day == MAX_DAYS

func is_game_over() -> bool:
	return current_day > MAX_DAYS

# ---- Ending ----
func determine_ending() -> String:
	return "good" if affinity >= GOOD_ENDING_THRESHOLD else "bad"

# ---- Daily Preference ----
func randomize_daily_preference() -> void:
	var moods := ["like", "neutral", "hate"]
	daily_preference["feed"] = moods.pick_random()
	daily_preference["stroke"] = moods.pick_random()
	daily_preference["fix"] = moods.pick_random()
	daily_preference["shower"] = "must"

func get_daily_preference(activity: String) -> String:
	return daily_preference.get(activity, "neutral")

# ---- QTE helper ----
func get_perfect_zone_size() -> float:
	return 40.0

# ---- Minigame Result Plumbing ----
func set_minigame_result(activity: String, score: int, hearts_left: int) -> void:
	last_minigame_activity = activity
	last_minigame_score = score
	last_minigame_hearts_left = hearts_left

func record_minigame_played() -> void:
	minigames_played_today += 1

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
			add_affinity(score + 1)
	record_minigame_played()
