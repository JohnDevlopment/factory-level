tool
extends Node

signal command(cmd, params)

export var command_name : String
export(Array, Dictionary) var arguments : Array

func do_command() -> void: pass

func emit_command_signal(params: Array) -> void:
	emit_signal('command', params)
