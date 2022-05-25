extends Sprite

func _on_player_detected(_body: Node) -> void:
	if Game.keycards > 0:
		Game.keycards -= 1
		frame += 1
		call_deferred('_do_commands')
		$Area2D.queue_free()

func _do_commands() -> void:
	var cmds : CommandHandler
	
	for node in get_children():
		if node is CommandHandler:
			cmds = node
			break
	
	if is_instance_valid(cmds):
		cmds.do_commands()
