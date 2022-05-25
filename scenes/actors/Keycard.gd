tool
extends Actor

var _spawned := false

func _ready() -> void:
	if Engine.editor_hint:
		set_physics_process(false)
		return

func _physics_process(_delta: float) -> void:
	velocity = move_and_slide(velocity, Vector2.UP, true)

func _on_DetectionField_body_entered(_body: Node) -> void:
	Game.keycards += 1
	queue_free()

func launch() -> void:
	velocity.y = -300
	enable_collision(false)
	yield(get_tree().create_timer(0.8), 'timeout')
	enable_collision(true)
