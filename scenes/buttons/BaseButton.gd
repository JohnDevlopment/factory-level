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

onready var sprite = $Frames
onready var animation_player = $AnimationPlayer

var _player : Actor
var _dot : float
var _commands := []
var _init := false

func set_toggled(flag: bool) -> void:
	toggled = flag
	_init = true
	set_process(true)
	emit_signal('toggle_status_changed', flag)

func _process(_delta: float) -> void:
	if Engine.editor_hint or not _init:
		if toggled:
			$Frames.play('Glow')
		else:
			$Frames.animation = SPRITE_ANIMATION
	else:
		# Play the sprite animation either forwards or backwards, then animate the hitbox
		sprite.play(SPRITE_ANIMATION, !toggled)
		var anim_speed : float = 1 if toggled else -1
		animation_player.play(HITBOX_ANIMATION, -1, anim_speed, !toggled)
	set_process(false)

func _ready() -> void:
	set_physics_process(false)
	if Engine.editor_hint: return
	for node in get_children():
		if node.has_method('do_command'):
			_commands.append(funcref(node, 'do_command'))
	$Frames.connect('animation_finished', self, '_on_Frames_animation_finished')
	$AnimationPlayer.connect('animation_finished', self, '_on_AnimationPlayer_animation_finished')

func _do_commands() -> void:
	for fr in _commands:
		(fr as FuncRef).call_func(toggled)

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_action_pressed('debug'):
			set_toggled(!toggled)

func _physics_process(_delta: float) -> void:
	if not toggled and _player.is_on_floor():
		var dir := global_position.direction_to(_player.call('get_bottom_edge'))
		_dot = dir.dot(Vector2.UP)
		if _dot >= 0.5:
			set_toggled(true)

func _on_DetectPlayer_body_entered(body: Node) -> void:
	set_physics_process(true)
	_player = body as Actor

func _on_DetectPlayer_body_exited(_body: Node) -> void:
	set_physics_process(false)
	if not sticky and toggled:
		set_toggled(false)

# Called when the hitbox animation finishes
func _on_AnimationPlayer_animation_finished(_anim_name: String):
	_do_commands()

# Called when the toggle animation finishes
func _on_Frames_animation_finished() -> void:
	if sprite.animation == SPRITE_ANIMATION:
		sprite.play('Glow')
		pass
