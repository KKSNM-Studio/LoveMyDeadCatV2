extends Node
"""
AudioManager.gd — ตัวจัดการเสียงหลักของเกม
(แนะนำให้ Autoload)

รองรับ:
- เล่น SFX / BGM
- Fade in / Fade out
- Crossfade เพลง
- ปรับ volume หลัก
"""

@onready var bgm_player := AudioStreamPlayer.new()
@onready var sfx_player := AudioStreamPlayer.new()
@onready var fade_timer := Timer.new()

var bgm_volume := 0.8
var sfx_volume := 1.0
var fade_time := 1.5

func _ready():
	add_child(bgm_player)
	add_child(sfx_player)
	add_child(fade_timer)
	bgm_player.volume_db = linear_to_db(bgm_volume)
	sfx_player.volume_db = linear_to_db(sfx_volume)

# === เล่นเสียงสั้น (SFX) ===
func play_sfx(stream_path: String):
	if not ResourceLoader.exists(stream_path):
		push_warning("Missing SFX: %s" % stream_path)
		return
	var sfx = load(stream_path)
	sfx_player.stream = sfx
	sfx_player.volume_db = linear_to_db(sfx_volume)
	sfx_player.play()

# === เล่นเพลง (BGM) ===
func play_bgm(stream_path: String, fade_in: bool = true):
	if not ResourceLoader.exists(stream_path):
		push_warning("Missing BGM: %s" % stream_path)
		return
	var new_bgm = load(stream_path)
	if bgm_player.stream == new_bgm:
		return # เล่นอยู่แล้ว
	if fade_in:
		_fade_out_bgm()
		await get_tree().create_timer(fade_time).timeout
	bgm_player.stream = new_bgm
	bgm_player.volume_db = -80 if fade_in else linear_to_db(bgm_volume)
	bgm_player.play()
	if fade_in:
		_fade_in_bgm()

func stop_bgm():
	_fade_out_bgm()

# === Private fade helper ===
func _fade_out_bgm():
	var start_db = bgm_player.volume_db
	var end_db = -80
	var step = (start_db - end_db) / (fade_time * 60.0)
	for i in range(int(fade_time * 60)):
		bgm_player.volume_db -= step
		await get_tree().process_frame
	bgm_player.stop()

func _fade_in_bgm():
	var start_db = -80
	var end_db = linear_to_db(bgm_volume)
	var step = (end_db - start_db) / (fade_time * 60.0)
	for i in range(int(fade_time * 60)):
		bgm_player.volume_db += step
		await get_tree().process_frame

# === Utility ===
func set_bgm_volume(vol: float):
	bgm_volume = clamp(vol, 0, 1)
	bgm_player.volume_db = linear_to_db(bgm_volume)

func set_sfx_volume(vol: float):
	sfx_volume = clamp(vol, 0, 1)
	sfx_player.volume_db = linear_to_db(sfx_volume)
