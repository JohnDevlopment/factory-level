extends TileMap

var tile_funcs := {}
onready var default_tile_function := funcref(self, 'default_tile')

func check_actor_collision(delta: float, collision: KinematicCollision2D, actor: Actor) -> void:
	assert(collision.collider is TileMap)
	
	var tilemap := collision.collider as TileMap
	
	# Get tile position and number
	var tile_pos := tilemap.world_to_map(collision.position)
	var tile := tilemap.get_cellv(tile_pos)
	
	# Call tile function
	var tf : FuncRef = tile_funcs.get(tile, default_tile_function)
	tf.call_func(delta, tile_pos, actor, collision)

func default_tile(_dt: float, _tile: Vector2, _actor: Actor, _collision: KinematicCollision2D):
	pass

func init_tilemap(tiles: Dictionary) -> void:
	tile_funcs = tiles
