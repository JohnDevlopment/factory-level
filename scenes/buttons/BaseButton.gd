tool
extends Actor

const SPRITE_ANIMATION := "default"
const HITBOX_ANIMATION := "ToggledStatus"

export var toggled := false setget set_toggled

onready var sprite = $Frames
onready var animation_player = $AnimationPlayer

func set_toggled(flag: bool) -> void:
	toggled = flag
	set_process(true)

func _process(_delta: float) -> void:
	if Engine.editor_hint:
		var sprite2 = $Frames
		var frame := 0
		if toggled:
			frame = sprite2.frames.get_frame_count(SPRITE_ANIMATION)
		sprite2.frame = frame
	else:
		sprite.play(SPRITE_ANIMATION, !toggled)
		# Animate the hitbox
		var anim_speed : float = 1 if toggled else -1
		$AnimationPlayer.play(HITBOX_ANIMATION, -1, anim_speed, !toggled)
	set_process(false)

func _ready() -> void:
	if Engine.editor_hint: return

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_action_pressed('debug'):
			set_toggled(!toggled)
