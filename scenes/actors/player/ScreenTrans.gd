extends State

const OFFSET := Vector2(50, 0)

var _finished := false

func _setup() -> void:
	persistant_state.velocity = Vector2()
	persistant_state.change_animation_state('Run')
	
	var camera : Camera2D = user_data.camera
	
	var dest : Vector2
	var rect_dest : Rect2 = user_data.rect_dest
	
	var left : bool = persistant_state.global_position.x < rect_dest.position.x
	
	# Player destination
	if left:
		dest = rect_dest.position + OFFSET
	else:
		dest = rect_dest.end - OFFSET
	dest.y = persistant_state.global_position.y
	
	var anima := Anima.begin(persistant_state)
	
	# Animate player
	anima.then({
		node = persistant_state,
		property = 'x',
		to = dest.x,
		duration = 1
	})
	
	camera.limit_left = rect_dest.position.x
	camera.limit_right = rect_dest.end.x
	camera.limit_top = rect_dest.position.y
	camera.limit_bottom = rect_dest.end.y
	
	# Play animation and wait to finish
	anima.play()
	
	_finished = false
	yield(anima, 'animation_completed')
	_finished = true

func process_main(_delta: float):
	if _finished:
		return persistant_state.STATE_IDLE
