extends 'res://addons/gut/test.gd'

func after_all() -> void:
	pass

func after_each() -> void:
	pass

func before_all() -> void:
	pass

func before_each() -> void:
	pass

func test_custom_classes():
	for CLASS in ['Actor', 'Enemy', 'State', 'StateMachine']:
		assert_true(ClassDB.class_exists(CLASS), "no '%s' class defined" % CLASS)

func test_Game():
	assert_has_signal(Game, 'changed_game_param')
	assert_eq(Game.level_entrance, -1)
