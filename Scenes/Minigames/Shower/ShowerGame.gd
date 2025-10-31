extends Control

# ---------- State machine ----------
enum State { WET, SOAP, RINSE, DRY, DONE }
var current_state: int = State.WET
var current_tool: String = ""   # "shower" | "soap" | "towel"

# ---------- Node refs ----------
@onready var cat: Control          = $Cat
@onready var status_label: Label   = $StatusLabel
@onready var shower_button: TextureButton = $ToolsPanel/ShowerHead
@onready var soap_button: TextureButton  = $ToolsPanel/Soap
@onready var towel_button: TextureButton  = $ToolsPanel/Towel
@onready var water_particles       = $WaterParticles    # CPUParticles2D
@onready var soap_particles        = $SoapParticles     # CPUParticles2D
@onready var soap_area: Area2D     = $SoapArea          # สำหรับต่อยอด Area ตรวจสบู่ติดตัวแมว

# ---------- Progress ----------
const WET_TARGET := 100
const SOAP_TARGET := 100
const WET_INC_ON_CLICK  := 8   # เพิ่มเมื่อฉีดโดนแมวต่อหนึ่ง tick
const SOAP_INC_ON_CLICK := 10
const RINSE_DEC_ON_CLICK := 20

var wet_progress: int  = 0
var soap_progress: int = 0

func _ready() -> void:
	status_label.text = "Step 1: Wet the cat"
	_connect_buttons()
	_reset_particles()
	soap_area.monitoring = false
	cat.modulate = Color(1, 1, 1)
	print("🛁 SHOWER: Ready. State=WET")

# ---------- UI: tool buttons ----------
func _connect_buttons() -> void:
	shower_button.pressed.connect(_select_shower)
	soap_button.pressed.connect(_select_soap)
	towel_button.pressed.connect(_select_towel)

func _select_shower() -> void:
	current_tool = "shower"
	CursorManager.set_tool_cursor("res://Assets/Art/Minigames/IMG_9226.PNG")
	status_label.text = "Using Shower Head"
	print("🧰 TOOL → ShowerHead")

func _select_soap() -> void:
	current_tool = "soap"
	CursorManager.set_tool_cursor("res://Assets/Art/Minigames/IMG_9227.PNG")
	status_label.text = "Using Soap"
	print("🧰 TOOL → Soap")

func _select_towel() -> void:
	current_tool = "towel"
	CursorManager.set_tool_cursor("res://Assets/Art/Minigames/IMG_9225.PNG")
	status_label.text = "Using Towel"
	print("🧰 TOOL → Towel")

# ---------- Input (click + drag) ----------
func _input(event: InputEvent) -> void:
	# คลิกซ้าย
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_try_apply_current_tool(event.position)
	# ลากเมาส์พร้อมกดซ้ายค้าง
	elif event is InputEventMouseMotion and (event.button_mask & MOUSE_BUTTON_MASK_LEFT) != 0:
		_try_apply_current_tool(event.position)

func _try_apply_current_tool(pos: Vector2) -> void:
	# ต้องโดนตัวแมวก่อน
	if not cat.get_global_rect().has_point(pos):
		return
	match current_tool:
		"shower":
			_apply_shower(pos)
		"soap":
			_apply_soap(pos)
		"towel":
			_apply_towel()

# ---------- Game logic ----------
func _apply_shower(pos: Vector2) -> void:
	if current_state == State.WET:
		_show_water(pos)
		wet_progress = clampi(wet_progress + WET_INC_ON_CLICK, 0, WET_TARGET)
		print("💦 ฉีดน้ำโดนแมว +%d%% (รวม %d%% / %d)" % [WET_INC_ON_CLICK, wet_progress, WET_TARGET])
		if wet_progress >= WET_TARGET:
			current_state = State.SOAP
			status_label.text = "OK. Now use soap."
			print("🔁 STATE: WET → SOAP")

	elif current_state == State.RINSE:
		_show_water(pos)
		var before := soap_progress
		soap_progress = clampi(soap_progress - RINSE_DEC_ON_CLICK, 0, SOAP_TARGET)
		print("💦 ล้างฟอง -%d%% (เหลือ %d%%)" % [RINSE_DEC_ON_CLICK, soap_progress])
		if soap_progress <= 0 and before > 0:
			_clear_soap_visual()
			current_state = State.DRY
			status_label.text = "Good. Rinse complete! Dry the cat."
			print("🔁 STATE: RINSE → DRY")
	else:
		status_label.text = "Not now."

func _apply_soap(pos: Vector2) -> void:
	if current_state == State.SOAP:
		_show_soap(pos)
		soap_progress = clampi(soap_progress + SOAP_INC_ON_CLICK, 0, SOAP_TARGET)
		print("🧼 ถูสบู่ +%d%% (รวม %d%% / %d)" % [SOAP_INC_ON_CLICK, soap_progress, SOAP_TARGET])
		if soap_progress >= SOAP_TARGET:
			current_state = State.RINSE
			status_label.text = "Nice. Now rinse with water."
			print("🔁 STATE: SOAP → RINSE")
	else:
		status_label.text = "Wrong order."

func _apply_towel() -> void:
	if current_state == State.DRY:
		current_state = State.DONE
		status_label.text = "Done! The cat is clean."
		CursorManager.reset_cursor()
		print("🧽 เช็ดตัวเสร็จ จบงานอาบน้ำ ✔")
		_finish_shower()
	else:
		status_label.text = "Not yet."

# ---------- Particles & visuals ----------
func _reset_particles() -> void:
	water_particles.emitting = false
	soap_particles.emitting = false

func _show_water(pos: Vector2) -> void:
	water_particles.global_position = pos
	water_particles.emitting = true
	await get_tree().create_timer(0.15).timeout
	water_particles.emitting = false

func _show_soap(pos: Vector2) -> void:
	soap_particles.global_position = pos
	soap_particles.emitting = true
	# ถ้าจะใช้ตรวจด้วย Area2D จริงในอนาคต ให้เปิดบรรทัดล่างนี้
	# soap_area.monitoring = true
	cat.modulate = Color(0.95, 0.98, 1.0, 1.0) # โทนฟองบาง ๆ
	await get_tree().create_timer(0.15).timeout
	soap_particles.emitting = false

func _clear_soap_visual() -> void:
	soap_particles.emitting = false
	soap_area.monitoring = false
	cat.modulate = Color(1, 1, 1)

# ---------- Finish ----------
func _finish_shower() -> void:
	# Shower ไม่มี hearts/QTE → ให้ผลคงที่ (ปรับบาลานซ์ได้)
	Global.set_minigame_result("shower", 3, Global.hearts)
	Global.add_affinity(5)
	print("🏁 RESULT → +Affinity(5) → ResultScreen")
	get_tree().change_scene_to_file("res://Scenes/UI/ResultScreen.tscn")
