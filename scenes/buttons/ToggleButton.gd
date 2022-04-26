extends StaticBody2D

onready var main_animations = $MainAnimations

var _queued_animations := []
var _bodies := 0

signal toggled(flag)

func _update_animation_queue() -> void:
	assert(_queued_animations.size() > 0, "no queued animations")
	
	if main_animations.is_playing():
		yield(main_animations, 'animation_finished')
	
	var next_animation : Array = _queued_animations.pop_front()
	var animation : String = next_animation[0]
	var backwards : bool = next_animation[1]
	var metadata : Dictionary = next_animation[2]
	
	# Set the speed of the animation
	var speed : float = metadata.get('speed', 1.0)
	if speed < 0.0:
		backwards = true
	elif backwards:
		speed *= -1.0
	
	main_animations.play(animation, -1, speed, speed < 0.0)
	
	assert(metadata.has('toggled'), "meta entry 'toggled' required")
	main_animations.set_meta('toggled', metadata['toggled'])
	main_animations.set_meta('animation', animation)
	main_animations.set_meta('backwards', backwards)

func _on_Detection_body_entered(_body: Node) -> void:
	if not _bodies:
		_queue_animation('Toggle', false, {toggled = true, speed = 2.0})
	_bodies += 1

func _on_Detection_body_exited(_body: Node) -> void:
	_bodies -= 1
	if not _bodies:
		_queue_animation('Toggle', true, {toggled = false, speed = -2.0})

func _queue_animation(anim: String, backwards: bool, metadata := {}) -> void:
	if _queued_animations.empty():
		call_deferred('_update_animation_queue')
	_queued_animations.push_back([anim, backwards, metadata])

func _on_MainAnimations_animation_finished(_anim_name: String) -> void:
	var toggled : bool = main_animations.get_meta('toggled')
	emit_signal('toggled', toggled)
