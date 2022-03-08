extends 'res://addons/gut/test.gd'

var _bob_inst

func before_each():
	var Bob = double('res://scenes/actors/player/Bob.gd')
	_bob_inst = Bob.new()

func after_each():
	gut.p("Is 'Bob' valid: %s" % is_instance_valid(_bob_inst))

func test_fails():
	fail_test("Failed the test")

func test_passes():
	pass_test("Passed the test")
