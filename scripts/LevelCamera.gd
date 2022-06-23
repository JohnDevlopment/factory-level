extends Camera2D

const TakeScreenshot = preload('res://scenes/components/TakeScreenshot.tscn')

export var velocity := Vector2(1, 1)

var _intvel := Vector2()

func _ready() -> void:
	if Game.has_player():
		var player = Game.get_player()
		assert(player.is_queued_for_deletion(),
			"Player and level camera cannot exist in the same scene")
	make_current()

func _physics_process(delta: float) -> void:
	var move_vector = Input.get_vector('ui_left', 'ui_right', 'ui_up', 'ui_down')
	if move_vector == Vector2.ZERO: return
	_intvel = move_vector * velocity * delta
	global_position += _intvel

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_action_pressed('ui_page_down'):
			# Zoom out
			zoom += Vector2(0.05, 0.05)
		elif event.is_action_pressed('ui_page_up'):
			# Zoom in
			zoom -= Vector2(0.05, 0.05)
		elif event.is_action_pressed('ui_home'):
			# Reset zoom
			zoom = Vector2(1, 1)
		elif event.is_action_pressed('debug'):
			var comp = TakeScreenshot.instance()
			comp.delay = 1
			comp.connect('screenshot_taken', self, '_screenshot_taken', [comp])
			add_child(comp)

func _screenshot_taken(node = null) -> void:
	if node:
		node.queue_free()
