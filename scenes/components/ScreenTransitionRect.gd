extends Area2D

export var camera_rects : Array setget set_camera_rects,get_camera_rects
export var connected_screens := [] setget set_connected_screens,get_connected_screens

onready var collision_shape = $CollisionShape2D
onready var debug_shape_2d : DebugShape2D = $DebugShape2D

func _ready() -> void:
	if is_instance_valid(debug_shape_2d):
		_init_debug_shape()
		update_debug_shapes()

func get_camera_rects():
	return camera_rects

func get_connected_screens() -> Array:
	return connected_screens

func get_shape_rect() -> Rect2:
	var rect := Rect2()
	var shape = collision_shape.shape
	match shape.get_class():
		'RectangleShape2D':
			rect.position = collision_shape.global_position - (shape as RectangleShape2D).extents
			rect.size = (shape as RectangleShape2D).extents * 2
		var cl:
			push_error("%s currently not supported" % cl)
	return rect

func set_camera_rects(rects: Array) -> void:
	for each in rects:
		assert(each is Rect2)
	camera_rects = rects

func set_connected_screens(rects: Array) -> void:
	connected_screens = rects

func update_debug_shapes():
	if is_instance_valid(debug_shape_2d):
		call_deferred('_init_debug_shape')

#func _get_adjacent_camera_rects():
#	var area_rect := get_shape_rect()
#	connected_screens = []
#	for region in camera_rects:
#		if area_rect.intersects(region):
#			connected_screens.push_back(region)

# entry condition: debug_shape_2d != null
func _init_debug_shape() -> void:
	debug_shape_2d.global_position = Vector2.ZERO
	#for rect in camera_rects:
	#	var screen_size := Game.screen_size
	#	var red : float = range_lerp(rect.position.x, 0, screen_size.x, 0, 1)
	#	var green : float = range_lerp(rect.position.y, 0, screen_size.y, 0, 1)
	#	debug_shape_2d.add_rect(rect, Color(red, green, 0.24, 0.5), true)
	debug_shape_2d.add_rect(get_shape_rect(), Color(0, 0, 0, 0.5), true)
