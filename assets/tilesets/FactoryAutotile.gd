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
	FOREGROUND: [LEFT_FACING_SLOPE]
}

enum TileDirection {LEFT, UP, RIGHT, DOWN}

func _is_tile_bound(drawn_id: int, neighbor_id: int) -> bool:
	if drawn_id in BINDS:
		return neighbor_id in BINDS[drawn_id]
	return false

func _forward_subtile_selection(autotile_id: int, bitmask: int, tilemap: Object, tile_location: Vector2):
	match autotile_id:
		LEFT_FACING_SLOPE:
			var tm := tilemap as TileMap
			var coord := tm.get_cell_autotile_coord(tile_location.x, tile_location.y)
			
			var neighbors = get_adjacent_tiles(tile_location, tilemap)
			if bitmask & BIND_LEFT:
				var left_tile = neighbors[TileDirection.LEFT]
				var left_sid := get_subtile_id(left_tile.id, left_tile.autotile_coord)
				if left_sid == 0:
					coord = Vector2(1, 0)
				elif left_sid == 1:
					coord = Vector2(0, 2)
			elif bitmask & BIND_BOTTOM:
				var bottom_tile = neighbors[TileDirection.DOWN]
				var bottom_sid := get_subtile_id(bottom_tile.id, bottom_tile.autotile_coord)
				if bottom_sid == 10:
					coord = Vector2.ZERO
			
			return coord
		FOREGROUND:
			var neighbors = get_adjacent_tiles(tile_location, tilemap)
			if bitmask & BIND_TOP:
				var top_tile = neighbors[TileDirection.UP]
				
				if not (top_tile.id in BINDS[FOREGROUND]): return
				
				var top_sid := get_subtile_id(top_tile.id, top_tile.autotile_coord)
				if top_sid == 0:
					(tilemap as TileMap).set_cellv(tile_location, LEFT_FACING_SLOPE)
					return get_subtile_coord_from_id(LEFT_FACING_SLOPE, 2)

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
#       @item `0
#       left
#       @item 1
#       up
#       @item 2
#       right
#       @item 3
#       down
#       @list_end
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

## Returns the coordinate of the subtile @a sid.
# @desc In order to work, this method needs the @a width of the autotile.
func get_subtile_coord(sid: int, width: int) -> Vector2:
	return Vector2(sid % width, sid / width)

## Returns the coordinate of the subtile @a sid of tile @a id.
func get_subtile_coord_from_id(id: int, sid: int) -> Vector2:
	var size := autotile_get_size(id)
	var region := tile_get_region(id)
	var width := int(region.size.x / size.x)
	return get_subtile_coord(sid, width)

## Returns the id of a subtile.
# @desc @a id is an autotile or tile atlas and @a v is the subtile coordinate.
func get_subtile_id(id: int, v: Vector2) -> int:
	var size := autotile_get_size(id)
	var region := tile_get_region(id)
	return get_subtile_id_from_vector(v, int(region.size.x / size.x))

## Converts a vector coordinate into a subtile id.
# @desc In order for this method to work, it needs the @a width of the autotile.
func get_subtile_id_from_vector(v: Vector2, width: int) -> int:
	return int(v.y) * width + int(v.x)

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

func _slope_offset_subtile(their_sid: int, map):
	var result = -1
	if map is int:
		result = their_sid + map
	elif map is Dictionary or map is Array:
		if their_sid in map:
			result = map[their_sid]
	
	return result

func _print_bitmask(bitmask: int) -> void:
	print("top: %s, right: %s, bottom: %s, left: %s"
		% [ bool(bitmask & BIND_TOP), bool(bitmask & BIND_RIGHT),
		bool(bitmask & BIND_BOTTOM), bool(bitmask & BIND_LEFT) ])

func _check_bitmask(value: int, mask: int, ignore: int) -> bool:
	return (value & (~ignore)) == mask
