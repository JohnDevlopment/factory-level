extends Node2D

func _ready() -> void:
	$Flash.play()
	yield(get_tree().create_timer(0.12), 'timeout')
	$Smoke.emitting = true

func _on_KillTimer_timeout() -> void:
	queue_free()

func _on_Flash_frame_changed() -> void:
	if $Flash.frame == 3:
		$Smoke.one_shot = true
		$Smoke.emitting = true
