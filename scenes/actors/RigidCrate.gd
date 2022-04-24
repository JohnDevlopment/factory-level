extends RigidBody2D

func _on_VisibilityEnabler2D_screen(entered: bool) -> void:
	sleeping = !entered

func _ready() -> void:
	yield(get_tree(), 'idle_frame')
	_on_VisibilityEnabler2D_screen($VisibilityEnabler2D.is_on_screen())
