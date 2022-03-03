## User interface singleton
# @name UI
# @singleton
# @desc Use this to access anything related to UI.
extends CanvasLayer

var _hud : Control

func _ready() -> void:
	_hud = $HUD

## Returns a reference to the HUD scene.
func get_hud() -> Control: return _hud
