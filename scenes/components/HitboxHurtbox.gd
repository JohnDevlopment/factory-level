extends Area2D

export var disabled := false setget set_disabled

func set_disabled(flag: bool) -> void:
	for n in get_children():
		if n is CollisionShape2D:
			n.disabled = flag
