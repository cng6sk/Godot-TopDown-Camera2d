@tool
extends EditorPlugin


func _enter_tree() -> void:
	var script = preload("top_down_camera_2d.gd")
	add_custom_type("TopDownCamera2D", "Camera2D", script, null)


func _exit_tree() -> void:
	remove_custom_type("TopDownCamera2D")
