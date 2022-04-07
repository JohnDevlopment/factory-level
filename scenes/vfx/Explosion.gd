extends Node2D

func _ready() -> void:
	$Dust.one_shot = true
	$Debris.one_shot = true
	$Flash.play('Flash')
	$Glow/AnimationPlayer.play('shrink')
	$BoomSound.pitch_scale = rand_range(0.8, 1.2)
	$BoomSound.play()
	_camera_shake()

func _on_KillTimer_timeout() -> void:
	queue_free()

func _camera_shake() -> void:
	var cameras := Game.get_player_cameras()
	for camera in cameras:
		if camera.has_method('shake'):
			camera.call('shake', 0.3, 15, randf() + 7.0)
