extends Area2D

var _connected_screens := []

onready var collision_shape = $CollisionShape2D

func connect_to_actor(actor: Node, function: String) -> void:
	connect('body_entered', actor, function, [self])

func get_connected_screens(point: Vector2) -> Array:
	var i := 0
	var result := []
	
	for rect in _connected_screens:
		if (rect as Rect2).has_point(point):
			result.push_back(rect)
			break
		i += 1
	
	assert(i < 2, "index is not within the range [0, 2]")
	result.push_back(_connected_screens[i ^ 1])
	return result

func get_shape_rect() -> Rect2: return _rect_from_shape(collision_shape)

func set_camera_regions(list: Array) -> void:
	_connected_screens = []
	
	var our_rect := get_shape_rect()
	var i := 0
	for rect in list:
		assert(rect is Rect2, "list[%d] is not Rect2" % i)
		if rect.intersects(our_rect):
			_connected_screens.push_back(rect)
		i += 1
	
	assert(_connected_screens.size() == 2)
	_connected_screens.sort_custom(self, '_sort_rects')

func _rect_from_shape(collshape: CollisionShape2D) -> Rect2:
	var rect := Rect2()
	
	var shape : Shape2D = collshape.shape
	
	if not is_instance_valid(shape):
		push_error("Missing collision shape")
		return Rect2()
	
	match shape.get_class():
		'RectangleShape2D':
			rect.position = collshape.global_position - (shape as RectangleShape2D).extents
			rect.size = (shape as RectangleShape2D).extents * 2
		'CapsuleShape2D':
			var capsule_shape := shape as CapsuleShape2D
			rect.position.x = position.x - capsule_shape.radius
			rect.position.y = position.y - capsule_shape.height
			rect.size = Vector2(capsule_shape.radius * 2, capsule_shape.height * 2)
		var cl:
			push_error("%s currently not supported" % cl)
	return rect

func _sort_rects(a: Rect2, b: Rect2) -> bool:
	return a.position < b.position
