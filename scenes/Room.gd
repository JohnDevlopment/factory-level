tool
extends Node2D

const CAMERA_SIZE := Vector2(256, 192)

export(Array, Rect2) var camera_rects : Array setget set_camera_rects
var editor_color := Color( 0.5, 1, 0.83, 0.4 ) setget set_editor_color
var editor_draw := false setget set_editor_draw

func _ready() -> void:
	if Engine.editor_hint: return
	yield(_align_camera(), 'completed')
	_show_hud()
	Game.set_paused(true)
	TransitionRect.set_alpha(1)
	TransitionRect.fade_in()
	yield(TransitionRect, 'fade_finished')
	Game.set_paused(false)

func _draw() -> void:
	if not Engine.editor_hint or not editor_draw: return
	for temp in camera_rects:
		var rect := temp as Rect2
		draw_rect(rect, editor_color, false)

func set_camera_rects(rects: Array) -> void:
	var i := 0
	for e in rects:
		assert(e is Rect2, "rects[%d] is not a Rect2" % i)
		i += 1
	camera_rects = rects
	update()

func set_editor_color(color: Color) -> void:
	editor_color = color
	update()

func set_editor_draw(draw: bool) -> void:
	editor_draw = draw
	update()

func _get_property_list() -> Array:
	return [
		{
			name = 'Editor',
			type = TYPE_NIL,
			usage = PROPERTY_USAGE_GROUP | PROPERTY_USAGE_SCRIPT_VARIABLE,
			hint_string = 'editor_'
		},
		{
			name = 'editor_color',
			type = TYPE_COLOR,
			usage = PROPERTY_USAGE_DEFAULT
		},
		{
			name = 'editor_draw',
			type = TYPE_BOOL,
			usage = PROPERTY_USAGE_DEFAULT
		}
	]

func _get(property: String):
	match property:
		'editor_color':
			return editor_color
		'editor_draw':
			return editor_draw

func _set(property: String, value) -> bool:
	match property:
		'editor_draw':
			editor_draw = value
			update()
		'editor_color':
			set_editor_color(value)
		_:
			return false
	return true

func _align_camera():
	if not Game.has_player(): return
	yield(get_tree(), 'idle_frame')
	var player := Game.get_player()
	for _rect in camera_rects:
		var rect: Rect2 = _rect
		if rect.size < CAMERA_SIZE:
			var diff := CAMERA_SIZE - rect.size
			rect = rect.grow_individual(0, 0, diff.x, diff.y)
			print("camera rect expanded to ", rect)
		if rect.has_point(player.global_position):
			player.set_camera_limits_from_rect(rect)

func _show_hud() -> void:
	var hud = UI.get_hud()
	hud.show()
	hud.connect_room(self)
