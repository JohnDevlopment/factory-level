tool
extends Enemy

export(float, 0.1, 1000, 0.1) var detection_radius : float setget set_detection_radius
export(float, 0.1, 5, 0.1) var time_to_radius : float

enum {STATE_IDLE, STATE_CHARGE, STATE_MOVEBACK, STATE_COOLDOWN}

onready var states : StateMachine = $States
onready var frames = $Frames

var distance_met := 0.0

func _ready() -> void:
	if Engine.editor_hint:
		set_process(false)
		set_physics_process(false)
		return
	
	set_meta('initial_position', global_position)
	
	assert(detection_radius > 0.0)
	assert(time_to_radius > 0.0)
	
	states.user_data = {
		frames = $Frames,
		delay = 0.5,
		initial_position = global_position,
		timer = $Timer,
		charge_speed = detection_radius / time_to_radius,
		hitbox = $Hitbox,
		beep = $BeepSound
	}
	
	$Hitbox.disabled = true
	states.change_state(STATE_IDLE)
	call_deferred('_face_player')

func _draw() -> void:
	if Engine.editor_hint:
		var draw_color : Color = ProjectSettings.get_setting('debug/shapes/collision/shape_color')
		draw_circle(Vector2(), detection_radius, draw_color)

func _physics_process(delta: float) -> void:
	var state_return = states.state_physics(delta)
	if state_return is int:
		states.change_state(state_return)
	
	move_actor()

func _on_damaged(_stats: Stats) -> void:
	hide()
	emit_defeated()
	yield(get_tree().create_timer(1.0), 'timeout')
	queue_free()

func _face_player() -> void:
	var dir := global_position.direction_to(Game.get_player().global_position)
	direction.x = sign(dir.x)
	frames.flip_h = direction.x > 0

func move_actor() -> void:
	velocity = move_and_slide(velocity, Vector2.UP)
	
	for i in get_slide_count():
		var slide := get_slide_collision(i)
		distance_met += abs(slide.travel.x)
		if slide.collider is Actor:
			var other : Actor = slide.collider
			if other.get_collision_layer_bit(Globals.CollisionLayers.OBJECTS):
				var normal : Vector2 = -(slide.normal)
				other.velocity = normal * (speed_cap * 2.0)

func set_detection_radius(r: float) -> void:
	detection_radius = r
	update()

# Hit the player
func _on_Hitbox_area_entered(area: Area2D) -> void:
	var other : Actor = area.get_parent()
	var launch_speed := Vector2(abs(velocity.x) * 2, 300)
	other.call(Globals.player_hurt_method, $Hitbox, launch_speed)
