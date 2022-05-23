tool
extends "res://scenes/Room.gd"

func _ready() -> void:
	if Engine.editor_hint: return
	
	for node in get_tree().get_nodes_in_group('lava'):
		node.connect('body_entered', self, '_on_lava_collision')

func _on_lava_collision(body: Node) -> void:
	#print("%s is in the lava" % body)
	if body.has_method('enter_lava_state'):
		body.call('enter_lava_state')
