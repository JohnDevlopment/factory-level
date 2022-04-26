## A base for all interactable buttons
# @name BaseButton<scene>
tool
extends StaticBody2D

## The button's toggle status has been changed.
# @arg bool on  Whether or not the button is toggled
# @desc         Emitted whenever the toggled status of the button changes via
#               @function set_toggled().
signal toggle_status_changed(on)

## Name of the hitbox animation
# @type String
const HITBOX_ANIMATION := "ToggledStatus"

## Whether or not the button is toggled.
# @type   bool
# @setter set_toggled(flag)
export var toggled := false setget set_toggled

## Vector to snap the button to
# @type Vector2
# @desc When moving the button within the editor, its position is snapped to this.
export var position_snap := Vector2(7, 7)

onready var animation_player = $AnimationPlayer

var _player : Actor
var _dot : float
var _init := false
var _lock := false

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_READY:
			set_physics_process(false)
			if Engine.editor_hint:
				set_notify_transform(true)
				return
			$AnimationPlayer.connect('animation_finished', self, '_on_AnimationPlayer_animation_finished')
		NOTIFICATION_PHYSICS_PROCESS:
			# don't detect collision during a lock
			if _lock: return
			if not toggled and _player.is_on_floor():
				var dir := global_position.direction_to(_player.call('get_bottom_edge'))
				_dot = dir.dot(Vector2.UP)
				if _dot >= 0.5:
					set_toggled(true)
		NOTIFICATION_PROCESS:
			if Engine.editor_hint or not _init:
				if toggled:
					$ButtonSprite.frame = 10
				else:
					$ButtonSprite.frame = 0
				_lock = false
			else:
				# Play the sprite animation either forwards or backwards, then animate the hitbox
				if toggled:
					animation_player.play('ToggledStatus')
				else:
					animation_player.play_backwards('ToggledStatus')
				var anim_speed : float = 1 if toggled else -1
				animation_player.play(HITBOX_ANIMATION, -1, anim_speed, !toggled)
			set_process(false)
		NOTIFICATION_TRANSFORM_CHANGED:
			var s := global_position.snapped(position_snap)
			global_position = s

func set_toggled(flag: bool) -> void:
	toggled = flag
	_do_toggle_animation()
	if not Engine.editor_hint:
		_init = true
		set_meta('toggled', flag)

func _do_toggle_animation() -> void:
	if not _lock:
		_lock = true
		set_process(true)

# Signals

func _on_DetectPlayer_body_entered(body: Node) -> void:
	set_physics_process(true)
	_player = body as Actor

func _on_DetectPlayer_body_exited(_body: Node) -> void:
	set_physics_process(false)

# Called when the hitbox animation finishes
func _on_AnimationPlayer_animation_finished(_anim_name: String):
	_lock = false
	emit_signal('toggle_status_changed', get_meta('toggled'))
