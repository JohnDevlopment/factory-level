extends Area2D

signal go_to_scene(scene, entrance)

export(PackedScene) var next_scene : PackedScene
export(int, -1, 255) var to_entrance := -1

func _process(_delta: float) -> void:
	var bodies := get_overlapping_bodies()
	if bodies.size() > 0:
		set_process(false)
		emit_signal('go_to_scene', next_scene, to_entrance)
