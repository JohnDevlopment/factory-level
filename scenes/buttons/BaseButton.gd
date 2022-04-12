## A base for all interactable buttons
# @name BaseButton<scene>
tool
extends StaticBody2D

## The button's toggle status has been changed.
# @arg bool on  Whether or not the button is toggled
# @desc         Emitted whenever the toggled status of the button changes via
#               @function set_toggled().
signal toggle_status_changed(on)

## Name of the sprite animation
# @type String
const SPRITE_ANIMATION := "Press/Release"

## Name of the hitbox animation
# @type String
const HITBOX_ANIMATION := "ToggledStatus"

## Whether or not the button is toggled.
# @type   bool
# @setter set_toggled(flag)
export var toggled := false setget set_toggled

## If this option is set, the button will stay pressed.
# @type bool
export var sticky := true

## Vector to snap the button to
# @type Vector2
# @desc When moving the button within the editor, its position is snapped to this.
export var position_snap := Vector2(7, 7)

onready var sprite = $Frames
onready var animation_player = $AnimationPlayer

var _player : Actor
var _dot : float
var _init := false
var _lock := false

func set_toggled(flag: bool) -> void:
	toggled = flag
	_init = true
	_do_toggle_animation()
	set_meta('toggled', flag)

func _do_toggle_animation() -> void:
	if not _lock:
		_lock = true
		set_process(true)

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_READY:
			set_physics_process(false)
			if Engine.editor_hint:
				set_notify_transform(true)
				return
			$Frames.connect('animation_finished', self, '_on_Frames_animation_finished')
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
					$Frames.animation = 'Glow'
				else:
					$Frames.animation = SPRITE_ANIMATION
				_lock = false
			else:
				# Play the sprite animation either forwards or backwards, then animate the hitbox
				sprite.play(SPRITE_ANIMATION, !toggled)
				var anim_speed : float = 1 if toggled else -1
				animation_player.play(HITBOX_ANIMATION, -1, anim_speed, !toggled)
			set_process(false)
		NOTIFICATION_TRANSFORM_CHANGED:
			var s := global_position.snapped(position_snap)
			global_position = s

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_action_pressed('debug'):
			set_toggled(!toggled)

func _on_DetectPlayer_body_entered(body: Node) -> void:
	set_physics_process(true)
	_player = body as Actor

func _on_DetectPlayer_body_exited(_body: Node) -> void:
	set_physics_process(false)
	if not sticky and toggled:
		set_toggled(false)

# Called when the hitbox animation finishes
func _on_AnimationPlayer_animation_finished(_anim_name: String):
	_lock = false
	emit_signal('toggle_status_changed', get_meta('toggled'))

# Called when the toggle animation finishes
func _on_Frames_animation_finished() -> void:
	if sprite.animation == SPRITE_ANIMATION and toggled:
		sprite.play('Glow')
