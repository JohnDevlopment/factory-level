extends State

export(float, 0, 100) var ladder_climb_speed : float

func _setup() -> void:
	var root : Actor = persistant_state
	set_meta('gravity', root.gravity_value)
	root.gravity_value = 0
	root.velocity = Vector2()
	root.move_and_slide(Vector2.UP, Vector2.UP)

func cleanup() -> void:
	persistant_state.gravity_value = get_meta('gravity')

func physics_main(_delta):
	if (persistant_state.direction.y < 0.0 or persistant_state.direction.x != 0.0) or persistant_state.is_on_floor():
		return persistant_state.STATE_IDLE
	
	var vdir := Input.get_axis('ui_up', 'ui_down')
	persistant_state.velocity.y = ladder_climb_speed * vdir

func process_main(_delta):
	var anim_state := 'Idle'
	if persistant_state._object_picked:
		anim_state += 'Carry'
	
	persistant_state.change_animation_state(anim_state)
