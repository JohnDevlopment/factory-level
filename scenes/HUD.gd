extends Control

#export(NodePath) var player

var hp := 0 setget set_hp
var current_floor := "" setget set_current_floor
var robots_destroyed := 0 setget set_robots_destroyed

var HPLabel : Label
var FloorLabel : Label
var RobotLabel : Label

var _after_ready := false

func _ready() -> void:
	hide()
	NodeMapper.map_nodes(self)
	_after_ready = true

func set_current_floor(cf: String) -> void:
	current_floor = cf
	if _after_ready:
		FloorLabel.text = current_floor

func set_hp(_hp: int) -> void:
	hp = _hp
	if _after_ready:
		HPLabel.text = str(hp)

#func set_max_hp(mhp: int):
#	pass

func set_robots_destroyed(rb: int) -> void:
	robots_destroyed = rb
	if _after_ready:
		RobotLabel.text = str(robots_destroyed)
