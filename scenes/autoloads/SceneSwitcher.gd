extends Node

var previous_scene : Node

var _quit := false

func _ready() -> void:
	pass

func change_scene(scene: String) -> int:
	var inst = ResourceLoader.load(scene, 'PackedScene')
	if not inst: return ERR_CANT_OPEN
	return change_scene_to(inst)

func change_scene_to(scene: PackedScene) -> int:
	var node : Node
	if is_instance_valid(scene):
		node = scene.instance()
		if not is_instance_valid(node): return ERR_CANT_CREATE
		call_deferred('_change_scene', node)
	return OK

func _change_scene(new_root: Node) -> void:
	var tree := get_tree()
	previous_scene = tree.current_scene
	tree.current_scene = null
	
	# free previous scene
	if is_instance_valid(previous_scene):
		previous_scene.free()
		previous_scene = null
	
	# if quitting, free the node
	if _quit:
		if is_instance_valid(new_root):
			new_root.free()
			new_root = null
	
	# add to scene tree
	if is_instance_valid(new_root):
		# check if node name has '@'s in it
		var unique_name := new_root.name.find('@') < 0
		tree.root.add_child(new_root, unique_name)
		tree.current_scene = new_root
