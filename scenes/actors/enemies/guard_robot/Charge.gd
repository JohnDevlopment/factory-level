extends State

export(float, 0.6, 2.0, 0.1) var delay : float

var _substate : int
var _destination : float

func _setup() -> void:
	user_data.frames.play('Move')
	user_data.hitbox.disabled = false
	(user_data.beep as AudioStreamPlayer2D).play()
	
	# Acclerate velocity
	var anima := Anima.begin(self)
	anima.then({
		node = persistant_state,
		property = 'velocity:x',
		to = user_data.charge_speed,
		easing = Anima.EASING.EASE_IN_CUBIC,
		duration = 0.5
	})
	anima.play()
	
	_substate = 0
	
	# Set destination
	var root : Enemy = persistant_state
	_destination = persistant_state.detection_radius
	_destination = root.global_position.x + _destination * root.direction.x

func physics_main(delta: float):
	var root := persistant_state as Enemy
	match _substate:
		0:
			if abs(root.global_position.x - _destination) < 11.0:
				_substate += 1
				(user_data.cintp as CubicInterpolator).start_interpolation(
					root.velocity.x,
					0,
					0.7
				)
		1:
			var cintp := user_data.cintp as CubicInterpolator
			var xvel = cintp.step(delta)
			assert(xvel is float)
			root.velocity.x = xvel
			if cintp.finished:
				return persistant_state.STATE_MOVEBACK

func cleanup() -> void:
	user_data.hitbox.disabled = true

func _go_to_next_state():
	emit_signal('state_change_request', persistant_state.STATE_MOVEBACK)
