extends StaticBody2D

enum TimeFactor {
	VERY_SLOW = 175,
	SLOW = 150,
	NORMAL = 100,
	FAST1 = 75,
	FAST2 = 50,
	VERY_FAST = 25
}

export var open := false
export var height := 1 setget set_height
export(TimeFactor) var time_factor : int = TimeFactor.NORMAL

var _pixel_height := 16
var _busy := false
var _current_animation := ''

func _ready() -> void:
	set_meta('initial_position', global_position)
	set_meta('z_index', z_index)
	
	if open:
		global_position.y -= _pixel_height
		z_index = -1
	
	_current_animation = 'up' if open else 'down'

func do_animation(anim: String):
	if _busy or anim == _current_animation: return
	
	var anima := Anima.begin(self)
	var dir := -1 if anim == 'up' else 1
	
	anima.then({
		node = self,
		property = 'y',
		from = 0,
		to = dir * _pixel_height,
		relative = true,
		duration = 1.7 * (float(time_factor) / 100),
		on_completed = [funcref(self, '_on_animation_completed'), [anim]]
	})
	
	anima.play()
	_busy = true
	z_index = -1
	_current_animation = anim

func set_height(h: int) -> void:
	height = h if h >= 1 else 1
	_pixel_height = h * 16

func _on_animation_completed(anim: String):
	open = anim == 'up'
	_busy = false
	if not open:
		z_index = get_meta('z_index')

func _flip_state() -> void:
	match _current_animation:
		'up':
			do_animation('down')
		'down':
			do_animation('up')
