tool
extends Actor

signal transition_finished(rect)
signal transition_started()
signal player_dead()

enum { STATE_IDLE, STATE_RUN, STATE_CLIMB, STATE_HURT, STATE_SCREENTRANS }

var input_vector := Vector2()
var direction := Vector2()
var stats : Stats = preload('res://scenes/actors/player/PlayerStats.tres')
onready var states : StateMachine = $States
onready var animation_tree : AnimationTree = $AnimationTree
onready var animation_state = $AnimationTree.get('parameters/playback')

var _in_ladder := false
var _on_floor := false
var _object_picked
var _current_anim_state := 'Idle'
var _moving := false

func _ready() -> void:
	if Engine.editor_hint:
		set_physics_process(false)
		set_process(false)
		return
	
	# Connect signals from the ladders
	for node in get_tree().get_nodes_in_group('ladders'):
		(node as Area2D).connect('body_entered', self, '_on_ladder_body_change_enter_state', [true])
		(node as Area2D).connect('body_exited', self, '_on_ladder_body_change_enter_state', [false])
	
	# Connect signals from pickable objects
	for node in get_tree().get_nodes_in_group('pickable'):
		(node as Actor).connect('picked_up', self, '_on_pickable_object_status_changed', [true])
		(node as Actor).connect('dropped', self, '_on_pickable_object_status_changed', [false])
	
	# Connect screen transition rects to the player
	for node in get_tree().get_nodes_in_group('screen_transitions'):
		node.connect_to_actor(self, '_on_screenarea_body_entered')
	
	states.user_data = {hurtbox = $Hurtbox, camera = $Camera2D}
	states.change_state(STATE_IDLE)
	
	stats.init_stats(self)

func _unhandled_key_input(event: InputEventKey) -> void:
	input_vector.x = Input.get_axis('ui_left', 'ui_right')
	
	if event.is_action_pressed('jump'):
		if _on_floor or _in_ladder:
			velocity.y = -speed_cap.y
			if states.current_state() == STATE_CLIMB or _object_picked:
				#velocity.y /= 2
				states.change_state(STATE_IDLE)
		get_tree().set_input_as_handled()
	elif event.is_action_released('jump'):
		if (not _on_floor or _in_ladder) and velocity.y < -100.0:
			velocity.y = -100.0
		get_tree().set_input_as_handled()
	elif event.is_action_pressed('ui_up') and _in_ladder and not _object_picked:
		states.change_state(STATE_CLIMB)
		get_tree().set_input_as_handled()

func _process(delta: float) -> void:
	if input_vector.x:
		direction.x = input_vector.x
	
	animation_tree.set('parameters/%s/blend_position' % _current_anim_state, direction.x)
	
	var state_return = states.state_process(delta)
	if state_return is int:
		states.change_state(state_return)

func _physics_process(delta: float) -> void:
	var state_return = states.state_physics(delta)
	if state_return is int:
		state_return = states.change_state(state_return)
		assert(state_return == OK)
	
	var snap_vector := Vector2(0, 4) if velocity.y > 0 else Vector2()
	var _velocity := move_and_slide_with_snap(velocity, snap_vector, Vector2.UP, true, 4, 0.785398, false)
	velocity.y = _velocity.y
	
	_on_floor = is_on_floor()

func _to_string() -> String:
	return "Bob[Actor:%d]" % get_instance_id()

func change_animation_state(state: String) -> void:
	if _object_picked: state += 'Carry'
	if _current_anim_state == state: return
	_current_anim_state = state
	animation_state.travel(state)
	animation_tree.set('parameters/%s/blend_position' % _current_anim_state, direction.x)

func current_state() -> String:
	var _state : String
	
	match states.current_state():
		STATE_CLIMB:
			_state = 'climb'
		STATE_HURT:
			_state = 'hurt'
		STATE_IDLE:
			_state = 'idle'
		STATE_RUN:
			_state = 'run'
		STATE_SCREENTRANS:
			_state = 'screentrans'
	
	assert(not _state.empty(), "the current state is not one of the recognized states")
	return _state

func deserialize(data: Dictionary) -> void:
	stats.health = data.current_hp

func get_bottom_edge() -> Vector2:
	return global_position + Vector2(0, 16)

func get_center() -> Vector2:
	return global_position + Vector2(0, 2.5)

func hurt(area: Area2D, speed: Vector2 = Vector2(100, 200)) -> void:
	# Collided with enemy hitbox
	if states.current_state() == STATE_HURT: return
	
	# Let go of carried object
	if _object_picked:
		_object_picked.drop()
	
	var other : Node2D = area.get_parent()
	assert(other.get('stats') != null, "no 'stats' property")
	var knockback_direction : Vector2 = global_position.direction_to(other.global_position) * -1
	velocity = Vector2(knockback_direction.x * speed.x, -speed.y)
	states.change_state(STATE_HURT)
	$HurtAnimation.play('HurtStart')
	
	var damage = stats.calculate_damage(other.stats)
	if damage:
		stats.health = int(max(0, stats.health - damage))
		if not stats.health:
			enable_collision(false)
			call_deferred('_make_still_camera')
			$DeathTimer.start()

func serialize() -> Dictionary:
	return {
		current_state = states.current_state(),
		current_animation_state = _current_anim_state,
		current_hp = stats.health,
		name = name
	}

func set_camera_limits_from_rect(rect: Rect2):
	var camera : Camera2D = $Camera2D
	camera.limit_left = rect.position.x
	camera.limit_top = rect.position.y
	camera.limit_right = rect.end.x
	camera.limit_bottom = rect.end.y
	camera.align()
	camera.reset_smoothing()

func update_velocity(delta: float) -> Vector2:
	if input_vector.x:
		velocity.x = move_toward(velocity.x, direction.x * speed_cap.x, 200 * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, 300 * delta)
	
	return velocity

# internal functions

func _make_still_camera() -> void:
	$Camera2D.clear_current()

#signals

func _on_HurtAnimation_animation_finished(anim_name: String) -> void:
	if anim_name == 'HurtStart':
		$HurtAnimation.play('Hurt')

func _on_ladder_body_change_enter_state(_node, flag: bool):
	_in_ladder = flag
	
	if not _in_ladder:
		if states.current_state() == STATE_CLIMB:
			states.change_state(STATE_IDLE)

func _on_pickable_object_status_changed(node, picked_up: bool) -> void:
	_object_picked = node if picked_up else null

func _on_screenarea_body_entered(_body, area, vertical: bool) -> void:
	assert(_body == self)
	
	var regions : Array = area.get_connected_screens(global_position)
	assert(regions.size() == 2)
	
	states.user_data['rect_src'] = regions[0]
	states.user_data['rect_dest'] = regions[1]
	states.user_data['vertical'] = vertical
	states.change_state(STATE_SCREENTRANS)

func _on_States_state_signal(spec: String, args: Array) -> void:
	match spec:
		'transition_finished':
			var rect: Rect2 = args.pop_front()
			emit_signal('transition_finished', rect)
		'transition_started':
			emit_signal('transition_started')

func _on_DeathTimer_timeout() -> void:
	emit_signal('player_dead')
	queue_free()
