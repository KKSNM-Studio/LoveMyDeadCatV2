extends Control

@onready var food_pack = $FoodPack
@onready var raw_meat = $RawMeat
@onready var back_button = $BackButton

func _ready():
	food_pack.text = "Cat Food"
	raw_meat.text = "Raw Meat (-10 Affinity)"
	back_button.text = "Back"

	food_pack.pressed.connect(_on_food_pack_pressed)
	raw_meat.pressed.connect(_on_raw_meat_pressed)
	back_button.pressed.connect(_on_back_pressed)

func _on_food_pack_pressed():
	# ไป FeedGame (QTE)
	get_tree().change_scene_to_file("res://Scenes/Minigames/Feed/FeedGame.tscn")

func _on_raw_meat_pressed():
	# ไม่เข้า FeedGame → ลด Affinity แล้วส่งไป Result
	Global.remove_affinity(10)
	Global.set_minigame_result("feed", 0, Global.hearts)
	get_tree().change_scene_to_file("res://Scenes/UI/ResultScreen.tscn")

func _on_back_pressed():
	get_tree().change_scene_to_file("res://Scenes/Main/LivingRoom.tscn")
