extends Node

export var fallback_scene : PackedScene

var previous_scene : Node
var options : Dictionary setget set_options

var _quit := false

func _ready() -> void:
	set_options({})

func add_node_data(node: Node, function: String = 'serialize') -> void:
	if not is_instance_valid(node):
		push_error("Node is invalid")
		return
	var save_nodes : Dictionary = options.get('save_nodes', {})
	if node.has_method(function):
		var data = node.call(function)
		if data is Dictionary:
			data['node'] = node
			save_nodes[node.name] = data
		return
	options['save_nodes'] = save_nodes

func change_scene(scene: String, opt: Dictionary = {}) -> int:
	set_options(opt)
	return _load_scene(scene, 'change_scene_to')

func change_scene_to(scene: PackedScene) -> int:
	var node : Node
	if is_instance_valid(scene):
		node = scene.instance()
		if not is_instance_valid(node):
			options = {}
			return ERR_CANT_CREATE
		call_deferred('_change_scene', node)
	return OK

func set_options(opt: Dictionary) -> void:
	options = opt
	if not 'save_nodes' in options:
		options['save_nodes'] = {}

func _change_scene(new_root: Node) -> void:
	var tree := get_tree()
	previous_scene = tree.current_scene
	tree.current_scene = null
	
	if is_instance_valid(previous_scene):
		previous_scene.free()
		previous_scene = null
	
	# if quitting, free the node
	if _quit and is_instance_valid(new_root):
		new_root.free()
		new_root = null
	
	# add to scene tree
	if is_instance_valid(new_root):
		# check if node name has '@'s in it
		var unique_name := new_root.name.find('@') < 0
		tree.root.add_child(new_root, unique_name)
		tree.current_scene = new_root
	else:
		# fallback scene if the other is invalid
		tree.current_scene = fallback_scene.instance()
		set_options({})
	
	# load data for each node
	for _node in options.save_nodes:
		var node := new_root.find_node(_node)
		if not is_instance_valid(node): continue
		var node_data : Dictionary = options.save_nodes[_node]
		node.call(node_data.get('deserialize_function', 'deserialize'), node_data)
	
	# cleanup
	set_options({})

func _load_scene(scene: String, function: String) -> int:
	var inst = ResourceLoader.load(scene, 'PackedScene')
	if not inst:
		options = {}
		return ERR_CANT_OPEN
	return call(function, inst)
