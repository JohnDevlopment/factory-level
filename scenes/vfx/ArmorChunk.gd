tool
extends Actor

func _ready() -> void:
	if not Engine.editor_hint:
		velocity = speed_cap
		gravity_value = 400

func _physics_process(delta: float) -> void:
	move_and_collide(velocity * delta, false)
	if velocity.x:
		velocity.x = velocity.x - (velocity.x * (delta * 0.95))
		if is_zero_approx(velocity.x):
			velocity.x = 0.0
