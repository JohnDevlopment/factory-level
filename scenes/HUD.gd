## The HUD (heads-up display) for the player.
# @name HUD
# @singleton
extends Control

#export(NodePath) var player

## The current HP of the player.
# @setter set_hp()
# @type int
var hp := 0 setget set_hp

## The current floor.
# @setter set_current_floor()
# @type int
var current_floor := "" setget set_current_floor

## How many robots are destroyed.
var robots_destroyed := 0 setget set_robots_destroyed

var HPLabel : Label
var FloorLabel : Label
var RobotLabel : Label

var _after_ready := false

func _ready() -> void:
	hide()
	NodeMapper.map_nodes(self)
	_after_ready = true

## Connects the room with the HUD.
# @desc When @a room exits the tree, the HUD will commence all necessary
#       cleanup, which includes hiding itself.
func connect_room(room: Node):
	room.connect('tree_exiting', self, '_on_room_tree_exiting')

func set_current_floor(cf: String) -> void:
	current_floor = cf
	if _after_ready:
		FloorLabel.text = current_floor

func set_hp(_hp: int) -> void:
	hp = _hp
	if _after_ready:
		HPLabel.text = str(hp)

func set_robots_destroyed(rb: int) -> void:
	robots_destroyed = rb
	if _after_ready:
		RobotLabel.text = str(robots_destroyed)

func _on_room_tree_exiting() -> void:
	hide()
	HPLabel.text = '0'
	FloorLabel.text = '~'
	RobotLabel.text = '0'
