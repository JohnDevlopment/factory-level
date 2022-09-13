extends Node2D

var stats := Stats.new()

func _ready() -> void:
	stats.init_stats(self)
	$Dust.one_shot = true
	$Debris.one_shot = true
	$Flash.play('Flash')
	$Glow/AnimationPlayer.play('shrink')
	$BoomSound.pitch_scale = rand_range(0.8, 1.2)
	$BoomSound.play()
	_camera_shake()
	yield(get_tree().create_timer(0.3), 'timeout')
	$Hitbox.disabled = true

func _on_KillTimer_timeout() -> void:
	queue_free()

func _camera_shake() -> void:
	var cameras := Game.get_player_cameras()
	for camera in cameras:
		if camera.has_method('shake'):
			camera.call('shake', 0.3, 15, randf() + 7.0)

func _on_Hitbox_area_entered(area: Area2D) -> void:
	var other : Actor = area.get_parent()
	var launch_speed := Vector2(300, 300)
	other.call(Game.PLAYER_HURT_METHOD, $Hitbox, launch_speed)
