tool
extends StaticBody2D

enum Direction {LEFT = -1, RIGHT = 1}

enum Steepness {NOT_STEEP, STEEP}

export(Direction) var direction : int = Direction.LEFT setget set_direction
export var height := 2 setget set_height
export(Steepness) var steepness := Steepness.NOT_STEEP setget set_steepness
var editor_draw_collision := false setget set_editor_draw_collision
var editor_draw_tiles := true setget set_editor_draw_tiles

const STAIR_TEXTURE := preload('res://assets/textures/stairs.png')

const TILE_SIZE := Vector2(16, 16)

const AREA_COLLISION_THICKNESS := 30.0

# In tiles
const ATLAS_WIDTH := 6

const DRAW_TILE_IDS := PoolIntArray([
	2, 8,
	4, 10, 16, 9, 15
])

var _player : Actor

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_READY:
			set_collision_layer(Game.CollisionLayer.PLATFORMS)
			set_collision_mask(0)
			
			if Engine.editor_hint:
				set_notify_transform(true)
				connect('child_entered_tree', self, '_on_tree_child_entered')
				return
			
			# Collision for the floor on top of the stairs
			$TopPlatform.set_collision_box(height, TILE_SIZE)
			
			# Collision for the stairs
			if get_shape_owners().size() == 0:
				var collision = CollisionPolygon2D.new()
				collision.one_way_collision = true
				collision.one_way_collision_margin = 1.0
				add_child(collision)
				collision.set_deferred('polygon', get_collision_points())
		NOTIFICATION_TRANSFORM_CHANGED:
			position = position.snapped(TILE_SIZE / 2)
		NOTIFICATION_DRAW:
			scale.x = -direction
			
			if not Engine.editor_hint or (Engine.editor_hint and editor_draw_tiles):
				var functions := PoolStringArray(['_draw_stair_tiles',
												'_draw_steep_stair_tiles'])
				call(functions[steepness], Vector2(-TILE_SIZE.x, 0))
			
			# Draw the collision polygon
			if Engine.editor_hint and editor_draw_collision:
				var points = get_collision_points()
				var colors : PoolColorArray
				for i in range(points.size()):
					var _color := Color(
						range_lerp(i, 0, points.size(), 1, 0),
						range_lerp(i, 0, points.size(), 0, 1),
						0,
						0.7
					)
					colors.push_back(_color)
				
				draw_polygon(points, colors)
				
				# TODO: draw $TopPlatform textures in its local script
				draw_rect(
					Rect2(
						Vector2(-height * TILE_SIZE.x, 0),
						Vector2(height * TILE_SIZE.x, 4)
					),
					Color(0.4, 0, 0.1, 0.7)
				)

func get_collision_points() -> PoolVector2Array:
	var functions := PoolStringArray(['_get_collision_points_nonsteep',
									'_get_collision_points_steep'])
	return call(functions[steepness])
	
func set_direction(d: int) -> void:
	direction = d
	update()

func set_editor_draw_collision(flag: bool) -> void:
	editor_draw_collision = flag
	update()

func set_editor_draw_tiles(flag: bool) -> void:
	editor_draw_tiles = flag
	update()

func set_height(h: int) -> void:
	height = max(2, h)
	update()

func set_steepness(v: int) -> void:
	steepness = v
	update()

# Internal functions

func _get_collision_points_steep() -> PoolVector2Array:
	var bottom = (3 + (height - 1) * 2) * TILE_SIZE.y - 15
	return PoolVector2Array([
		Vector2(0, 1),
		Vector2(-2, 1),
		Vector2(-height * TILE_SIZE.x - 1, bottom - 3),
		Vector2(-height * TILE_SIZE.x - 1, bottom),
		Vector2(-height * TILE_SIZE.x, bottom)
	])

func _get_collision_points_nonsteep() -> PoolVector2Array:
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

func _draw_steep_stair_tiles(drawpos: Vector2):
	var i := height - 1
	var stair_offsets = {
		a = _get_tile_offset_from_id(DRAW_TILE_IDS[2]),
		b = _get_tile_offset_from_id(DRAW_TILE_IDS[3]),
		c = _get_tile_offset_from_id(DRAW_TILE_IDS[4]),
		d = _get_tile_offset_from_id(DRAW_TILE_IDS[5]),
		e = _get_tile_offset_from_id(DRAW_TILE_IDS[6])
	}
	
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
			Rect2(stair_offsets.a, TILE_SIZE)
		)
		draw_texture_rect_region(STAIR_TEXTURE,
			Rect2(
				drawpos + Vector2(0, TILE_SIZE.y),
				TILE_SIZE
			),
			Rect2(
				stair_offsets.b,
				TILE_SIZE
			)
		)
		draw_texture_rect_region(STAIR_TEXTURE,
			Rect2(
				drawpos + Vector2(0, TILE_SIZE.y * 2),
				TILE_SIZE
			),
			Rect2(
				stair_offsets.c,
				TILE_SIZE
			)
		)
		draw_texture_rect_region(STAIR_TEXTURE,
			Rect2(
				drawpos + Vector2(-TILE_SIZE.x, TILE_SIZE.y),
				TILE_SIZE
			),
			Rect2(
				stair_offsets.d,
				TILE_SIZE
			)
		)
		
		if i == 0:
			draw_texture_rect_region(STAIR_TEXTURE,
				Rect2(
					drawpos + Vector2(-TILE_SIZE.x, TILE_SIZE.y * 2),
					TILE_SIZE
				),
				Rect2(
					stair_offsets.e,
					TILE_SIZE
				)
			)
		
		drawpos += Vector2(-TILE_SIZE.x, TILE_SIZE.y * 2)
		i -= 1

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
			set_editor_draw_collision(value)
		'editor_draw_tiles':
			set_editor_draw_tiles(value)
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
		},
		{
			name = 'editor_draw_tiles',
			type = TYPE_BOOL,
			usage = PROPERTY_USAGE_DEFAULT
		}
	]

# Signals

func _on_tree_child_entered(node: Node) -> void:
	if node is CollisionPolygon2D:
		if node.polygon.empty():
			node.polygon = get_collision_points()
			node.one_way_collision = true
