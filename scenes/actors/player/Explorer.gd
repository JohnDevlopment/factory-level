tool
extends Actor

enum { STATE_IDLE, STATE_RUN, STATE_CLIMB, STATE_HURT }

var direction := Vector2()
onready var states : StateMachine = $States
var stats : Stats = preload('res://scenes/actors/player/PlayerStats.tres')
onready var animation_tree : AnimationTree = $AnimationTree
onready var animation_state = $AnimationTree.get('parameters/playback')

var _in_ladder := false
var _on_floor := false
var _object_picked
var _current_anim_state := 'Idle'

func _ready() -> void:
	if Engine.editor_hint:
		set_physics_process(false)
		set_process(false)
		return
	
	# Connect signals from the ladders
	for node in get_tree().get_nodes_in_group('ladders'):
		(node as Area2D).connect('body_entered', self, '_on_ladder_body_entered')
		(node as Area2D).connect('body_exited', self, '_on_ladder_body_exited')
	
	for node in get_tree().get_nodes_in_group('pickable'):
		(node as Actor).connect('picked_up', self, '_on_pickable_object_status_changed', [true])
		(node as Actor).connect('dropped', self, '_on_pickable_object_status_changed', [false])
	
	states.user_data = {
		hurtbox = $Hurtbox
	}
	
	states.change_state(STATE_IDLE)

func _unhandled_key_input(event: InputEventKey) -> void:
	direction.x = Input.get_axis('ui_left', 'ui_right')
	
	if event.is_action_pressed('jump'):
		if _on_floor or _in_ladder:
			velocity.y = -speed_cap.y
			if states.current_state() == STATE_CLIMB or _object_picked:
				velocity.y /= 2
				states.change_state(STATE_IDLE)
	elif event.is_action_pressed('ui_up') and _in_ladder and not _object_picked:
		states.change_state(STATE_CLIMB)
#	elif event.is_action_pressed('debug') and is_on_floor():
#		velocity.x = -200
#		states.change_state(STATE_HURT)

func _process(delta: float) -> void:
	if direction.x:
		animation_tree.set('parameters/%s/blend_position' % _current_anim_state, direction.x)
	
	var state_return = states.state_process(delta)
	if state_return is int:
		states.change_state(state_return)

func _physics_process(delta: float) -> void:
	var state_return = states.state_physics(delta)
	if state_return is int:
		state_return = states.change_state(state_return)
		assert(state_return == OK)
	
	var snap_vector := Vector2.UP * 10 if velocity.y > 0 else Vector2()
	velocity = move_and_slide_with_snap(velocity, snap_vector, Vector2.UP, true, 4, 0.785398, true)
	
	_on_floor = is_on_floor()

func _on_ladder_body_entered(_node):
	_in_ladder = true

func _on_ladder_body_exited(_node):
	_in_ladder = false
	if states.current_state() == STATE_CLIMB:
		states.change_state(STATE_IDLE)

func _on_pickable_object_status_changed(node, picked_up: bool) -> void:
	_object_picked = node if picked_up else null

func calculate_normal_movement(delta: float) -> Vector2:
	var goal_velocity : float = direction.x * speed_cap.x
	var motion_delta := delta * (200 if direction.x else 300)
	velocity.x = move_toward(velocity.x, goal_velocity, motion_delta)
	
	return velocity

func change_animation_state(state: String) -> void:
	if _current_anim_state == state: return
	_current_anim_state = state
	animation_state.travel(state)

func hurt(area: Area2D) -> void:
	# Collided with enemy hitbox
	if states.current_state() == STATE_HURT: return
	var other : Enemy = area.get_parent()
	var knockback_direction : Vector2 = global_position.direction_to(other.global_position) * -1
	velocity = Vector2(knockback_direction.x * 200, 100)
	states.change_state(STATE_HURT)
