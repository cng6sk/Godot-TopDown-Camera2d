@tool


extends Camera2D

@onready var camera : Camera2D = self


#region Exported
@export_group("Key Controls")

@export var pan_input : String = "drag"
@export var zoom_in_input : String = "zoomIn"
@export var zoom_out_input : String = "zoomOut"
@export var zoom_follow_cursor : bool = true
@export_range(1, 10, 0.01) var max_zoom_level : float = 5.0
@export_range(0.01, 1, 0.01) var min_zoom_level : float = 0.1
@export_range(0.01, 0.2, 0.01) var zoom_factor : float = 0.1

@export_group("Boundary")

@export var use_boundaries: bool = false
@export var boundary_X: float = 3000.0
@export var boundary_Y: float = 2000.0
@export var boundary_color: Color = Color(0.2, 0.4, 0.8, 0.1):
	set(new_val):
		boundary_color = new_val
		queue_redraw()
@export var boundary_border_color: Color = Color(0.2, 0.4, 0.8, 0.6)
@export var boundary_text_color: Color = Color(1, 1, 1, 0.8)
@export var boundary_text_size: int = 24

@export_group("Smoothness")

@export_range(0, 0.99, 0.01) var pan_smoothness : float = 0.5:
	set(new_val):
		if not Engine.is_editor_hint():
			pan_smoothness = pow(new_val, smooth_factor)
	get:
		return pan_smoothness

@export_range(0, 0.99, 0.01) var zoom_smoothness : float = 0.5:
	set(new_val):
		if not Engine.is_editor_hint():
			zoom_smoothness  = pow(new_val, smooth_factor)
	get:
		return zoom_smoothness 

const smooth_factor : float = 0.25

#endregion


#region Init
@onready var target_zoom := camera.zoom
@onready var target_position := camera.position

const base_fps : float = 120.0

var prev_mouse_pos : Vector2
var zoom_mouse_pos : Vector2

var _editor_draw: bool = Engine.is_editor_hint()

func _ready() -> void:
	if Engine.is_editor_hint():
		queue_redraw()
	if not Engine.is_editor_hint():
		pan_smoothness = pan_smoothness
		zoom_smoothness = zoom_smoothness
#endregion


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()
		return
	#print("_process")
	var pan_interpolation := pow(pan_smoothness, base_fps * delta)
	var zoom_interpolation := pow(zoom_smoothness, base_fps * delta)

	#var pre_mouseZoom_posLocal := to_local(get_canvas_transform().affine_inverse().basis_xform(zoom_mouse_pos))
	#var post_mouseZoom_posLocal := to_local(get_canvas_transform().affine_inverse().basis_xform(zoom_mouse_pos))
	
	var pre_mouseZoom_posGlobal := get_canvas_transform().affine_inverse().basis_xform(zoom_mouse_pos)
	camera.zoom = camera.zoom * zoom_interpolation + (1.0 - zoom_interpolation) * target_zoom
	var post_mouseZoom_posGlobal := get_canvas_transform().affine_inverse().basis_xform(zoom_mouse_pos)
	var zoom_offset := (pre_mouseZoom_posGlobal - post_mouseZoom_posGlobal) if zoom_follow_cursor else Vector2.ZERO

	target_position += zoom_offset
	
	if use_boundaries:
			var viewport_size := get_viewport_rect().size
			var effective_boundary_x := boundary_X - (viewport_size.x / (2 * camera.zoom.x))
			var effective_boundary_y := boundary_Y - (viewport_size.y / (2 * camera.zoom.y))
			
			effective_boundary_x = max(0, effective_boundary_x)
			effective_boundary_y = max(0, effective_boundary_y)
			
			target_position = target_position.clamp(
				Vector2(-effective_boundary_x, -effective_boundary_y), 
				Vector2(effective_boundary_x, effective_boundary_y)
			)
	camera.position = pan_interpolation * camera.position  + zoom_offset + target_position * (1.0 - pan_interpolation)



func _unhandled_input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return

	if not event is InputEventMouse and not event is InputEventAction:
		return

	var curr_mouse_pos := get_local_mouse_position()
	
	if Input.is_action_just_pressed(zoom_in_input):
		target_zoom *= 1.0 / (1.0 - zoom_factor)
		zoom_mouse_pos = get_viewport().get_mouse_position() - 0.5 * get_viewport_rect().size 

	if Input.is_action_just_pressed(zoom_out_input):
		target_zoom *= (1.0 - zoom_factor)
		zoom_mouse_pos = get_viewport().get_mouse_position() - 0.5 * get_viewport_rect().size

	if Input.is_action_pressed(pan_input):
		#print(target_position)
		target_position += (prev_mouse_pos - curr_mouse_pos)
		if use_boundaries:
			var viewport_size := get_viewport_rect().size
			var effective_boundary_x := boundary_X - (viewport_size.x / (2 * camera.zoom.x))
			var effective_boundary_y := boundary_Y - (viewport_size.y / (2 * camera.zoom.y))
			
			effective_boundary_x = max(0, effective_boundary_x)
			effective_boundary_y = max(0, effective_boundary_y)
			
			target_position = target_position.clamp(
				Vector2(-effective_boundary_x, -effective_boundary_y), 
				Vector2(effective_boundary_x, effective_boundary_y)
			)
		#print(target_position)

	target_zoom = target_zoom.clamp(Vector2.ONE * min_zoom_level, Vector2.ONE * max_zoom_level)
	prev_mouse_pos = curr_mouse_pos


func _draw() -> void:
	if not _editor_draw or not use_boundaries:
		return
	
	# 在编辑器中绘制边界矩形
	var rect := Rect2(
		Vector2(-boundary_X, -boundary_Y),
		Vector2(boundary_X * 2, boundary_Y * 2)
	)
	
	# 绘制半透明的填充矩形
	draw_rect(rect, boundary_color, true)
	
	# 绘制边界线
	draw_rect(rect, boundary_border_color, false, 2.0)
	
	# 添加标签显示边界大小
	var label := "Boundary: %d x %d" % [int(boundary_X * 2), int(boundary_Y * 2)]
	
	# 使用 Godot 4.x 获取默认字体的方法
	var font := ThemeDB.fallback_font
	
	draw_string(
		font,
		Vector2(-boundary_X + 10, -boundary_Y + 20),
		label,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		boundary_text_size,
		boundary_text_color
	)
