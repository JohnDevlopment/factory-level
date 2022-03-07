tool
extends Actor

enum { STATE_IDLE, STATE_RUN, STATE_CLIMB, STATE_HURT }

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
	
	for node in get_tree().get_nodes_in_group('pickable'):
		(node as Actor).connect('picked_up', self, '_on_pickable_object_status_changed', [true])
		(node as Actor).connect('dropped', self, '_on_pickable_object_status_changed', [false])
	
	states.user_data = {hurtbox = $Hurtbox}
	states.change_state(STATE_IDLE)
	
	stats.init_stats(self)

func _unhandled_key_input(event: InputEventKey) -> void:
	input_vector.x = Input.get_axis('ui_left', 'ui_right')
	
	if event.is_action_pressed('jump'):
		if _on_floor or _in_ladder:
			velocity.y = -speed_cap.y
			if states.current_state() == STATE_CLIMB or _object_picked:
				velocity.y /= 2
				states.change_state(STATE_IDLE)
	elif event.is_action_pressed('ui_up') and _in_ladder and not _object_picked:
		states.change_state(STATE_CLIMB)

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

func _on_ladder_body_change_enter_state(_node, flag: bool):
	_in_ladder = flag
	
	if not _in_ladder:
		if states.current_state() == STATE_CLIMB:
			states.change_state(STATE_IDLE)

func _on_pickable_object_status_changed(node, picked_up: bool) -> void:
	_object_picked = node if picked_up else null

func change_animation_state(state: String) -> void:
	if _object_picked: state += 'Carry'
	if _current_anim_state == state: return
	_current_anim_state = state
	animation_state.travel(state)
	animation_tree.set('parameters/%s/blend_position' % _current_anim_state, direction.x)

func current_state() -> String:
	match states.current_state():
		STATE_CLIMB:
			return 'climb'
		STATE_HURT:
			return 'hurt'
		STATE_IDLE:
			return 'idle'
		STATE_RUN:
			return 'run'
	
	return ""

func deserialize(data: Dictionary) -> void:
	global_position = data.global_position
	states.change_state(data.current_state)

func get_bottom_edge() -> Vector2:
	return global_position + Vector2(0, 16)

func hurt(area: Area2D, speed: Vector2 = Vector2(100, 200)) -> void:
	# Collided with enemy hitbox
	if states.current_state() == STATE_HURT: return
	
	# Let go of carried object
	if _object_picked:
		#(_object_picked as Object).call_deferred('set_indexed', 'velocity:x', 130 * -direction.x)
		_object_picked.drop()
	
	var other : Enemy = area.get_parent()
	var knockback_direction : Vector2 = global_position.direction_to(other.global_position) * -1
	velocity = Vector2(knockback_direction.x * speed.x, -speed.y)
	states.change_state(STATE_HURT)
	$HurtAnimation.play('HurtStart')
	
	var damage = stats.calculate_damage(other.stats)
	if damage:
		stats.health = int(max(0, stats.health - damage))

func serialize() -> Dictionary:
	return {
		current_state = states.current_state(),
		current_animation_state = _current_anim_state,
		current_hp = stats.health,
		global_position = global_position,
		name = name
	}

func set_camera_limits_from_rect(rect: Rect2):
	var camera : Camera2D = $Camera2D
	camera.limit_left = rect.position.x
	camera.limit_top = rect.position.y
	camera.limit_right = rect.end.x
	camera.limit_bottom = rect.end.y
	camera.align()

func update_velocity(delta: float) -> Vector2:
	if input_vector.x:
		velocity.x = move_toward(velocity.x, direction.x * speed_cap.x, 200 * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, 300 * delta)
	
	return velocity

func _on_HurtAnimation_animation_finished(anim_name: String) -> void:
	if anim_name == 'HurtStart':
		$HurtAnimation.play('Hurt')
