extends Area2D

signal transition_finished

export var camera_rects : Array setget set_camera_rects,get_camera_rects
export var connected_screens := [] setget set_connected_screens,get_connected_screens

onready var collision_shape : CollisionShape2D = $CollisionShape2D
onready var debug_shape_2d : DebugShape2D = $DebugShape2D

func _ready() -> void:
	var both_valid : bool = is_instance_valid(collision_shape) and \
		is_instance_valid(debug_shape_2d)
	if both_valid:
		_init_debug_shape()

func get_camera_rects():
	return camera_rects

func get_connected_screens() -> Array:
	return connected_screens

func get_shape_rect() -> Rect2:
	var rect := Rect2()
	var shape = collision_shape.shape
	
	if not shape:
		push_error("Missing collision shape")
		return rect
	
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
	_find_overlapping_regions()

func set_connected_screens(rects: Array) -> void:
	connected_screens = rects
	connected_screens.sort_custom(self, '_sort_rects')

func transition_screen(camera: Camera2D, point: Vector2):
	var screen := -1
	# find out which screen point is in
	for i in connected_screens.size():
		var region : Rect2 = connected_screens[i]
		if (region as Rect2).has_point(point):
			screen = i
	if screen >= 0:
		screen ^= 1
	
	if screen >= 0 and screen < 3:
		var to_region : Rect2 = connected_screens[screen]
		var anima := Anima.begin(self, 'ScreenTransition')
		
		# disable limits temporarily
		camera.limit_top = -1000000
		camera.limit_left = -1000000
		camera.limit_bottom = 1000000
		camera.limit_right = 1000000
		
		# camera position
		anima.then({
			node = camera,
			property = 'x',
			to = to_region.position.x,
			duration = 1.0,
			delay = 1.0
		})
		if true:
			var diff : float
			var bottom_edge : float = camera.global_position.y + \
				int((Game.screen_size * camera.zoom).y)
			if camera.global_position.y < to_region.position.y:
				diff = to_region.position.y - camera.global_position.y
			elif bottom_edge > to_region.end.y:
				diff = to_region.end.y - bottom_edge
			if not is_zero_approx(diff):
				anima.with({
					node = camera,
					property = 'y',
					to = diff,
					duration = 1.0,
					relative = true
				})
		anima.play()
		yield(anima, 'animation_completed')
		
		# snap camera to position
		camera.limit_top = to_region.position.y
		camera.limit_left = to_region.position.x
		camera.limit_bottom = to_region.end.y
		camera.limit_right = to_region.end.x
		
		_finished()

func update_debug_shapes():
	if is_instance_valid(debug_shape_2d):
		call_deferred('_init_debug_shape')

# entry condition: debug_shape_2d != null
func _init_debug_shape() -> void:
	debug_shape_2d.global_position = Vector2.ZERO
	#for rect in camera_rects:
	#	var screen_size := Game.screen_size
	#	var red : float = range_lerp(rect.position.x, 0, screen_size.x, 0, 1)
	#	var green : float = range_lerp(rect.position.y, 0, screen_size.y, 0, 1)
	#	debug_shape_2d.add_rect(rect, Color(red, green, 0.24, 0.5), true)
	debug_shape_2d.add_rect(get_shape_rect(), Color(0, 0, 0, 0.5), true)

func _sort_rects(a: Rect2, b: Rect2) -> bool:
	if a.position < b.position:
		return true
	return false

func _finished() -> void:
	emit_signal('transition_finished')

func _find_overlapping_regions() -> void:
	var area_rect : Rect2 = get_shape_rect()
	var connected := []
	for cr in camera_rects:
		if area_rect.intersects(cr):
			connected.push_back(cr)
	set_connected_screens(connected)
