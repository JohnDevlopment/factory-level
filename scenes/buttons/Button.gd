extends StaticBody2D

signal pressed

onready var animation_player = $AnimationPlayer

var _player : Actor
var _dot : float
var _lock := false

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_READY:
			$AnimationPlayer.connect('animation_finished', self, '_on_AnimationPlayer_animation_finished')
		NOTIFICATION_PHYSICS_PROCESS:
			# don't detect collision during a lock
			if _lock: return
			if _player.is_on_floor():
				var dir := global_position.direction_to(_player.call('get_bottom_edge'))
				_dot = dir.dot(Vector2.UP)
				if _dot >= 0.5:
					call_deferred('_do_toggle_animation')
					set_physics_process(false)

func _do_toggle_animation() -> void:
	_lock = true
	animation_player.play('Toggle')

# Signals

func _on_DetectPlayer_body_entered(body: Node) -> void:
	set_physics_process(true)
	_player = body as Actor

func _on_DetectPlayer_body_exited(_body: Node) -> void:
	set_physics_process(false)
	if _lock:
		$DetectPlayer.queue_free()
		$CollisionShape2D.queue_free()

# Called when the hitbox animation finishes
func _on_AnimationPlayer_animation_finished(_anim_name: String):
	emit_signal('pressed')
