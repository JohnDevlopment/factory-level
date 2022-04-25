tool
extends StaticBody2D

enum Direction {LEFT = -1, RIGHT = 1}

export(Direction) var direction : int = Direction.LEFT setget set_direction
export var height := 2 setget set_height
var editor_draw_collision := false setget set_editor_draw_collision

const STAIR_TEXTURE := preload('res://assets/textures/stairs.png')

const TILE_SIZE := Vector2(16, 16)

const AREA_COLLISION_THICKNESS := 30.0

# In tiles
const ATLAS_WIDTH := 6

const DRAW_TILE_IDS := PoolIntArray([2, 8])

var _player : Actor

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_READY:
			set_collision_layer(Game.CollisionLayer.STAIRS)
			set_collision_mask(0)
			set_process(false)
			
			if Engine.editor_hint:
				set_notify_transform(true)
				connect('child_entered_tree', self, '_on_tree_child_entered')
				return
			
			set_process_unhandled_key_input(false)
			
			# Collision for the floor on top of the stairs
			$TopPlatform.set_collision_box(height, TILE_SIZE)
			
			# Collision for the stairs
			if get_shape_owners().size() == 0:
				var collision = CollisionPolygon2D.new()
				collision.one_way_collision = true
				collision.one_way_collision_margin = 1.0
				add_child(collision)
				collision.set_deferred('polygon', _get_collision_points())
			
			# Collision for the area
			if true:
				var detection_field = $DetectionField
				var area_collision := CollisionPolygon2D.new()
				area_collision.polygon = PoolVector2Array([
					Vector2(-height * TILE_SIZE.x, 0),
					Vector2(-4, 0),
					Vector2(-height * TILE_SIZE.x, height * TILE_SIZE.y)
				])
				detection_field.add_child(area_collision)
		NOTIFICATION_TRANSFORM_CHANGED:
			position = position.snapped(TILE_SIZE / 2)
		NOTIFICATION_PROCESS:
			# If the player is jumping, enable collision
			if _player.velocity.y < 0.0 or _player.velocity.y > Actor.GRAVITY_STEP:
				_player.set_collision_mask_bit(Game.CollisionLayerIndex.STAIRS, true)
				set_process(false)
				return
		NOTIFICATION_DRAW:
			scale.x = -direction
			_draw_stair_tiles(Vector2(-TILE_SIZE.x, 0))
			
			# Draw the collision polygon
			if Engine.editor_hint and editor_draw_collision:
				var points := _get_collision_points()
				var colors : PoolColorArray
				for i in range(points.size()):
					var _color := Color(
						range_lerp(i, 0, points.size(), 1, 0),
						range_lerp(i, 0, points.size(), 0, 1),
						0,
						0.7
					)
					colors.push_back(_color)
				draw_polygon(_get_collision_points(), colors)
				
				# TODO: draw $TopPlatform textures in its local script
				draw_rect(
					Rect2(
						Vector2(-height * TILE_SIZE.x, 0),
						Vector2(height * TILE_SIZE.x, 4)
					),
					Color(0.4, 0, 0.1, 0.7)
				)

func _unhandled_key_input(event: InputEventKey) -> void:
	if event.is_action_pressed('jump'):
		if _player.is_on_floor():
			_player.set_collision_mask_bit(Game.CollisionLayerIndex.STAIRS, true)
		get_tree().set_input_as_handled()
	elif event.is_action_pressed('ui_down'):
		if _player.is_on_floor() and _player.get_collision_mask_bit(Game.CollisionLayerIndex.STAIRS):
			_player.set_collision_mask_bit(Game.CollisionLayerIndex.STAIRS, false)
		get_tree().set_input_as_handled()

func set_direction(d: int) -> void:
	direction = d
	update()

func set_editor_draw_collision(flag: bool) -> void:
	editor_draw_collision = flag
	update()

func set_height(h: int) -> void:
	height = max(2, h)
	update()

# Internal functions

func _get_collision_points() -> PoolVector2Array:
	return PoolVector2Array([
		Vector2(0, 1),
		Vector2(-2, 1),
		Vector2(-height * TILE_SIZE.x, height * TILE_SIZE.y - 1),
		Vector2(-height * TILE_SIZE.x, height * TILE_SIZE.y + 5),
		Vector2(-2, 7),
		Vector2(0, 7)
	])

# Drawing subfunctions

func _get_tile_offset_from_id(id: int) -> Vector2:
	return Vector2(
		float(id % ATLAS_WIDTH),
		float(id / ATLAS_WIDTH)
	) * TILE_SIZE

func _draw_stair_tiles(drawpos : Vector2):
	var i := height - 1
	var stair_offset_a := _get_tile_offset_from_id(DRAW_TILE_IDS[0])
	var stair_offset_b := _get_tile_offset_from_id(DRAW_TILE_IDS[1])
	
	# Draw tiles
	while i >= 0:
		# Top platform
		draw_texture_rect_region(
			STAIR_TEXTURE,
			Rect2(Vector2(drawpos.x, 0), TILE_SIZE),
			Rect2(_get_tile_offset_from_id(1), TILE_SIZE)
		)
		
		# Stairs
		draw_texture_rect_region(STAIR_TEXTURE,
			Rect2(drawpos, TILE_SIZE),
			Rect2(stair_offset_a,TILE_SIZE)
		)
		draw_texture_rect_region(STAIR_TEXTURE,
			Rect2(
				drawpos + Vector2(0, TILE_SIZE.y),
				TILE_SIZE
			),
			Rect2(
				stair_offset_b,
				TILE_SIZE
			)
		)
		
		drawpos += Vector2(-TILE_SIZE.x, TILE_SIZE.y)
		i -= 1
	
	return drawpos

# Properties

func _get(property: String):
	match property:
		'editor_draw_collision':
			return editor_draw_collision

func _set(property: String, value) -> bool:
	match property:
		'editor_draw_collision':
			editor_draw_collision = value
			update()
		_:
			return false
	
	return true

func _get_property_list() -> Array:
	return [
		{
			name = 'editor',
			type = TYPE_NIL,
			usage = PROPERTY_USAGE_GROUP | PROPERTY_USAGE_SCRIPT_VARIABLE,
			hint_string = 'editor_'
		},
		{
			name = 'editor_draw_collision',
			type = TYPE_BOOL,
			usage = PROPERTY_USAGE_DEFAULT
		}
	]

# Signals

func _on_tree_child_entered(node: Node) -> void:
	if node is CollisionPolygon2D:
		if node.polygon.empty():
			node.polygon = _get_collision_points()
			node.one_way_collision = true

func _on_DetectionField_body(body: Node, entered: bool) -> void:
	set_process_unhandled_key_input(entered)
	set_process(entered)
	_player = body
	_player.set_collision_mask_bit(Game.CollisionLayerIndex.STAIRS, false)
