extends 'res://addons/gut/test.gd'

# LEGEND
# -------------
# STR = screen transition rectangle
# CRR = camera region rectangle
# -------------

# These tests are for making sure that the transition rect can be referenced
#  and used.
class TestScreenTransRect:
	extends 'res://addons/gut/test.gd'
	
	func test_room() -> void:
		# setup
		var room_double = double('res://test/resources/TestRoom.tscn').instance()
		stub(room_double, 'get_screen_transition_rect').to_call_super()
		add_child(room_double)
		
		assert_call_count(room_double, '_ready', 1)
		
		gut.p("-- transition rectangle --")
		
		var trect = room_double.get_screen_transition_rect()
		if not trect:
			fail_test("get_screen_transition_rect() returned null")
			return
		
		assert_typeof(trect.camera_rects, TYPE_ARRAY)
		
		assert_typeof(trect.connected_screens, TYPE_ARRAY)
	
	func test_connecting_camera_rects() -> void:
		var room = load('res://test/resources/TestRoom.tscn').instance()
		add_child_autofree(room)
		
		var tr = room.get_screen_transition_rect()
		
		assert_gt(tr.get_camera_rects().size(), 0, "no camera rects given")
		
		assert_gt(tr.get_connected_screens().size(), 0, "no screens connected")
		
		if is_passing():
			var screens : Array = tr.get_connected_screens()
			gut.p(screens)

# This class is for testing the screen transition function(s).
class TestScreenTransitions:
	extends 'res://addons/gut/test.gd'
	
	var TestRoom : PackedScene
	var screentrans_params := [21.0, -21.0, 423.0]
	
	func after_all() -> void:
		TestRoom = null
	
	func before_all() -> void:
		TestRoom = load('res://test/resources/TestRoom.tscn')
	
	func test_screen1_to_screen2(params = use_parameters(screentrans_params)):
		var room = add_child_autoqfree(TestRoom.instance())
		(room as Node2D).z_index = 1
		
		gut.p("Test screen transition with camera set at Y position %f" % params)
		
		# get camera node
		var camera = room.get_node_or_null(@'Camera2D')
		assert_not_null(camera, "'Camera2D' not found")
		
		camera.global_position.y = params
		
		# start screen transition
		room.start_screen_transition()
		#yield(yield_to(room.get_screen_transition_rect(), 'transition_finished', 5), YIELD)
		yield(yield_for(3), YIELD)
		
		gut.p("-- Transition Results --")
		
		gut.p("New camera position: %s" % camera.global_position)
		assert_almost_eq(camera.global_position.x, 300.0, 0.01, "camera not in right position")
		
		if is_passing():
			var cam := camera as Camera2D
			assert_eq(cam.limit_left, 300, "camera 'limit_left'")
			assert_eq(cam.limit_top, 0, "camera 'limit_top'")
			assert_eq(cam.limit_right, 600, "camera 'limit_right'")
			assert_eq(cam.limit_bottom, 300, "camera 'limit_bottom'")
