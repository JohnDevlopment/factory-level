tool
extends Enemy

export(float, 0.1, 1000, 0.1) var detection_radius : float setget set_detection_radius
export(float, 0.1, 5, 0.1) var time_to_radius : float

enum {STATE_INVALID = -1, STATE_IDLE, STATE_CHARGE, STATE_MOVEBACK, STATE_COOLDOWN}

onready var states : StateMachine = $States

var distance_met := 0.0

func _ready() -> void:
	if Engine.editor_hint:
		set_process(false)
		set_physics_process(false)
		return
	
	set_meta('initial_position', global_position)
	
	#var charge_speed : float
	assert(detection_radius > 0.0)
	assert(time_to_radius > 0.0)
	#charge_speed = detection_radius / time_to_radius
	
	states.user_data = {
		frames = $Frames,
		initial_position = global_position,
		timer = $Timer,
		charge_speed = detection_radius / time_to_radius
	}
	
	states.change_state(STATE_IDLE)

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
	queue_free()

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

func _on_Timer_timeout() -> void:
	states.change_state(STATE_IDLE)

func _on_Hitbox_area_entered(area: Area2D) -> void:
	var other : Actor = area.get_parent()
	other.call(Globals.player_hurt_method, $Hitbox)
