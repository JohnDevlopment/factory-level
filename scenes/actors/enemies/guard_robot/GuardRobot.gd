tool
extends Enemy

export(float, 45.0, 1000, 0.1) var detection_radius := 45.0 setget set_detection_radius
export var face_right := false
export var spawn_key := false

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
	
	# Set direction
	direction.x = -1 if not face_right else 1
	frames.flip_h = direction.x > 0
	
	# Set detection area
	if detection_radius > 14.0:
		var detcoll : CollisionShape2D = $DetectionField/CollisionShape2D
		var shape := RectangleShape2D.new()
		shape.extents = Vector2(detection_radius/2, 14)
		detcoll.position.x = detection_radius / 2 * direction.x
		detcoll.shape = shape
	
	$Hitbox.disabled = true
	
	# Initialize the state machine
	states.user_data = {
		frames = $Frames,
		initial_position = global_position,
		cintp = CubicInterpolator.new(),
		charge_speed = speed_cap.x * direction.x,
		distance = detection_radius,
		hitbox = $Hitbox,
		beep = $BeepSound,
		detection_field = $DetectionField
	}
	states.change_state(STATE_IDLE)

func _draw() -> void:
	if Engine.editor_hint:
		var draw_color : Color = ProjectSettings.get_setting('debug/shapes/collision/shape_color')
		draw_rect(
			Rect2(-detection_radius, -13, detection_radius * 2, 28),
			draw_color
		)

func _physics_process(delta: float) -> void:
	var state_return = states.state_physics(delta)
	if state_return is int:
		states.change_state(state_return)
	
	move_actor()

func _do_commands() -> void:
	var cmds : CommandHandler
	
	for node in get_children():
		if node is CommandHandler:
			cmds = node
			break
	
	if is_instance_valid(cmds):
		cmds.do_commands()
		yield(cmds, 'finished')
	
	queue_free()

func _on_damaged(_stats: Stats) -> void:
	hide()
	enable_collision(false)
	Game.spawn_vfx(get_parent(), self, 'robot_explosion', global_position)
	call_deferred('_spawn_keycard_after_death')
	call_deferred('_do_commands')
	emit_defeated()

func move_actor() -> void:
	velocity = move_and_slide(velocity, Vector2.UP)
	
	for i in get_slide_count():
		var slide := get_slide_collision(i)
		distance_met += abs(slide.travel.x)
		if slide.collider is Actor:
			var other : Actor = slide.collider
			# FIXME: When we hit an energy ball, this actor stops dead in its tracks
			if other.get_collision_layer_bit(Game.CollisionLayerIndex.OBJECTS):
				var normal : Vector2 = -(slide.normal)
				other.velocity = normal * (speed_cap * 2.0)

func set_detection_radius(r: float) -> void:
	detection_radius = r
	update()

func _spawn_keycard_after_death() -> void:
	if spawn_key:
		var spawned = preload('res://scenes/actors/Keycard.tscn').instance()
		get_parent().add_child(spawned)
		spawned.global_position = global_position
		spawned.launch()

# Hit the player
func _on_Hitbox_area_entered(area: Area2D) -> void:
	var other : Actor = area.get_parent()
	var launch_speed := Vector2(abs(velocity.x) * 2, 300)
	other.call(Game.PLAYER_HURT_METHOD, $Hitbox, launch_speed)

# When the player enters the detection field
func _on_DetectionField_body_entered(body: Node) -> void:
	states.state_call('player_detected', [body])

# When the player exits the detection field or it is disabled
func _on_DetectionField_body_exited(body: Node) -> void:
	states.state_call('player_exited', [body])
