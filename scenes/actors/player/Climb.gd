extends State

export(float, 0, 100) var ladder_climb_speed : float

func _setup() -> void:
	var root : Actor = persistant_state
	set_meta('gravity', root.gravity_value)
	root.gravity_value = 0
	root.velocity = Vector2()
	root.move_and_slide(Vector2.UP, Vector2.UP)
	#root.enable_collision(false)

func cleanup() -> void:
	persistant_state.gravity_value = get_meta('gravity')
	#persistant_state.enable_collision(true)

func physics_main(_delta):
	if persistant_state.velocity.x:
		persistant_state.velocity.x = 0
	
	if persistant_state.input_vector.x != 0.0 or persistant_state.is_on_floor():
		return persistant_state.STATE_IDLE
	
	var vdir := Input.get_axis('ui_up', 'ui_down')
	persistant_state.velocity.y = ladder_climb_speed * vdir

func process_main(_delta):
	persistant_state.change_animation_state('Idle')
