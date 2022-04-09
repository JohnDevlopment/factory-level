extends Node2D

export var lifetime := 1.0

func _ready() -> void:
	$KillTimer.start(lifetime)

func _on_KillTimer_timeout() -> void:
	queue_free()
