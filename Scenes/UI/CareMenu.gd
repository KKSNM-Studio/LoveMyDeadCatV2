extends Control
"""
Care Menu System (Gameplay Version)
- Cat left, Buttons right
- Show cat reaction on hover per activity (daily gestures)
- Limit care 3/day
- Connect to minigames
"""

# -------- Nodes --------
@onready var feed_button   = $ButtonArea/FeedButton
@onready var stroke_button = $ButtonArea/StrokeButton
@onready var shower_button = $ButtonArea/ShowerButton
@onready var fix_button    = $ButtonArea/FixWoundButton
@onready var back_button   = $BackButton
@onready var cat_sprite: Sprite2D = $CatPanel/CatSprite

func _ready():
	# hover → แสดงอารมณ์แมว
	feed_button.mouse_entered.connect(func(): on_hover_activity("feed"))
	stroke_button.mouse_entered.connect(func(): on_hover_activity("stroke"))
	shower_button.mouse_entered.connect(func(): on_hover_activity("shower"))
	fix_button.mouse_entered.connect(func(): on_hover_activity("fix"))
	for b in [feed_button, stroke_button, shower_button, fix_button]:
		b.mouse_exited.connect(func(): reset_cat_face())

	# click → ไปมินิเกม
	feed_button.pressed.connect(func(): _start_game("feed"))
	stroke_button.pressed.connect(func(): _start_game("stroke"))
	shower_button.pressed.connect(func(): _start_game("shower"))
	fix_button.pressed.connect(func(): _start_game("fix"))
	back_button.pressed.connect(_back_to_room)

	_update_cat_display()

# -------- Hover gestures --------
func on_hover_activity(act: String):
	var mood = Global.daily_gestures.get(act, "neutral")
	match mood:
		"happy":
			cat_sprite.texture = preload("res://Assets/Art/Cat/CatLikeBlood/CatLikeBlood_0001.png")
		"disliked":
			cat_sprite.texture = preload("res://Assets/Art/Cat/CatConfuseBlood/CatConfuseBlood_0001.png")
		"angry":
			cat_sprite.texture = preload("res://Assets/Art/Cat/CatAngryBlood/cat_angry.png")
		_:
			reset_cat_face()

func reset_cat_face():
	cat_sprite.texture = preload("res://Assets/Art/Cat/CatStandingBlood/CatStandingBlood_0001.png")

# -------- Cat State --------
func _update_cat_display():
	match Global.cat_state:
		"normal":
			cat_sprite.texture = preload("res://Assets/Art/Cat/CatStandingNormal/CatStandingNormal_0001.png")
		"injury":
			cat_sprite.texture = preload("res://Assets/Art/Cat/CatStandingBlood/CatStandingBlood_0001.png")
		"demon":
			cat_sprite.texture = preload("res://Assets/Art/Cat/CatDevilBlood/CatDevilBlood_0001.png")

# -------- Flow to Minigame --------
func _start_game(activity):
	if Global.minigames_played_today >= 3:
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
