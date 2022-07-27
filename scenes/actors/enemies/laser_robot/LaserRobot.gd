tool
extends Enemy

const ANGLE_THRESHOLD := 0.785398
const ANGLE_SPEED := deg2rad(15.0)

export(float, 1, 500, 0.1) var angular_velocity := 1.0
export var flipped := false

onready var ai: Node = $AI
onready var blackboard: Blackboard = $Blackboard
onready var detect_player: RayCast2D = $'%DetectPlayer'

func _ready():
	if Engine.editor_hint:
		set_process(false)
		set_physics_process(false)
		return
	
	stats.init_stats(self)
	
	# Set direction
	direction.x = -1 if flipped else 1
	$Head.scale.x = direction.x
	$Pole.scale.x = direction.x
	$DetectionField/CollisionShape2D.position.x = 73 if flipped else -61
	$Hurtbox.position.x = 9.5
	
	if Game.has_player():
		enable_actor(true)
	else:
		_enable_actor(false)
		enable_collision(false)
	
	blackboard.set_data('direction', -direction.x)
	blackboard.set_data('raycast', detect_player)
	blackboard.set_data('raycast/cast_to', detect_player.cast_to * direction.x)
	blackboard.set_data('spawn_point', $'%SpawnPoint')

func _enable_actor(flag: bool) -> void:
	set_physics_process(flag)
	if not flag:
		ai.abort()
	blackboard.set_data('player', Game.get_player() if flag else null)

func _on_damaged(_stats: Stats) -> void:
	Game.spawn_vfx(get_parent(), self, 'robot_explosion', global_position)
	enable_actor(false)
	yield(get_tree().create_timer(3.0), 'timeout')
	queue_free()
	emit_defeated()

func _physics_process(_delta: float) -> void:
	velocity = move_and_slide(velocity, Vector2.UP, false)
	if velocity.x:
		var weight : float = 0.2 if is_on_floor() else 0.02
		velocity.x *= 1.0 - weight
		if Math.is_almost_zero(velocity.x, 0.07):
			velocity.x = 0

# Returns the angle
func _target_player(offset: Vector2 = Vector2()):
	var a : Vector2 = global_position
	var b : Vector2 = Game.get_player().get_center() + offset
	var c : Vector2 = ((b - a) if direction.x < 0 else (a - b)).normalized()
	
	var angle : float = c.angle()
	if not Math.is_in_range(angle, -ANGLE_THRESHOLD, ANGLE_THRESHOLD) \
	and abs(angle) > 0.0174533:
		return clamp(angle, -ANGLE_THRESHOLD, ANGLE_THRESHOLD)
	
	return angle

func _enable_collision(flag: bool) -> void:
	for node in [$Hurtbox, $DetectionField]:
		(node as Area2D).call_deferred('set_disabled', !flag)
	detect_player.enabled = flag

func _on_screen_visibility(flag: bool) -> void:
	_enable_actor(flag and Game.has_player())

func _on_DetectionField_body_entered(_body: Node) -> void:
	ai.is_active = true
	ai.start()

func _on_DetectionField_body_exited(_body: Node) -> void:
	ai.abort()
