extends 'res://addons/gut/test.gd'

func before_each() -> void:
	pass

func test_door_init():
	var door = partial_double('res://scenes/actors/doors/Door.tscn').instance()
	
	# Connect the area's signal and test said connection
	door.connect('body_entered', self, 'dummy')
	assert_connected(door, self, 'body_entered', 'dummy')
	
	# Add the child and test that two methods in _ready were called
	add_child(door)
	
	assert_called(door, '_check_signals')
	
	assert_called(door, '_disconnect_signals')
	
	# The signal should have been disconnected
	assert_not_connected(door, self, 'body_entered', 'dummy')

func test_door_ready():
	var door = load('res://scenes/actors/doors/Door.tscn').instance()
	
	# Check that the signals are connected
	add_child_autofree(door)
	
	assert_connected(door, door, 'body_entered')
	
	assert_connected(door, door, 'body_exited')
