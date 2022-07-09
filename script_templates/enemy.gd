tool
extends Enemy

func _ready():
	if Engine.editor_hint:
		set_process(false)
		set_physics_process(false)
		return
	
	stats.init_stats(self)

func _on_damaged(stats: Stats) -> void:
	pass

func _should_damage() -> bool:
	return true

func _enable_actor(flag: bool) -> void:
	pass

func _enable_collision(flag: bool) -> void:
	pass
