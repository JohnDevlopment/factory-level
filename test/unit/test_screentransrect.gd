extends 'res://addons/gut/test.gd'

#class TestInnerClass:
#	extends 'res://addons/gut/test.gd'
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
#		pass
#
#	func test_METHODNAME():
#		pass

var ScreenTransitionRect : PackedScene
var transition_rect

func after_all() -> void:
	ScreenTransitionRect = null

func after_each() -> void:
	pass

func before_all() -> void:
	ScreenTransitionRect = load('res://scenes/components/ScreenTransitionRect.tscn')

func before_each() -> void:
	transition_rect = autofree(ScreenTransitionRect.instance())

func test_properties() -> void:
	gut.p('-- class properties --')
	
	assert_property(ScreenTransitionRect, 'camera_rects', [], [])
	
	assert_property(ScreenTransitionRect, 'connected_screens', [], [])
	#assert_property(transition_rect, 'connected_screens', [], range(3))
	gut.p(str(transition_rect.connected_screens))
	
	gut.p('-- methods --')
	
	var dbl_rect = double(ScreenTransitionRect).instance()
	add_child(dbl_rect)
	
	assert_called(dbl_rect, '_ready')
	
	pause_before_teardown()
	
	gut.p("Done pausing")
	
