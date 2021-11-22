extends Area2D

export var disabled := false setget set_disabled

func set_disabled(flag: bool) -> void:
	disabled = flag
	$CollisionShape2D.disabled = flag
