tool
extends Enemy

export var armored := false setget set_armored
export var flipped := false

func _ready():
	direction.x = -1 if flipped else 1
	$PositionSnapper.cast_to.x = 20 * direction.x
	$PositionSnapper.position = Vector2(direction.x * 12, 6)
	for node in [$Sprite, $CollisionShape2D, $Hurtbox/CollisionShape2D]:
		node.scale.x = direction.x
	
	if Engine.editor_hint:
		set_process(false)
		set_physics_process(false)
		return
	
	if armored:
		stats.max_health = 2
	
	stats.init_stats(self)

func set_armored(flag: bool) -> void:
	armored = flag
	$Sprite.frame = 1 if armored else 0

func _should_damage() -> bool:
	return true

func _do_commands() -> void:
	var cmds : CommandHandler
	
	for node in get_children():
		if node is CommandHandler:
			cmds = node
			break
	
	if is_instance_valid(cmds):
		cmds.do_commands()
		yield(cmds, 'finished')
	
	queue_free()

# Signals

func _on_damaged(_stats: Stats) -> void:
	if stats.health == 1:
		# Spawn an armor-breaking effect
		var armor_break : Node2D = load('res://scenes/vfx/SwitchRobotArmorBreak.tscn').instance()
		get_parent().add_child_below_node(self, armor_break)
		armor_break.global_position = global_position
		
		set_armored(false)
	else:
		hide()
		Game.spawn_vfx(get_parent(), self, 'robot_explosion', global_position)
		
		enable_collision(false)
		
		# Evaluate commands and mark this robot as dead
		call_deferred('_do_commands')
		emit_defeated()
