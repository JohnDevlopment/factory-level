tool
extends "res://scenes/components/commands/button_commands/ButtonCommand.gd"

export(NodePath) var conveyor_belt

enum Speed {
	UNCHANGED = -1,
	VERY_SLOW = 10,
	SLOW = 20,
	NORMAL = 40,
	FAST = 60,
	VERY_FAST = 80
}

export var flip_direction := true

export(Speed) var movement_speed : int = Speed.UNCHANGED

func do_command() -> void:
	var belt = get_node_or_null(conveyor_belt)
	if belt:
		if 'direction' in belt and flip_direction:
			belt.direction = -(belt.direction)
		if 'movement_speed' in belt and movement_speed > 0:
			belt.movement_speed = movement_speed
