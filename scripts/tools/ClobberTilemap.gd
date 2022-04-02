tool
extends TileMap

export var skip := false
export(Resource) var clobber_data : Resource
export(Script) var sprite_script

const DEBUG := false

var _tileset_tile_by_id := []

func _ready() -> void:
	if Engine.editor_hint:
		editor_description = \
		"""Data property accepts the following keys:
	uv = uv coordinate of the tile
	width = width of the (auto)tile or tile atlas (in tiles)
		"""
		return
	if _save_tiles_to_dict():
		call_deferred('_create_sprite_from_tilemap')

func _save_tiles_to_dict() -> bool:
	if skip: return false
	if not is_instance_valid(tile_set):
		push_error("There is no tileset")
		return false
	
	if not is_instance_valid(clobber_data):
		push_error("No 'clobber_data' defined")
		return false
	
	for id in tile_set.get_tiles_ids():
		if not _save_tile_information(tile_set, id):
			return false
	return true

func _save_tile_information(ts: TileSet, id: int) -> bool:
	if ts.tile_get_tile_mode(id) == TileSet.SINGLE_TILE:
		pass
	else:
		# Tile atlas or autotile
		var used_cells := get_used_cells_by_id(id)
		if not used_cells.empty() and id in clobber_data.data:
			var curtile := { texture = ts.tile_get_texture(id), id = id }
			var data : Dictionary = clobber_data.data
			# This subtile is used, save it
			var autotile := {
				size = ts.autotile_get_size(id),
				uv_offset = data[id].uv,
				subtiles = {},
				id = id
			}

			for cell in used_cells:
				var subtile_coord := get_cell_autotile_coord(cell.x, cell.y)
				_add_subtile(id, autotile.subtiles, subtile_coord, cell)

			curtile['autotile'] = autotile
			_tileset_tile_by_id.append(curtile)
			if DEBUG:
				print("curtile = %s" % curtile)

	return true

func _add_subtile(id, d: Dictionary, coord: Vector2, cell: Vector2):
	var subtile_id := _subtile_id_from_coord(id, coord)
	assert(subtile_id >= 0, "invalid autotile %d" % id)
	if not subtile_id in d:
		d[subtile_id] = []
	(d[subtile_id] as Array).push_back(cell)
	if DEBUG:
		print("add tile %d:%d to %s" % [id, subtile_id, cell])

func _subtile_id_from_coord(id: int, coord: Vector2) -> int:
	var subtile_id := -1
	var data = clobber_data.data
	if id in data:
		var w := float(data[id].width)
		subtile_id = int(w * coord.y + coord.x)
	return subtile_id

func _subtile_coord_from_id(id: int, sid: int) -> Vector2:
	var coord := Vector2()
	var data = clobber_data.data
	if id in data:
		var w := float(data[id].width)
		coord.y = int(sid / w)
		coord.x = sid % int(w)
	return coord

func _create_sprite_from_tilemap():
	# create image to blit the tiles onto
	var img_rect : Rect2
	var img := Image.new()
	if true:
		img_rect = get_used_rect()
		img_rect.size = img_rect.size * cell_size
		img_rect.position = img_rect.position * cell_size
		if DEBUG:
			print("Image rect = %s" % img_rect)
		img.create(img_rect.size.x, img_rect.size.y, false, Image.FORMAT_RGBA8)

	for tile in _tileset_tile_by_id:
		var src_img : Image = (tile.texture as Texture).get_data()
		if DEBUG:
			print("source tilemap texture size is ", src_img.get_size())

		if 'autotile' in tile:
			# Is an autotile or a tile atlas
			var autotile = tile.autotile
			for subtile in autotile.subtiles:
				var src_rect := Rect2(
					autotile.uv_offset + _subtile_coord_from_id(tile.id, subtile) * autotile.size,
					autotile.size
				)

				for cell in autotile.subtiles[subtile]:
					var tile_offset := map_to_world(cell)
					tile_offset -= img_rect.position
					img.blit_rect(src_img, src_rect, tile_offset)

	if true:
		# add newly created image texture to sprite
		var img_tex := ImageTexture.new()
		img_tex.create_from_image(img, 0)

		var spr := Sprite.new()
		spr.texture = img_tex
		spr.centered = false
		spr.name = name
		name = "DeletedTileMap%d" % get_instance_id()
		if sprite_script:
			spr.set_script(sprite_script)

		var parent := get_parent()
		parent.add_child(spr, true)
		parent.move_child(spr, get_index())
		spr.position = img_rect.position
		queue_free()
