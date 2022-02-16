extends CanvasLayer

var _hud : Control

func _ready() -> void:
	_hud = $HUD

func get_hud() -> Control: return _hud
