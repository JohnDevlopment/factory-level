tool
extends TileSet

#const BIND_ALL := 511

enum {
	FOREGROUND              = 0,
	LEFT_FACING_SLOPE       = 5,
	LEFT_FACING_LONG_SLOPE  = 6,
	RIGHT_FACING_LONG_SLOPE = 7,
	RIGHT_FACING_SLOPE      = 8
}

const FILL_TILE := Vector2(9, 2)

const BINDS := {
	LEFT_FACING_SLOPE: [FOREGROUND],
	LEFT_FACING_LONG_SLOPE: [FOREGROUND],
	RIGHT_FACING_SLOPE: [FOREGROUND],
	RIGHT_FACING_LONG_SLOPE: [FOREGROUND],
	FOREGROUND: [LEFT_FACING_LONG_SLOPE, RIGHT_FACING_LONG_SLOPE, LEFT_FACING_SLOPE, RIGHT_FACING_SLOPE]
}

enum TileDirection {LEFT, UP, RIGHT, DOWN}

func _is_tile_bound(drawn_id: int, neighbor_id: int) -> bool:
	if drawn_id in BINDS:
		return neighbor_id in BINDS[drawn_id]
	return false

func _forward_subtile_selection(autotile_id: int, bitmask: int, tilemap: Object, tile_location: Vector2):
	#var subtiles := get_subtiles(autotile_id)
	var tm := tilemap as TileMap
	match autotile_id:
		FOREGROUND:
			if bitmask & BIND_TOP:
				if tm.get_cellv(tile_location + Vector2.UP) in [LEFT_FACING_LONG_SLOPE, RIGHT_FACING_LONG_SLOPE]:
					# tile above is a slope
					tm.set_cellv(tile_location, autotile_id)
					return FILL_TILE
		LEFT_FACING_LONG_SLOPE:
#			var coord = slope_tile(autotile_id, tile_location, bitmask, {
#				tilemap = tilemap,
#				dir_horz = TileDirection.LEFT,
#				bind_horz = BIND_LEFT,
#				dir_vert = TileDirection.UP,
#				bind_vert = BIND_TOP,
#				test = "sid <= 3.0"
#			})
			#if coord is Vector2: return coord
			pass
#			if bitmask == BIND_CENTER:
#				# icon tile when there are no adjacent tiles
#				tm.set_cellv(tile_location, autotile_id)
#				return autotile_get_icon_coordinate(autotile_id)
#
#			var neighbor_tiles := get_adjacent_tiles(tile_location, tilemap)
#			if bitmask & BIND_LEFT:
#				# check that the tile to the left has the same ID
#				if (neighbor_tiles[TileDirection.LEFT].id as int) == autotile_id:
#					var coord : Vector2 = neighbor_tiles[TileDirection.LEFT].autotile_coord
#					var new_tile := autotile_id
#					if coord.x <= 3.0:
#						coord.x += 1.0
#					else:
#						coord = FILL_TILE
#						new_tile = FOREGROUND
#
#					tm.set_cellv(tile_location, new_tile)
#					return coord
#			if bitmask & BIND_TOP:
#				# check that the tile above has the same ID
#				if (neighbor_tiles[TileDirection.UP].id as int) == autotile_id:
#					var new_tile_id := autotile_id
#					var coord : Vector2 = neighbor_tiles[TileDirection.UP].autotile_coord
#					if coord.x == 0.0:
#						coord.x = 3.0
#					elif coord.x >= 2.0:
#						new_tile_id = FOREGROUND
#						coord = Vector2(9, 2)
#					else:
#						coord.x += 1
#					tm.set_cellv(tile_location, new_tile_id)
#					return coord
#			# Fallback when all other conditions fail; use the icon texture
#			tm.set_cellv(tile_location, autotile_id)
#			return autotile_get_icon_coordinate(autotile_id)

func create_expression(expression: String, binds: PoolStringArray) -> Expression:
	var e := Expression.new()
	var err := e.parse(expression, binds)
	if err:
		printerr(e.get_error_text())
	return e

# Returns the coordinate of the autotile subtile left of v.
# Returns a negative vector if the two tiles have different IDs.
#func get_subtile_left(tm: TileMap, autotile_id: int, v: Vector2) -> Vector2:
#	return _get_subtile_shifted(tm, autotile_id, v, Vector2.LEFT)
#
## Returns the coordinate of the autotile subtile right of v.
## Returns a negative vector if the two tiles have different IDs.
#func get_subtile_right(tm: TileMap, autotile_id: int, v: Vector2) -> Vector2:
#	return _get_subtile_shifted(tm, autotile_id, v, Vector2.RIGHT)
#
## Returns the coordinate of the autotile subtile left of v.
## Returns a negative vector if the two tiles have different IDs.
#func get_subtile_up(tm: TileMap, autotile_id: int, v: Vector2) -> Vector2:
#	return _get_subtile_shifted(tm, autotile_id, v, Vector2.UP)
#
#func _get_subtile_shifted(tm: TileMap, autotile_id: int, v: Vector2, o: Vector2) -> Vector2:
#	var tile_location := v + o
#	if tm.get_cellv(tile_location) == autotile_id:
#		return tm.get_cell_autotile_coord(tile_location.x, tile_location.y)
#	return Vector2(-1, -1)

# Returns an array of tiles that are adjacent to the one at the given cell.
# Each element is a dictionary:
#   cell <Vector2> = location of the tile
#   id <int> = ID of the tile
#   autotile_coord <Vector2> = coordinate of the subtile if ID is an autotile
# Indices:
#   0 = left
#   1 = up
#   2 = right
#   3 = down
func get_adjacent_tiles(tile_location: Vector2, tilemap: TileMap) -> Array:
	var result := [
		Vector2.LEFT,
		Vector2.UP,
		Vector2.RIGHT,
		Vector2.DOWN
	]
	for _i in range(4):
		var offset : Vector2 = result.pop_front()
		var cell := tile_location + offset
		result.push_back({
			cell = cell,
			id = tilemap.get_cellv(cell),
			autotile_coord = tilemap.get_cell_autotile_coord(cell.x, cell.y)
		})
	return result

func get_subtile_coord(sid: int, width: int):
	return Vector2(sid % width, sid / width)

func get_subtile_coord_from_id(autotile_id: int, sid: int):
	var width := int(autotile_get_size(autotile_id).x / tile_get_region(autotile_id).size.x)
	return get_subtile_coord_from_id(sid, width)

func get_subtile_id(autotile_id: int, v: Vector2) -> int:
	var size := autotile_get_size(autotile_id)
	var region := tile_get_region(autotile_id)
	return get_subtile_id_from_vector(v, int(region.size.x / size.x))

func get_subtile_id_from_vector(v: Vector2, width: int) -> int: return int(v.y) * width + int(v.x)

# Helper function for iterating over subtiles
# Return an array of dictionaries with subtile texture co-ords,
# and subtile bitmask
# n.b. I did not account for spacing, I leave that to you
# [{ coord = Vector2 , mask = int }]
func get_subtiles(autotile_id: int) -> Array:
	var return_values := []
	var size = autotile_get_size(autotile_id)
	var region = tile_get_region(autotile_id)
	var end_x = region.size.x / size.x
	var end_y = region.size.y / size.y

	for y in range(end_y):
		for x in range(end_x):
			var coord = Vector2(x,y)
			var mask = autotile_get_bitmask(autotile_id, coord)
			if mask != 0:
				return_values.push_back({
					"coord": coord,
					"mask": mask
				})
	return return_values

func slope_tile(id: int, bitmask: int, loc: Vector2, tilemap: TileMap, reverse: bool = false):
	if bitmask & BIND_CENTER:
		tilemap.set_cellv(loc, id)
		return autotile_get_icon_coordinate(id)
	
	

#func _slope_tile(id: int, loc: Vector2, bitmask: int, options: Dictionary):
#	var tilemap := options.tilemap as TileMap
#
#	if bitmask & BIND_CENTER:
#		tilemap.set_cellv(loc, id)
#		return autotile_get_icon_coordinate(id)
#
#	var neighbor_tiles := get_adjacent_tiles(loc, options.tilemap)
#	var direction : int = options.dir_horz
#
#	if bitmask & (options.bind_horz as int):
#		if (neighbor_tiles[direction].id as int) == id:
#			var e := Expression.new()
#			if e.parse(options.test, ['sid']):
#				printerr(e.get_error_text())
#				return
#			var coord : Vector2 = neighbor_tiles[direction].autotile_coord
#			var sid := get_subtile_id(id, coord)
#			var new_tile_id := id
#			if (e.execute([sid]) as bool):
#				sid += 1
#				coord = get_subtile_coord_from_id(id, sid)
#			else:
#				coord = FILL_TILE
#				new_tile_id = FOREGROUND
#			tilemap.set_cellv(loc, new_tile_id)
#			return coord
#
#	if bitmask & (options.bind_vert as int):
#		pass
