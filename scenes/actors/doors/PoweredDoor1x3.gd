extends "res://scenes/actors/doors/PoweredDoorBase.gd"

func _on_ClickableArea_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == BUTTON_LEFT:
			_flip_state()
