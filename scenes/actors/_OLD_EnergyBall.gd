extends RigidBody2D

signal picked_up(node)
signal dropped(node)

export(float, 1, 100000, 0.5) var throw_force : float = 1
export(float, 1, 100000, 0.5) var upward_force : float = 1
export var required_force : Vector2

var picked := false
var picker = null
var set_new_position := false
onready var hitbox = $Hitbox
onready var sleep_timer = $SleepTimer
onready var sleep_threshold_velocity : float = ProjectSettings.get_setting('physics/2d/sleep_threshold_linear')

var _internal_linear_velocity : Vector2
var _disable_hitbox := false
var _internal_sleeping_state := false

onready var stats = load('res://scenes/actors/EnergyBallStats.tres')

func _ready() -> void:
	set_physics_process(false)
	$SleepTimer.wait_time = ProjectSettings.get_setting('physics/2d/time_before_sleep')

func _unhandled_key_input(event: InputEventKey) -> void:
	if event.is_action_pressed('action'):
		if picked:
			set_physics_process(false)
			
			mode = MODE_CHARACTER
			var force : float = throw_force * picker.direction.x
			apply_central_impulse(Vector2(force, -upward_force))
			
			picked = false
			picker = null
			get_tree().set_input_as_handled()
			emit_signal('dropped', self)
		else:
			var bodies : Array = $DetectionField.get_overlapping_bodies()
			for body in bodies:
				if body.name == 'Explorer':
					# Set the item as being picked up
					picked = true
					picker = body
					
					mode = MODE_STATIC
					set_physics_process(true)
					get_tree().set_input_as_handled()
					emit_signal('picked_up', self)

func _process(_delta: float) -> void:
	hitbox.disabled = _disable_hitbox

func _physics_process(_delta: float) -> void:
	if picked:
		position = picker.global_position - Vector2(0, 20)

func _integrate_forces(state: Physics2DDirectBodyState) -> void:
	if set_new_position:
		# Change position
		set_new_position = false
		var xform := state.transform
		xform.origin = get_meta('new_position')
		state.transform = xform
	else:
		_internal_linear_velocity = state.linear_velocity
		
		var force := abs(_internal_linear_velocity.x)
		
		if _internal_linear_velocity.x < sleep_threshold_velocity and _internal_linear_velocity.y < sleep_threshold_velocity:
			sleep_timer.start()
			_internal_linear_velocity = Vector2()
		
		_disable_hitbox = !(force >= required_force.x or _internal_linear_velocity.y >= required_force.y)

func set_rigid_position(pos: Vector2):
	set_new_position = true
	set_meta('new_position', pos)

func _on_hit_enemy_hurtbox(area: Area2D) -> void:
	var enemy : Enemy = area.get_parent()
	enemy.decide_damage(stats)
	
	var reflection := _internal_linear_velocity.reflect(Vector2.UP) * 10 * 2
	if reflection.y > 0.0:
		reflection.y = -reflection.y
	apply_central_impulse(reflection)

func _on_EnergyBall_sleeping_state_changed() -> void:
	_internal_sleeping_state = sleeping

func _on_SleepTimer_timeout() -> void:
	sleeping = true
	_disable_hitbox = true
