extends Node
"""
Cursor Manager
- รองรับ dynamic cursor เมื่อ hover object
- รองรับ item-in-hand (เช่น Shower tools)
"""

var default_cursor = preload("res://Assets/Art/Cursor/cursor_default.png")
var hover_cursor = preload("res://Assets/Art/Cursor/cursor_hover.png")

var current_item: Texture2D = null  # ใช้ตอนถือของ เช่น ฝักบัว/สบู่
var current_tool_icon: Texture = null

func _ready():
	Input.set_custom_mouse_cursor(_get_scaled_texture(default_cursor))

# เปลี่ยนเคอร์เซอร์ตอน hover object
func set_hover(active: bool):
	if active:
		Input.set_custom_mouse_cursor(_get_scaled_texture(hover_cursor))
	else:
		if current_item:
			Input.set_custom_mouse_cursor(_get_scaled_texture(current_item))
		else:
			Input.set_custom_mouse_cursor(_get_scaled_texture(default_cursor))
			

func set_tool_cursor(icon_path: String):
	var tex = load(icon_path)
	if tex:
		hold_item(tex)
	else:
		print("CursorManager ERROR: Tool icon not found -> ", icon_path)

func reset_cursor():
	clear_item()
	Input.set_custom_mouse_cursor(_get_scaled_texture(default_cursor))

# ระบบ Item in Hand (เช่น Shower)
func hold_item(texture: Texture2D):
	current_item = texture
	Input.set_custom_mouse_cursor(texture)

func clear_item():
	current_item = null
	Input.set_custom_mouse_cursor(default_cursor)
	
func _get_scaled_texture(tex):
	if tex == null:
		return default_cursor

	var img = tex.get_image()
	if img.is_empty():
		return default_cursor

	var new_size = img.get_size() * 0.05
	img.resize(new_size.x, new_size.y, Image.INTERPOLATE_LANCZOS)
	return ImageTexture.create_from_image(img)
