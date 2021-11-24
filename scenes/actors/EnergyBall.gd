tool
extends Actor

signal picked_up
signal dropped

export var neccessary_velocity := Vector2()

onready var hitbox = $Hitbox
export var picked_up := false
onready var player : Actor = Game.get_player()

func _ready() -> void:
	if Engine.editor_hint:
		set_process(false)
		set_physics_process(false)
		return

# warning-ignore:unused_argument
func _process(delta: float) -> void:
	var fast_enough : bool = abs(velocity.x) >= neccessary_velocity.x or velocity.y >= neccessary_velocity.y
	hitbox.disabled = !fast_enough

# warning-ignore:unused_argument
func _physics_process(delta: float) -> void:
	if picked_up:
		global_position = player.global_position - Vector2(0, 20)
		return
	
	velocity = move_and_slide(velocity, Vector2.UP, false, 4, 0.785398, false)
	for i in get_slide_count():
		var slide := get_slide_collision(i)
		var collider = slide.collider
		if collider is Actor:
			if collider.get_collision_layer_bit(Globals.CollisionLayers.ENEMIES):
				_check_collision_with_enemy(slide)
	
	if velocity.x:
		var weight : float = 0.08 if is_on_floor() else 0.02
		velocity.x = lerp(velocity.x, 0.0, weight)
		if Math.is_almost_zero(velocity.x, 0.05):
			velocity.x = 0
			print('zero velocity')

func _unhandled_key_input(event: InputEventKey) -> void:
	if event.is_action_pressed('action'):
		get_tree().set_input_as_handled()
		if picked_up:
			_set_picked(false)
		else:
			var nodes : Array = hitbox.get_overlapping_bodies()
			for node in nodes:
				if node == player:
					_set_picked(true)

func _set_picked(picked: bool) -> void:
	if picked:
		# Object is picked up
		picked_up = true
		emit_signal('picked_up')
	else:
		# Object is dropped
		picked_up = false
		velocity = Vector2(100, -200)
		emit_signal('dropped')
		
	enable_collision(!picked_up)

func _check_collision_with_enemy(collision: KinematicCollision2D):
	print("collision normal: %s" % [collision.normal])
