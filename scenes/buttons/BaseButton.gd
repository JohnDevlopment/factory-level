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
const SPRITE_ANIMATION := "default"

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

func set_toggled(flag: bool) -> void:
	toggled = flag
	set_process(true)
	emit_signal('toggle_status_changed', flag)

func _process(_delta: float) -> void:
	if Engine.editor_hint:
		var sprite2 = $Frames
		var frame := 0
		if toggled:
			frame = sprite2.frames.get_frame_count(SPRITE_ANIMATION)
		sprite2.frame = frame
	else:
		# Play the sprite animation either forwards or backwards, then animation the hitbox
		sprite.play(SPRITE_ANIMATION, !toggled)
		var anim_speed : float = 1 if toggled else -1
		animation_player.play(HITBOX_ANIMATION, -1, anim_speed, !toggled)
	set_process(false)

func _ready() -> void:
	set_physics_process(false)
	if Engine.editor_hint: return
	#Game.connect('changed_game_param', self, '_on_game_param_changed')

#func _on_game_param_changed(param: String, _value):
#	match param:
#		'tree_paused':
#			pass

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
#		else:
#			if not sticky and toggled: set_toggled(false)

func _on_DetectPlayer_body_entered(body: Node) -> void:
	set_physics_process(true)
	_player = body as Actor

func _on_DetectPlayer_body_exited(_body: Node) -> void:
	set_physics_process(false)
	if not sticky and toggled:
		set_toggled(false)
