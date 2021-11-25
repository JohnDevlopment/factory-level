tool
extends Actor

enum { STATE_NORMAL, STATE_CLIMB }

var direction := Vector2()
var states : StateMachine

var _in_ladder := false
var _on_floor := false

func _ready() -> void:
	if Engine.editor_hint:
		set_physics_process(false)
		set_process(false)
		return
	
	states = $States
	
	# Connect signals from the ladders
	for node in get_tree().get_nodes_in_group('ladders'):
		(node as Area2D).connect('body_entered', self, '_on_ladder_body_entered')
		(node as Area2D).connect('body_exited', self, '_on_ladder_body_exited')
	
	states.change_state(STATE_NORMAL)

func _unhandled_key_input(event: InputEventKey) -> void:
	direction.x = Input.get_axis('ui_left', 'ui_right')
	
	if event.is_action_pressed('jump'):
		if _on_floor or _in_ladder:
			velocity.y = -speed_cap.y
			if states.current_state() == STATE_CLIMB:
				velocity.y /= 2
				states.change_state(STATE_NORMAL)
	elif event.is_action_pressed('ui_up') and _in_ladder:
		states.change_state(STATE_CLIMB)

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
		states.change_state(STATE_NORMAL)
