extends Control
# Phase 1: drag 4 organs into belly
# Phase 2: stitch 3 points via QTE → result

enum Phase { ORGANS, STITCH }
var phase: int = Phase.ORGANS

@onready var belly: Control = $Belly
@onready var organs := [
	$Organs/Organ1, $Organs/Organ2, $Organs/Organ3, $Organs/Organ4
]
@onready var qte: Node = $QTECircle
@onready var stitches := [
	$WoundArea/Stitch1, $WoundArea/Stitch2, $WoundArea/Stitch3
]

var placed := 0
var dragging: Control = null
var drag_offset := Vector2.ZERO

var stitch_idx := 0
var stitch_scores := []  # values: 2 (perfect), 1 (safe), 0 (danger)

func _ready() -> void:
	Global.reset_hearts()
	qte.hide()
	for o in organs:
		o.gui_input.connect(func(e): _on_drag_input(e, o))

# ---------- PHASE 1: DRAG ----------
func _on_drag_input(e: InputEvent, organ: Control) -> void:
	if phase != Phase.ORGANS:
		return
	if e is InputEventMouseButton and e.pressed:
		dragging = organ
		drag_offset = organ.global_position - e.position
	elif e is InputEventMouseButton and not e.pressed and dragging == organ:
		if belly.get_global_rect().has_point(organ.global_position):
			organ.mouse_filter = Control.MOUSE_FILTER_IGNORE
			organ.modulate = Color(0.8, 1.0, 0.8) # placed hint
			placed += 1
			if placed >= organs.size():
				_start_stitch_phase()
		dragging = null
	elif e is InputEventMouseMotion and dragging == organ:
		organ.global_position = e.position + drag_offset

# ---------- PHASE 2: STITCH ----------
func _start_stitch_phase() -> void:
	phase = Phase.STITCH
	stitch_idx = 0
	stitch_scores.clear()
	qte.show()
	_connect_qte()
	_next_stitch()

func _connect_qte() -> void:
	if qte.is_connected("qte_completed", Callable(self, "_on_qte_completed")):
		return
	if qte.has_signal("qte_completed"):
		qte.connect("qte_completed", _on_qte_completed)
	elif qte.has_signal("qte_finished"):
		qte.connect("qte_finished", _on_qte_finished_proxy)

func _next_stitch() -> void:
	if stitch_idx >= stitches.size():
		_finish_fix()
		return

	var target: Control = stitches[stitch_idx]  # ← แก้จาก := เป็น = และกำหนดชนิดให้ชัด
	if qte.has_method("reset_difficulty"):
		qte.reset_difficulty()
	if Global.cat_state == "demon" and qte.has_method("increase_difficulty"):
		qte.increase_difficulty()
	if qte.has_method("set_activity"):
		qte.set_activity("fix")

	# วางตำแหน่ง QTE ให้ตรงจุดเย็บ
	qte.global_position = target.global_position
	qte.show()
	if qte.has_method("start_qte"):
		qte.start_qte()


func _on_qte_finished_proxy(result: String) -> void:
	var s := 3 if result == "perfect" else (1 if result == "safe" else 0)
	_accumulate_and_continue(s)

func _on_qte_completed(result: String, score: int) -> void:
	_accumulate_and_continue(score)

func _accumulate_and_continue(score: int) -> void:
	var band := 3 if score >= 3 else (1 if score >= 1 else 0)
	var points := 2 if band == 3 else (1 if band == 1 else 0)
	stitch_scores.append(points)

	# color feedback per stitch
	match band:
		3: stitches[stitch_idx].modulate = Color(0.6, 1, 0.6)
		1: stitches[stitch_idx].modulate = Color(1, 0.95, 0.6)
		0: stitches[stitch_idx].modulate = Color(1, 0.6, 0.6)

	stitch_idx += 1
	_next_stitch()

# ---------- FINISH ----------
func _finish_fix() -> void:
	var total := 0
	for v in stitch_scores:
		total += v  # 0..6

	var band := 3 if total >= 5 else (1 if total >= 2 else 0)
	if band == 0:
		Global.add_injury(1)  # FAIL-A: punish on worst outcome

	Global.set_minigame_result("fix", band, Global.hearts)
	Global.apply_minigame_score("fix", band)
	get_tree().change_scene_to_file("res://Scenes/UI/ResultScreen.tscn")
