extends Node

var parent_node: Node
var remote_nodes: = []
var initial_position: = Vector2()

const valid_commands: = [
	["delete_node", [TYPE_INT], ["iid"]],
	["list_actor_ids", [], []],
	["new_actor", [-1, TYPE_VECTOR2], ["actor_id", "spawn_pos"]],
	["reset_position", [], []],
	["reset_scene", [], []],
	["set_position", [], []],
	["set_object_property", [TYPE_INT, TYPE_STRING, -1], ['iid', 'prop', 'value']]
]

func delete_node(iid: int) -> String:
	var inst := instance_from_id(iid)
	if not is_instance_valid(inst):
		return "@error:%d does not refer to a valid instance" % iid
	
	(inst as Node).queue_free()
	
	return str("Deleted ", inst)

func list_actor_ids() -> String:
	var result := ""
	for id in Game.ActorIDS:
		result += str(id, "\n")
		#result += str(id, " = ", Game.actor_id_to_string(id), "\n")
	return result

func new_actor(id, pos: Vector2) -> String:
	if (id is String):
		id = Game.ActorIDS.get(id, -1)
	elif not (id is int):
		return "@error:invalid parameter %s, must be an integer or string" % id
	
	var result := ""
	
	var scene = Game.Scenes.get(id)
	if not is_instance_valid(scene):
		result = "@error:no actor with ID %d exists" % id
	else:
		var instance = (scene as PackedScene).instance()
		var parent: Node = get_node('/root/Main')
		assert( is_instance_valid(parent), "not in CharacterTest.tscn!" )
		
		var player = Game.get_player()
		assert(player, "where is the player?")
		parent.add_child(instance)
		parent.move_child(instance, player.get_index())
		
		instance.global_position = pos
		result = "Spawn new %s (IID: %d) at position %s" \
					% [Game.actor_id_to_string(id), instance.get_instance_id(), pos]
	
	return result

func reset_position() -> String:
	var kevin : Actor = Game.get_player()
	kevin.global_position = initial_position
	return str("reset Kevin's position to ", initial_position)

func reset_scene() -> String:
	get_tree().call_deferred('reload_current_scene')
	return "@exit"

func set_object_property(iid: int, prop: String, value) -> String:
	var obj : Object = instance_from_id(iid)
	if not is_instance_valid(obj):
		return "@error:There is no object with instance id %s" % iid
	
	var f := 'set'
	if prop.find_last(':') > 1:
		f += '_indexed'
	
	obj.call_deferred(f, prop)
	
	return "set property '%s' to %s" % [prop, value]

func set_position() -> String:
	var kevin : Actor = Game.get_player()
	initial_position = kevin.global_position
	return "Saved position: %s" % initial_position
