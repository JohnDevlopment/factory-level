extends 'res://addons/gut/test.gd'

var physics_fps : float
var physics_delta : float

func before_all():
	physics_fps = ProjectSettings.get_setting('physics/common/physics_fps')
	gut.p("Physics FPS: %f" % physics_fps)
	physics_delta = 1.0 / physics_fps
	gut.p("Physics delta: %f" % physics_delta)

func test_double():
	var ActorDouble = double(Actor)
	assert_not_null(ActorDouble)
	if ActorDouble:
		gut.p("ActorDouble is a '%s' class" % (ActorDouble as Object).get_class())

func test_properties():
	var dummy : Actor = add_child_autoqfree(Actor.new())
	assert_ne(dummy.gravity_value, 0.0, "'gravity_value' should not initially be 0")
	assert_almost_eq(dummy.GRAVITY_STEP, 13.4, 0.01, "'GRAVITY_STEP' should be 13.4")
	if not is_zero_approx(dummy.speed_cap.x) or not is_zero_approx(dummy.speed_cap.y):
		fail_test("Velocity is not zero like it should be")
	assert_almost_eq(dummy.snap_length, 1.0, 0.1, "'snap_level' initially should be 1")

func test_method_calls():
	gut.p("-- doubling actor --")
	var actor = double(Actor).new()
	assert_not_null(actor)
