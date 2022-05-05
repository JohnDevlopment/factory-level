extends State

export(float, 0.1, 10.0, 0.1) var wait_time : float

var _timer : float

func _setup() -> void:
	user_data.frames.play('Idle')
	_timer = wait_time

func physics_main(delta: float):
	_timer -= delta
	if _timer < 0.0:
		_timer = 0.0
		return persistant_state.STATE_IDLE
