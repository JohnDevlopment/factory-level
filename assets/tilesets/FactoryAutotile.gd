tool
extends TileSet

#const BIND_ALL := 511

enum {
	FOREGROUND = 0,
	LEFT_FACING_LONG_SLOPE = 5,
	RIGHT_FACING_LONG_SLOPE = 6
}

const FILL_TILE := Vector2(9, 2)

const BINDS := {
	LEFT_FACING_LONG_SLOPE: [FOREGROUND],
	RIGHT_FACING_LONG_SLOPE: [FOREGROUND],
	FOREGROUND: [LEFT_FACING_LONG_SLOPE, RIGHT_FACING_LONG_SLOPE]
}

func _is_tile_bound(drawn_id: int, neighbor_id: int) -> bool:
	if drawn_id in BINDS:
		return neighbor_id in BINDS[drawn_id]
	return false

func _forward_subtile_selection(autotile_id: int, bitmask: int, tilemap: Object, tile_location: Vector2):
	var subtiles := get_subtiles(autotile_id)
	var tm := tilemap as TileMap
	match autotile_id:
		FOREGROUND:
			if bitmask & BIND_TOP:
				if tm.get_cellv(tile_location + Vector2.UP) in [LEFT_FACING_LONG_SLOPE, RIGHT_FACING_LONG_SLOPE]:
					# tile above is a slope
					tm.set_cellv(tile_location, autotile_id)
					return Vector2(9, 2)
		LEFT_FACING_LONG_SLOPE:
			if bitmask == BIND_CENTER:
				# icon tile when there are no adjacent tiles
				tm.set_cellv(tile_location, autotile_id)
				return autotile_get_icon_coordinate(autotile_id)
			
			var neighbor_tiles := get_adjacent_tiles(tile_location, tilemap)
			if bitmask & BIND_LEFT:
				# check that the tile to the left has the same ID
				if (neighbor_tiles[0].id as int) == autotile_id:
					#var coord := get_subtile_left(tm, autotile_id, tile_location)
					var coord : Vector2 = neighbor_tiles[0].autotile_coord
					var new_tile := autotile_id
					if coord.x <= 3.0:
						coord.x += 1.0
					else:
						coord = FILL_TILE
						new_tile = FOREGROUND
					
					tm.set_cellv(tile_location, new_tile)
					#coord.x = (coord.x + 1.0) if coord.x < 3.0 else 4.0
					return coord
			if bitmask & BIND_TOP:
				# check that the tile above has the same ID
				if (neighbor_tiles[1].id as int) == autotile_id:
					var new_tile_id := autotile_id
					var coord : Vector2 = neighbor_tiles[1].autotile_coord
					print("tile above autotile coordinate: ", coord)
					print("current tile location: ", tile_location)
					if coord.x == 0.0:
						coord.x = 3.0
					elif coord.x >= 2.0:
						new_tile_id = FOREGROUND
						coord = Vector2(9, 2)
					else:
						coord.x += 1
					#print("new coord: ", coord)
					tm.set_cellv(tile_location, new_tile_id)
					return coord
			# Fallback when all other conditions fail; use the icon texture
			tm.set_cellv(tile_location, autotile_id)
			return autotile_get_icon_coordinate(autotile_id)

# Returns the coordinate of the autotile subtile left of v.
# Returns a negative vector if the two tiles have different IDs.
func get_subtile_left(tm: TileMap, autotile_id: int, v: Vector2) -> Vector2:
	return _get_subtile_shifted(tm, autotile_id, v, Vector2.LEFT)

# Returns the coordinate of the autotile subtile right of v.
# Returns a negative vector if the two tiles have different IDs.
func get_subtile_right(tm: TileMap, autotile_id: int, v: Vector2) -> Vector2:
	return _get_subtile_shifted(tm, autotile_id, v, Vector2.RIGHT)

# Returns the coordinate of the autotile subtile left of v.
# Returns a negative vector if the two tiles have different IDs.
func get_subtile_up(tm: TileMap, autotile_id: int, v: Vector2) -> Vector2:
	return _get_subtile_shifted(tm, autotile_id, v, Vector2.UP)

func _get_subtile_shifted(tm: TileMap, autotile_id: int, v: Vector2, o: Vector2) -> Vector2:
	var tile_location := v + o
	if tm.get_cellv(tile_location) == autotile_id:
		return tm.get_cell_autotile_coord(tile_location.x, tile_location.y)
	return Vector2(-1, -1)

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
					"mask": mask,
					"width": end_x
				})
	return return_values
