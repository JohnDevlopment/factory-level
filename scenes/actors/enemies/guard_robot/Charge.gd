extends State

func _setup() -> void:
	var root : Enemy = persistant_state
	var player : Actor = Game.get_player()
	
	var xdirection : float = root.global_position.direction_to(player.global_position).x
	root.direction.x = sign(xdirection)
	user_data.frames.play('Move')

func physics_main(delta: float):
	var root : Actor = persistant_state
	var velocity : Vector2 = root.velocity
	
	if root.distance_met >= root.detection_radius:
		velocity.x = lerp(velocity.x, 0, delta * 10)
		if is_zero_approx(velocity.x):
			return root.STATE_MOVEBACK
	else:
		velocity.x = lerp(velocity.x, user_data.charge_speed * root.direction.x, delta * 5)
	
	root.velocity = velocity
