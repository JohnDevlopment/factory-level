extends RayCast2D

func _ready() -> void:
	if _is_scene_root():
		push_warning("This should be a child to a Node2D-derived node")
		return
	
	assert(get_parent() is Node2D, "parent must be a Node2D")
	call_deferred('_snap_actor')

func _is_scene_root() -> bool:
	return self.get_instance_id() == get_tree().current_scene.get_instance_id()

func _snap_actor() -> void:
	if is_colliding():
		var point := get_collision_point()
		var difference = point - position
		(get_parent() as Node2D).global_position = difference
