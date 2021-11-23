extends RigidBody2D

signal picked_up(node)
signal dropped(node)

export(float, 1, 100000, 0.5) var throw_force : float = 1
export(float, 1, 100000, 0.5) var upward_force : float = 1
export(float, 1, 500, 0.1) var required_force : float = 1

var picked := false
var picker = null
var set_new_position := false
onready var hitbox = $Hitbox

var _internal_linear_velocity : Vector2
var _current_force : float

onready var stats = load('res://scenes/actors/EnergyBallStats.tres')

func _ready() -> void:
	set_physics_process(false)

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

func _physics_process(_delta: float) -> void:
	if picked:
		position = picker.global_position

func _integrate_forces(state: Physics2DDirectBodyState) -> void:
	if set_new_position:
		# Change position
		set_new_position = false
		var xform := state.transform
		xform.origin = get_meta('new_position')
		state.transform = xform
	else:
		_internal_linear_velocity = state.linear_velocity
		var force := _internal_linear_velocity.length()
		_current_force = force
		if is_zero_approx(force):
			_internal_linear_velocity = Vector2()
			sleeping = true
		else:
			hitbox.set_deferred('disabled', !(force >= required_force))
		
		

func set_rigid_position(pos: Vector2):
	set_new_position = true
	set_meta('new_position', pos)

# warning-ignore:unused_argument
func _on_hit_enemy_hurtbox(area: Area2D) -> void:
	if _internal_linear_velocity.length() >= required_force:
		var enemy : Enemy = area.get_parent()
		enemy.decide_damage(stats)
	
	var reflection := _internal_linear_velocity.reflect(Vector2.UP) * 10 * 2
	if reflection.y > 0.0:
		reflection.y = -reflection.y
	apply_central_impulse(reflection)
