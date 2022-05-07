tool
extends StaticBody2D

export(int, 1, 16) var height : int = 1 setget set_height

func _ready() -> void:
	if Engine.editor_hint:
		return
	$Animations.play('Slide')
	var collider := $CollisionShape2D as CollisionShape2D
	collider.shape = RectangleShape2D.new()
	collider.shape.extents = Vector2(8 * height, 8)

func set_height(h: int) -> void:
	height = h
	call_deferred('_update_wall_height')

func _update_wall_height() -> void:
	$Frames.region_rect.size.y = 16 * height
