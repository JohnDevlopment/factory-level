tool
extends Node2D

const CAMERA_SIZE := Vector2(256, 192)
const INVISIBLE_WALL = preload('res://scripts/InvisibleWall.gd')

export(Array, Rect2) var camera_rects : Array setget set_camera_rects,get_camera_rects
var editor_color := Color( 0.5, 1, 0.83, 0.4 ) setget set_editor_color
var editor_draw := false setget set_editor_draw

func _enter_tree() -> void:
	if Engine.editor_hint: return
	# connect level exits
	for node in get_tree().get_nodes_in_group('exits'):
		(node as Node).connect('go_to_scene', self, '_on_Room_Exit_go_to_scene')

func _ready() -> void:
	if Engine.editor_hint: return
	# provide screen transition rects with the camera rects
	for tr in get_tree().get_nodes_in_group('transition_rects'):
		tr.camera_rects = camera_rects
		_connect_STR_to_camera_regions(tr)
	# check if there is an entrance defined
	if Game.has_player():
		var level_entrance = Game.level_entrance
		for _node in get_tree().get_nodes_in_group('entrances'):
			var node : Position2D = _node
			if level_entrance == _node.entrance_id:
				var player := Game.get_player()
				player.global_position = node.global_position
		call_deferred('_align_camera')
	if is_inside_tree():
		_fade_in()

func _draw() -> void:
	if not Engine.editor_hint or not editor_draw: return
	for temp in camera_rects:
		var rect := temp as Rect2
		draw_rect(rect, editor_color, false)

func get_camera_rects() -> Array:
	return camera_rects

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
		if rect.has_point(player.global_position):
			player.set_camera_limits_from_rect(rect)
			_add_invisible_wall(rect)

func _add_invisible_wall(region: Rect2) -> void:
	# end of region
	var static_body := INVISIBLE_WALL.new(
		Vector2(region.end.x, region.position.y),
		Vector2(region.end.x, region.end.y)
	)
	static_body.collision_layer = Game.CollisionLayer.WALLS
	static_body.collision_mask = 0
	add_child(static_body)
	# start of region
	static_body = INVISIBLE_WALL.new(
		region.position,
		Vector2(region.position.x, region.end.y)
	)
	static_body.collision_layer = Game.CollisionLayer.WALLS
	static_body.collision_mask = 0
	add_child(static_body)

func _fade_in():
	if get_tree().current_scene == self:
		Game.set_paused(true)
		TransitionRect.set_alpha(1)
		TransitionRect.fade_in()
		yield(TransitionRect, 'fade_finished')
		Game.set_paused(false)

func _fade_out():
	if get_tree().current_scene == self:
		Game.set_paused(true)
		TransitionRect.set_alpha(0)
		TransitionRect.fade_out()
		yield(TransitionRect, 'fade_finished')
		Game.set_paused(false)

# STR = screen transition rectangle
func _connect_STR_to_camera_regions(strect):
	assert(strect is Area2D)
	var area_rect : Rect2 = strect.get_shape_rect()
	var connected := []
	for cr in camera_rects:
		if area_rect.intersects(cr):
			connected.push_back(cr)
	strect.connected_screens = connected

# signals

func _on_Room_Exit_go_to_scene(scene: PackedScene, entrance: int) -> void:
	yield(_fade_out(), 'completed')
	Game.level_entrance = entrance
	SceneSwitcher.add_node_data(Game.get_player())
	SceneSwitcher.change_scene_to(scene)
