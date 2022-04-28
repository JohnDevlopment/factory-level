## Powered door base class
# @name PoweredDoorBase
extends StaticBody2D

signal state_changed(open)

enum TimeFactor {
	VERY_SLOW = 175,
	SLOW = 150,
	NORMAL = 100,
	FAST1 = 75,
	FAST2 = 50,
	VERY_FAST = 25
}

## Whether door is open or not.
# @type bool
export var open := false

## Height of the door in tiles.
# @type int
# @setter set_height(height)
export var height := 1 setget set_height

## Speed of the door closing and opening.
# @type int
# @desc May be one of the constants of the @constant TimeFactor enum.
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

## Animate the door opening or closing.
# @desc Starts an opening or closing animation for the door. @a anim may
#       be either "down" or "up", denoting which direction to move the door.
#       Returns instantly if the door is already animating or the same animation
#       was played last.
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
	emit_signal('state_changed', open)

func _flip_state() -> void:
	match _current_animation:
		'up':
			do_animation('down')
		'down':
			do_animation('up')
