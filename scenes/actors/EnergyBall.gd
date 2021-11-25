tool
extends Actor

signal picked_up
signal dropped

export var neccessary_velocity := Vector2()
export(float, 1, 500, 0.1) var throw_force : float = 1
export var reflect_speed : Vector2

onready var hitbox = $Hitbox

var picked_up := false
var player : Actor
var direction : Vector2
onready var stats = load('res://scenes/actors/EnergyBallStats.tres')
var _detected := false

func _ready() -> void:
	if Engine.editor_hint:
		set_process(false)
		set_physics_process(false)
		return
	
	player = Game.get_player()
	set_meta('gravity', gravity_value)

func _process(_delta: float) -> void:
	var fast_enough : bool = abs(velocity.x) >= neccessary_velocity.x or velocity.y >= neccessary_velocity.y
	hitbox.disabled = !fast_enough

# warning-ignore:unused_argument
func _physics_process(delta: float) -> void:
	if picked_up:
		direction = player.direction
		global_position = player.global_position - Vector2(0, 20)
		return
	
	velocity = move_and_slide(velocity, Vector2.UP, false, 4, 0.785398, false)
	for i in get_slide_count():
		var slide := get_slide_collision(i)
		var collider = slide.collider
		if collider is Actor:
			if collider.get_collision_layer_bit(Globals.CollisionLayers.ENEMIES):
				_check_collision_with_enemy(slide)
				(collider as Enemy).decide_damage(stats)
	
	if velocity.x:
		var weight : float = 0.08 if is_on_floor() else 0.02
		velocity.x = lerp(velocity.x, 0.0, weight)
		if Math.is_almost_zero(velocity.x, 0.07):
			velocity.x = 0
			print('zero velocity')

func _unhandled_key_input(event: InputEventKey) -> void:
	if event.is_action_pressed('action'):
		get_tree().set_input_as_handled()
		if picked_up:
			_set_picked(false)
		else:
			if _detected: _set_picked(true)

func _set_picked(picked: bool) -> void:
	if picked:
		# Object is picked up
		picked_up = true
		gravity_value = 0
		emit_signal('picked_up')
	else:
		# Object is dropped
		picked_up = false
		gravity_value = get_meta('gravity')
		velocity = Vector2(throw_force * direction.x, -200)
		emit_signal('dropped')
		
	enable_collision(!picked_up)

func _check_collision_with_enemy(collision: KinematicCollision2D):
	velocity = reflect_speed * collision.normal

func _on_DetectionField_body_entered(_body: Node) -> void:
	_detected = true

func _on_DetectionField_body_exited(_body: Node) -> void:
	_detected = false
