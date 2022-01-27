tool
extends MeshInstance2D

export(int, 2, 16) var tile_height : int setget set_tile_height

func set_tile_height(h: int) -> void:
	tile_height = h
	mesh.size = Vector2(16, 16 * tile_height)
	mesh.center_offset.y = float(16 * tile_height) / 2
	update_children()

func update_children() -> void:
	for node in get_children():
		var _node := node as Node
		if _node.has_method('update'):
			_node.call('update')

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_READY:
			if Engine.editor_hint:
				set_notify_transform(true)
				return
			var shape := ConvexPolygonShape2D.new()
			shape.set_point_cloud([
				Vector2(),
				Vector2(16, 0),
				Vector2(16, 16 * tile_height),
				Vector2(0, 16 * tile_height)
			])
			$Area/CollisionShape2D.shape = shape
		NOTIFICATION_TRANSFORM_CHANGED:
			global_position = global_position.snapped(Vector2(16, 16))
