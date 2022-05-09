extends State

const OFFSET := Vector2(50, 0)

var _finished := false

func _setup() -> void:
	var camera : Camera2D = user_data.camera
	var rect_dest : Rect2 = user_data.rect_dest
	
	camera.limit_left = rect_dest.position.x
	camera.limit_right = rect_dest.end.x
	camera.limit_top = rect_dest.position.y
	camera.limit_bottom = rect_dest.end.y
	
	persistant_state.velocity.x = 0
	
	if not user_data.vertical:
		var left : bool = persistant_state.global_position.x < rect_dest.position.x
		var _offset := OFFSET * (1.0 if left else -1.0)
		persistant_state.change_animation_state('Run')
		_horizontal_screen_transition(
			(rect_dest.position + _offset) if left else (rect_dest.end + _offset)
		)
	else:
		var _y_offset := -OFFSET.x
		_finished = true
		if persistant_state.global_position.y >= rect_dest.position.y:
			# Below the trigger
			var anima := Anima.begin(persistant_state)
			anima.then({
				node = persistant_state,
				property = 'y',
				to = _y_offset,
				relative = true,
				duration = 0.2
			})
			anima.play()
			_finished = false
			yield(anima, 'animation_completed')
			_finished = true

func cleanup() -> void:
	var dest_rect : Rect2 = user_data.rect_dest
	user_data['rect_dest'] = null
	user_data['rect_src'] = null
	user_data['vertical'] = null
	emit_signal('state_signal', 'transition_finished', [dest_rect])

func process_main(_delta: float):
	if _finished:
		return persistant_state.STATE_IDLE

func _horizontal_screen_transition(dest: Vector2):
	var anima := Anima.begin(persistant_state)
	
	# Animate player
	anima.then({
		node = persistant_state,
		property = 'x',
		to = dest.x,
		duration = 1
	})
	
	# Play animation and wait to finish
	anima.play()
	
	_finished = false
	emit_signal('state_signal', 'transition_started', [])
	yield(anima, 'animation_completed')
	_finished = true
