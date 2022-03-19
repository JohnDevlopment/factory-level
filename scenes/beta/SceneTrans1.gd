tool
extends "res://scenes/Room.gd"

var gut_tester

var ToNextScreen : Area2D
var Bob : Actor

func _ready() -> void:
	if Engine.editor_hint: return
	NodeMapper.map_nodes(self)
