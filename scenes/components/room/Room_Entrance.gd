extends Position2D

export(int, 0, 255) var entrance_id := 0

func _ready() -> void:
	$Sprite.queue_free()
