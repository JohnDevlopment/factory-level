extends Area2D

signal go_to_scene(scene, entrance)

export(PackedScene) var next_scene : PackedScene
export(int, -1, 255) var to_entrance := -1

func connect_exit(node: Node, function: String) -> void:
	connect('body_entered', node, function, [next_scene, to_entrance], CONNECT_ONESHOT)
