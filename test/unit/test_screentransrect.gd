extends 'res://addons/gut/test.gd'

class TestScreenTransitionRectCore:
	extends 'res://addons/gut/test.gd'
	
	func test_room() -> void:
		# setup
		var room_double = double('res://test/resources/TestRoom.tscn').instance()
		stub(room_double, 'get_screen_transition_rect').to_call_super()
		add_child(room_double)
		
		gut.p("-- testing '_ready' --")
		assert_call_count(room_double, '_ready', 1)
		gut.p("-- testing transition rectangle --")
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

#class TestInnerClass:
#	extends 'res://addons/gut/test.gd'
#
#	const TEST_ROOM := preload('res://test/resources/TestRoom.tscn')
#
#	var _room_double
#	var _transition_rect
#
#	func after_all() -> void:
#		pass
#
#	func after_each() -> void:
#		pass
#
#	func before_all() -> void:
#		pass
#
#	func before_each() -> void:
#		_room_double = partial_double(TEST_ROOM)
#		_room_double = _room_double.instance()
#		add_child(_room_double)
#		_transition_rect = _room_double.get_screen_transition_rect()
#
#	func test_METHODNAME():
#		pass
