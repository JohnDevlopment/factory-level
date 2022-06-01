tool
class_name MyEditorGrid
extends Node2D

export var on := false setget set_on
export var start := Vector2() setget set_start
export var end := Vector2(10000, 10000) setget set_end
export var grid_size := Vector2(8, 8) setget set_grid_size
export var draw_color := Color(0.02, 0.02, 0.02, 0.75) setget set_draw_color
export var editor_only := true

func _draw() -> void:
	if on:
		if editor_only and not Engine.editor_hint: return
		
		var bounds := Rect2(start, Vector2.ONE)
		bounds.end = end
		
		for x in range(int(bounds.size.x / grid_size.x)):
			var xoffset := float(x) * grid_size.x
			
			draw_line(
				Vector2(xoffset + start.x, start.y),
				Vector2(xoffset + start.x, end.y),
				draw_color
			)
		
		for y in range(int(bounds.size.y / grid_size.y)):
			var yoffset := float(y) * grid_size.y
			
			draw_line(
				Vector2(0, yoffset + start.y),
				Vector2(end.x, yoffset + start.y),
				draw_color
			)

func set_on(flag: bool) -> void:
	on = flag
	update()

func set_start(s: Vector2) -> void:
	if not s.is_equal_approx(end):
		start = s
	update()

func set_draw_color(color: Color) -> void:
	draw_color = color
	update()

func set_end(e: Vector2) -> void:
	if not e.is_equal_approx(start):
		end = e
	update()

func set_grid_size(size: Vector2) -> void:
	grid_size = size
	update()
