extends StaticBody2D

const GROUP_NAME := 'invisible walls'

var _collision_shape
var _segment : SegmentShape2D

func _init(a: Vector2, b: Vector2) -> void:
	_collision_shape = CollisionShape2D.new()
	_segment = SegmentShape2D.new()
	_segment.a = a
	_segment.b = b
	_collision_shape.shape = _segment
	add_child(_collision_shape)

func _enter_tree() -> void:
	add_to_group(GROUP_NAME)
