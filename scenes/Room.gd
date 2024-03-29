tool
extends Node2D

const CAMERA_SIZE := Vector2(256, 192)
const INVISIBLE_WALL = preload('res://scripts/InvisibleWall.gd')

export(Array, Rect2) var camera_rects : Array setget set_camera_rects,get_camera_rects
export var no_fade_in := false

var editor_color := Color( 0.5, 1, 0.83, 0.4 ) setget set_editor_color
var editor_draw := false setget set_editor_draw

func _ready() -> void:
	if Engine.editor_hint: return
	
	# connect level exits
	for node in get_tree().get_nodes_in_group('exits'):
		node.connect_exit(self, '_on_Room_Exit_go_to_scene')
		
	# connect doors
	for node in get_tree().get_nodes_in_group('doors'):
		node.connect_exit(self, '_on_door_go_to_scene')
		
	# provide screen transition rects with the camera rects
	for tr in get_tree().get_nodes_in_group('screen_transitions'):
		tr.set_camera_regions(camera_rects)
		
	# check if there is an entrance defined
	if Game.has_player():
		var level_entrance = Game.level_entrance
		for _node in get_tree().get_nodes_in_group('entrances'):
			var node : Position2D = _node
			if level_entrance == _node.entrance_id:
				var player := Game.get_player()
				player.global_position = node.global_position
		call_deferred('_align_camera')
		
		# Connect player signals
		var player = Game.get_player()
		player.connect('transition_finished', self, '_on_player_transition_finished')
		player.connect('transition_started', self, '_on_player_transition_started')
		player.connect('player_dead', self, '_on_player_dead')
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
	var desired_rect = null
	
	# No region has been selected, so look for any level bounds rect
	if not desired_rect is Rect2:
		var level_bounds_rects := get_tree().get_nodes_in_group('level_bounds')
		if level_bounds_rects.size():
			var temp : Control = level_bounds_rects[0]
			desired_rect = temp.get_rect()
	
	# Find which region the player is in, if any
	for _rect in camera_rects:
		var rect: Rect2 = _rect
		if rect.size < CAMERA_SIZE:
			var diff := CAMERA_SIZE - rect.size
			rect = rect.grow_individual(0, 0, diff.x, diff.y)
		if rect.has_point(player.global_position):
			desired_rect = rect
			break
	
	# Set the player camera limits according to the chosen bounds of the level
	if desired_rect:
		player.set_camera_limits_from_rect(desired_rect)
		_add_invisible_wall(desired_rect)

func _add_invisible_wall(region: Rect2) -> void:
	var data := [
		[region.position, Vector2(region.position.x, region.end.y)],
		[Vector2(region.end.x, region.position.y), region.end]
	]
	
	for params in data:
		var static_body := INVISIBLE_WALL.new(params[0], params[1])
		static_body.collision_layer = Game.CollisionLayer.WALLS
		static_body.collision_mask = 0
		add_child(static_body)

func _clear_invisible_walls() -> void:
	for node in get_tree().get_nodes_in_group(INVISIBLE_WALL.GROUP_NAME):
		node.queue_free()

func _fade_in():
	if not no_fade_in:
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

# signals

func _on_Room_Exit_go_to_scene(_body, scene: PackedScene, entrance: int) -> void:
	yield(_fade_out(), 'completed')
	Game.level_entrance = entrance
	SceneSwitcher.add_node_data(Game.get_player())
	SceneSwitcher.change_scene_to(scene)

func _on_door_go_to_scene(scene: PackedScene, entrance: int) -> void:
	_on_Room_Exit_go_to_scene(null, scene, entrance)

func _on_player_transition_finished(rect: Rect2) -> void:
	_add_invisible_wall(rect)

func _on_player_transition_started() -> void:
	_clear_invisible_walls()

func _on_player_dead() -> void:
	var root := get_viewport()
	assert(root == get_tree().root)
	
	# Instance the gameover screen
	var GameOverScreen := preload('res://scenes/GameOverScreen.tscn')
	var gms := GameOverScreen.instance()
	gms.music_playing = true
	gms.previous_scene = filename
	root.add_child(gms)
	gms.fade_in()
