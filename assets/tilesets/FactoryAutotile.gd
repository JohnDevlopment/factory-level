## Factory tileset autotile engine
# @name FactoryAutotile
tool
extends TileSet

class MapperTile:
	var type : int
	var coord : Vector2
	var id : int
	
	func _init(_id: int, c := Vector2(-1, -1)) -> void:
		id = _id
		type = 0
		if c >= Vector2.ZERO:
			coord = c
			type = 1
	
	func _to_string() -> String:
		return "[TileMapper:id=%s,coord=%s]" % [id, coord]
	
	func get_autotile_coordinate() -> Vector2:
		return Vector2() if type else coord

# Tile IDs
enum {
	FOREGROUND              = 0,
	LEFT_FACING_SLOPE       = 5,
	LEFT_FACING_LONG_SLOPE  = 6,
	RIGHT_FACING_LONG_SLOPE = 7,
	RIGHT_FACING_SLOPE      = 8,
	SLOPE_FILL_TILE         = 9
}

# Autotiles that bind to each other
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
	match autotile_id:
		FOREGROUND:
			var factory_bind_range := range(5, 9)
			var tm := tilemap as TileMap
			if bitmask & BIND_TOP:
				if tm.get_cellv(tile_location + Vector2.UP) in factory_bind_range:
					# tile above is a slope
					tm.set_cellv(tile_location, autotile_id)
					return Vector2(9, 2)
		LEFT_FACING_LONG_SLOPE, LEFT_FACING_SLOPE:
			var fill_tile := MapperTile.new(SLOPE_FILL_TILE)
			var map := { 'horizontal': 1 }
			if autotile_id == LEFT_FACING_LONG_SLOPE:
				map['vertical'] = [3, 4, fill_tile, fill_tile, fill_tile]
			else:
				map['vertical'] = [2, fill_tile, fill_tile]
			
			var coord = slope_tile(autotile_id, bitmask, tile_location, tilemap, map)
			if coord is Vector2:
				return coord
			else:
				(tilemap as TileMap).set_cellv(tile_location, autotile_id)
				return autotile_get_icon_coordinate(autotile_id)

func create_expression(expression: String, binds: PoolStringArray) -> Expression:
	var e := Expression.new()
	var err := e.parse(expression, binds)
	if err:
		printerr(e.get_error_text())
	return e

## Returns an array of tiles that are adjacent to the one at the given cell.
# @desc Each element is a dictionary:
#
#       @list_begin unordered
#       @item cell <Vector2>
#       Location of the tile
#       @item id <int>
#       ID of the tile
#       @item size <Vector2>
#       Size of the region in tiles
#       @item tile_size <Vector2>
#       Size of each tile
#       @list_end
#
#       If tile is an autotile, these are added:
#
#       @list_begin unordered
#       @item autotile_coord <Vector2>
#       Coordinate of the subtile if ID is an autotile
#       @item autotile_end <int>
#       The ID of the last subtile
#       @list_end
#
#       Indices:
#
#       @list_begin unordered
#       @item 0 = left
#       @item 1 = up
#       @item 2 = right
#       @item 3 = down
#       @unordered
func get_adjacent_tiles(tile_location: Vector2, tilemap: TileMap) -> Array:
	var result := [
		Vector2.LEFT,
		Vector2.UP,
		Vector2.RIGHT,
		Vector2.DOWN
	]
	for _i in range(4):
		var cell : Vector2 = tile_location + result.pop_front()
		var id := tilemap.get_cellv(cell)
		var tile := { cell = cell, id = id }
		if id >= 0:
			var region := tile_get_region(id)
			var tile_size := autotile_get_size(id)
			tile['size'] = (region.size / tile_size) if region.size else Vector2.ZERO
			tile['tile_size'] = tile_size
			if tile_get_tile_mode(id) != SINGLE_TILE:
				# atlas or autotile
				tile['autotile_coord'] = tilemap.get_cell_autotile_coord(cell.x, cell.y)
				tile['autotile_end'] = get_subtile_id_from_vector(tile.size, tile_size.x)
		
		result.push_back(tile)
	return result

func get_subtile_coord(sid: int, width: int): return Vector2(sid % width, sid / width)

func get_subtile_coord_from_id(autotile_id: int, sid: int):
	var size := autotile_get_size(autotile_id)
	var region := tile_get_region(autotile_id)
	var width := int(region.size.x / size.x)
	return get_subtile_coord(sid, width)

func get_subtile_id(autotile_id: int, v: Vector2) -> int:
	var size := autotile_get_size(autotile_id)
	var region := tile_get_region(autotile_id)
	return get_subtile_id_from_vector(v, int(region.size.x / size.x))

func get_subtile_id_from_vector(v: Vector2, width: int) -> int: return int(v.y) * width + int(v.x)

## Helper function for iterating over subtiles.
# @desc Return an array of dictionaries with subtile texture co-ords,
#       and subtile bitmask.
#
#       Keys:
#
#       @list_begin unordered
#       @item coord
#       The coordinate of the autotile variation
#       @item mask
#       The tile's bitmask
#       @list_end
func get_subtiles(autotile_id: int) -> Array:
	var return_values := []
	var size = autotile_get_size(autotile_id)
	var region = tile_get_region(autotile_id)
	var end_x = region.size.x / size.x
	var end_y = region.size.y / size.y

	for y in range(end_y):
		for x in range(end_x):
			var coord := Vector2(x,y)
			var mask := autotile_get_bitmask(autotile_id, coord)
			if mask != 0:
				return_values.push_back({
					"coord": coord,
					"mask": mask
				})
	return return_values

func slope_tile(id: int, bitmask: int, loc: Vector2, tilemap: TileMap,
map: Dictionary, reverse: bool = false):
	var neighbor_tiles := get_adjacent_tiles(loc, tilemap)
	var bind : int
	var new_id := id
	var subtiles := get_subtiles(id)
	
	# validate map argument
	for e in ['horizontal', 'vertical']:
		if not e in map:
			printerr("'%s' key not found in 'map'" % e)
			return
	
	var diffs = {
		binds = [BIND_RIGHT if reverse else BIND_LEFT, BIND_TOP],
		dir = [TileDirection.RIGHT if reverse else TileDirection.LEFT, TileDirection.UP],
		map = PoolStringArray(['horizontal', 'vertical'])
	}
	
	for i in range(2):
		bind = diffs.binds[i]
		if bitmask & bind:
			# check tile to the left or right of us
			bind = diffs.dir[i]
			var tile = neighbor_tiles[bind]
			if not tile:
				printerr("'neighbor_tiles[%d]' tile is empty" % bind)
				return
			if tile.id == id:
				# from the same autotile
				var coord : Vector2 = tile.get('autotile_coord', Vector2(-1, -1))
				if coord.x < 0 or coord.y < 0:
					printerr("No autotile coordinate for tile %d" % tile.id)
					return
				var their_sid : int = get_subtile_id(id, coord)
				if true:
					var temp = _slope_offset_subtile(their_sid, map[diffs.map[i]])
					print(temp)
					if temp is MapperTile:
						new_id = temp.id
						coord = temp.get_autotile_coordinate()
					else:
						var our_sid : int = temp
						if our_sid < subtiles.size() and our_sid >= 0:
							coord = subtiles[our_sid].coord
						else:
							new_id = SLOPE_FILL_TILE
							coord = Vector2()
				tilemap.set_cellv(loc, new_id)
				return coord

func _slope_offset_subtile(their_sid: int, map):
	var result = -1
	if map is int:
		result = their_sid + map
	elif map is Dictionary or map is Array:
		if their_sid in map:
			result = map[their_sid]
	
	return result
