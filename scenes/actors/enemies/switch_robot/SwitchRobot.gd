tool
extends Enemy

func _ready():
	if Engine.editor_hint:
		set_process(false)
		set_physics_process(false)
		return
	
	stats.init_stats(self)

func _on_damaged(_stats: Stats) -> void:
	hide()
	
	# Create explosion
	var explosion : Node2D = load('res://scenes/vfx/Explosion.tscn').instance()
	get_parent().add_child_below_node(self, explosion, true)
	explosion.global_position = global_position
	
	emit_defeated()
	queue_free()

func _should_damage() -> bool:
	return true


