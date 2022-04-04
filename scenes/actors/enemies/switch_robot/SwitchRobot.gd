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
	emit_defeated()
	queue_free()

func _should_damage() -> bool:
	return true


