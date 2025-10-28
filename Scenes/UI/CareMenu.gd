extends Control
"""
Care Menu System (Gameplay Version)
- Show cat reaction on hover
- Limit care 3 times/day
- Daily preference (mood effect placeholder)
- Connect to minigames
"""

# -------- Nodes --------
@onready var feed_button   = $ButtonArea/FeedButton
@onready var stroke_button = $ButtonArea/StrokeButton
@onready var shower_button = $ButtonArea/ShowerButton
@onready var fix_button    = $ButtonArea/FixWoundButton
@onready var back_button   = $ButtonArea/BackButton

@onready var cat_sprite      = $CatArea/CatSprite
@onready var reaction_sprite = $CatArea/ReactionSprite


# -------- READY --------
func _ready():
	# ✅ ดึง Daily Preference จาก Global (ไม่ต้องสุ่มเอง)
	# (ของเดิมสุ่มเอง → คอมเมนต์เก็บไว้)
	# _generate_daily_preference()
	_setup_buttons()
	_update_cat_display()
	_update_button_lock()


# -------- Button Setup --------
func _setup_buttons():
	# --- Hover reaction ---
	feed_button.mouse_entered.connect(func(): _show_reaction_for("feed"))
	stroke_button.mouse_entered.connect(func(): _show_reaction_for("stroke"))
	shower_button.mouse_entered.connect(func(): _show_reaction_for("shower"))
	fix_button.mouse_entered.connect(func(): _show_reaction_for("fix"))

	# reset เมื่อออกจากปุ่ม
	feed_button.mouse_exited.connect(_reset_reaction)
	stroke_button.mouse_exited.connect(_reset_reaction)
	shower_button.mouse_exited.connect(_reset_reaction)
	fix_button.mouse_exited.connect(_reset_reaction)

	# --- Go Minigame ---
	feed_button.pressed.connect(func(): _start_game("feed"))
	stroke_button.pressed.connect(func(): _start_game("stroke"))
	shower_button.pressed.connect(func(): _start_game("shower"))
	fix_button.pressed.connect(func(): _start_game("fix"))
	back_button.pressed.connect(_back_to_room)


# -------- Button Lock System --------
func _update_button_lock():
	if Global.minigames_played_today >= 3:
		feed_button.disabled = true
		stroke_button.disabled = true
		shower_button.disabled = true
		fix_button.disabled = true


# -------- Reaction System --------
func _show_reaction_for(activity: String):
	var pref = Global.get_daily_preference(activity)

	match pref:
		"like":
			reaction_sprite.texture = preload("res://Assets/Cat/reaction_happy.png")
		"hate":
			reaction_sprite.texture = preload("res://Assets/Cat/reaction_angry.png")
		"neutral":
			reaction_sprite.texture = preload("res://Assets/Cat/reaction_neutral.png")
		"must":
			reaction_sprite.texture = preload("res://Assets/Cat/reaction_neutral.png")

func _reset_reaction():
	reaction_sprite.texture = null  # กลับเป็นหน้าเนียน ๆ เฉย ๆ


# -------- Cat State --------
func _update_cat_display():
	match Global.cat_state:
		"normal":
			cat_sprite.texture = preload("res://Assets/Cat/cat_normal.png")
		"injury":
			cat_sprite.texture = preload("res://Assets/Cat/cat_injury.png")
		"demon":
			cat_sprite.texture = preload("res://Assets/Cat/cat_demon.png")


# -------- Flow to Minigame --------
func _start_game(activity):
	if Global.minigames_played_today >= 3:
		print("[CareMenu] Care limit reached.")
		return

	match activity:
		"feed":
			get_tree().change_scene_to_file("res://Scenes/Minigames/Feed/Kitchen.tscn")
		"stroke":
			get_tree().change_scene_to_file("res://Scenes/Minigames/Stroke/StrokeGame.tscn")
		"shower":
			get_tree().change_scene_to_file("res://Scenes/Minigames/Shower/ShowerGame.tscn")
		"fix":
			get_tree().change_scene_to_file("res://Scenes/Minigames/FixWound/FixWoundGame.tscn")


func _back_to_room():
	get_tree().change_scene_to_file("res://Scenes/Main/LivingRoom.tscn")


# -------- OLD CODE (คอมเมนต์เก็บไว้) --------
# func _generate_daily_preference():
#     var moods = ["like", "neutral", "hate"]
#     daily_preference = {
#         "feed": moods.pick_random(),
#         "stroke": moods.pick_random(),
#         "shower": "must",
#         "fix": moods.pick_random()
#     }
