tool
extends StaticBody2D

var _player : Actor

func set_collision_box(width: float, tile_size: Vector2) -> void:
	var shape := RectangleShape2D.new()
	shape.extents = Vector2(width * tile_size.x, 4) / 2
	$CollisionShape2D.shape = shape
	$CollisionShape2D.position = shape.extents * Vector2(-1, 1)
	
	# Area collision
	var area_collision := CollisionShape2D.new()
	area_collision.one_way_collision = true
	shape = shape.duplicate()
	shape.extents.y += 2.0
	area_collision.shape = shape
	$DetectionArea.add_child(area_collision)
	area_collision.position = shape.extents * Vector2(-1, 1) - Vector2(0, shape.extents.y)

func _on_DetectionArea_body(body: Node, entered: bool) -> void:
	set_process_unhandled_key_input(entered)
	_player = body

func _unhandled_key_input(event: InputEventKey) -> void:
	if event.is_action_pressed('ui_down'):
		_player.position.y += 1.1
