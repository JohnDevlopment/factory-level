extends Node

signal screenshot_taken()

export(float, 0.0, 1000.0, 0.1) var delay := 0.0

var output_file := ""

func _ready() -> void:
	if Game.has_player():
		Game.get_player().queue_free()
	
	# Start timer
	if delay > 0.0:
		var timer = get_tree().create_timer(delay)
		yield(timer, 'timeout')
	
	$CanvasLayer/FileDialog.popup_centered()
	Game.set_paused(true)

func _take_snapshot():
	var img : Image = get_viewport().get_texture().get_data()
	img.flip_y()
	img = _colorkey(Color("#4C4C4C"), img)
	
	var err := OK
	err = img.save_png(output_file)
	if err:
		push_error("Failed to write texture to '%s'" % output_file)
		return
	
	Game.set_paused(false)
	
	emit_signal('screenshot_taken')

func _on_FileDialog_file_selected(path: String) -> void:
	output_file = path
	yield(get_tree().create_timer(1), 'timeout')
	call_deferred('_take_snapshot')

func _on_FileDialog_popup_hide() -> void:
	Game.set_paused(false)

func _colorkey(key: Color, img: Image) -> Image:
	# Add alpha channel
	if img.detect_alpha() == img.ALPHA_NONE:
		img.convert(Image.FORMAT_RGBA8)
	
	# Set each pixel matching KEY as transparent
	var size := img.get_size()
	img.lock()
	for y in size.y:
		for x in size.x:
			if img.get_pixel(x, y) == key:
				img.set_pixel(x, y, Color(0, 0, 0, 0))
	img.unlock()
	
	# Crop the image 
	var used_rect := img.get_used_rect()
	if used_rect != Rect2(Vector2(), size):
		var temp := img
		return temp.get_rect(used_rect)
	
	return img
