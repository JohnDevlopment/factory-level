tool
extends TileSet

#const BIND_ALL := 511

enum {
	FOREGROUND = 0,
	LEFT_FACING_LONG_SLOPE = 5,
	RIGHT_FACING_LONG_SLOPE = 6
}

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
	#var subtiles := get_subtiles(autotile_id)
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
			if bitmask & BIND_LEFT:
				# check that the tile to the left has the same ID
				if tm.get_cellv(tile_location + Vector2.LEFT) == autotile_id:
					var coord := get_subtile_left(tm, autotile_id, tile_location)
					tm.set_cellv(tile_location, autotile_id)
					coord.x = (coord.x + 1.0) if coord.x < 3.0 else 4.0
					return coord
			if bitmask & BIND_TOP:
				# check that the tile above has the same ID
				if tm.get_cellv(tile_location + Vector2.UP) == autotile_id:
					var coord := get_subtile_up(tm, autotile_id, tile_location)
					tm.set_cellv(tile_location, autotile_id)
					return Vector2(3, 0) if coord.x == 0.0 else Vector2(4, 0)
			# Fallback when all other conditions fail; use the icon texture
			tm.set_cellv(tile_location, autotile_id)
			return autotile_get_icon_coordinate(autotile_id)
		RIGHT_FACING_LONG_SLOPE:
			if bitmask == BIND_CENTER:
				# icon tile when there are no adjacent tiles
				tm.set_cellv(tile_location, autotile_id)
				return autotile_get_icon_coordinate(autotile_id)
			if bitmask & BIND_RIGHT:
				# check that the tile to the right has the same ID
				if tm.get_cellv(tile_location + Vector2.RIGHT) == autotile_id:
					var coord := get_subtile_right(tm, autotile_id, tile_location)
					tm.set_cellv(tile_location, autotile_id)
					coord.x = (coord.x - 1.0) if coord.x >= 1.0 else 0.0
					return coord
			if bitmask & BIND_TOP:
				# check that the tile above has the same ID
				if tm.get_cellv(tile_location + Vector2.UP) == autotile_id:
					var coord := get_subtile_up(tm, autotile_id, tile_location)
					tm.set_cellv(tile_location, autotile_id)
					return Vector2(1, 0) if coord.x == 4.0 else Vector2()
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
