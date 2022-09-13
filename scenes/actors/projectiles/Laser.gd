tool
extends Actor

export var projectile_speed : float

func _ready() -> void:
	gravity_value = 0

func launch(location: Vector2, direction: float, angle: float) -> void:
	var linvel := Vector2(projectile_speed, 0) * direction
	set_as_toplevel(true)
	rotation = angle
	position = location
	$Frames.play('Charge')
	yield($Frames, 'animation_finished')
	velocity = linvel.rotated(angle)
	$CollisionShape2D.set_deferred('disabled', false)

func _physics_process(delta: float) -> void:
	if move_and_collide(velocity * delta, false):
		_explode()

func _on_VisibilityNotifier2D_screen_exited() -> void:
	queue_free()

func _explode() -> void:
	Game.spawn_vfx(get_parent(), self, 'explosion', global_position)
	queue_free()
