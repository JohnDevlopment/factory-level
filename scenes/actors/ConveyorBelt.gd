tool
extends StaticBody2D

export var debug := false

enum Direction {LEFT = -1, RIGHT = 1}

enum Speed {
	VERY_SLOW = 10,
	SLOW = 20,
	NORMAL = 40,
	FAST = 60,
	VERY_FAST = 80
}

export(Direction) var direction : int = Direction.RIGHT setget set_direction

export(Speed) var movement_speed : int = Speed.NORMAL setget set_movement_speed

export(int, 3, 100) var width := 3 setget set_width

var _after_ready := false

func _draw() -> void:
	var i := width - 1
	var drawpos := Vector2()
	
	var tex_a : Texture
	var tex_b : Texture
	var tex_c : Texture
	
	if true:
		var reversed : bool = direction == Direction.RIGHT
		var animation_pattern := "conveyor_belt_{0}_animated"
		if reversed:
			animation_pattern += "_rev"
		
		# Get preloaded textures
		tex_a = $ResourcePreloader.get_resource(animation_pattern.format(['a']))
		tex_b = $ResourcePreloader.get_resource(animation_pattern.format(['b']))
		tex_c = $ResourcePreloader.get_resource(animation_pattern.format(['c']))
		
		# Use one of the frames in the editor
		if Engine.editor_hint:
			tex_a = (tex_a as AnimatedTexture).get_frame_texture(6 if reversed else 1)
			tex_b = (tex_b as AnimatedTexture).get_frame_texture(6 if reversed else 1)
			tex_c = (tex_c as AnimatedTexture).get_frame_texture(6 if reversed else 1)
	
	# Draw the first tile
	draw_texture(tex_a, drawpos)
	drawpos.x += 16.0
	i -= 1

	# Draw the middle tiles
	while i > 0:
		draw_texture(tex_b, drawpos)
		i -= 1
		drawpos.x += 16.0

	# Draw the last tile
	draw_texture(tex_c, drawpos)

func _ready() -> void:
	if not Engine.editor_hint:
		_update_conveyor_speed()
		if not debug:
			$CanvasLayer.queue_free()
		else:
			_setup_debug()
		_after_ready = true
		return
	connect('child_entered_tree', self, '_on_tree_child_entered')

func set_direction(dir: int) -> void:
	direction = dir
	if not Engine.editor_hint:
		_update_conveyor_speed()
		_setup_debug()
	update()

func set_movement_speed(speed: int) -> void:
	movement_speed = speed
	if not Engine.editor_hint:
		_update_conveyor_speed()
		_setup_debug()

func set_width(w: int) -> void:
	width = w
	update()

func _setup_debug() -> void:
	if debug:
		$CanvasLayer.visible = true
		$CanvasLayer/BoxContainer/ConstLinVelLabel.text = str("Conveyor X Velocity: ",
			constant_linear_velocity.x)

# This is not called in the editor, so don't worry about that
func _update_conveyor_speed() -> void:
	if not _after_ready:
		constant_linear_velocity.x = float(movement_speed * direction)
		return
	
	var anima := Anima.begin(self)
	anima.then({
		node = self,
		property = 'constant_linear_velocity:x',
		to = float(movement_speed * direction),
		duration = 0.4,
		easing = Anima.EASING.EASE_IN_CUBIC,
		on_completed = [funcref(self, '_setup_debug')]
	})
	
	anima.play()

func _on_tree_child_entered(node) -> void:
	if node is CollisionShape2D:
		if not is_instance_valid(node.shape):
			node.shape = RectangleShape2D.new()
			node.shape.extents = Vector2(float(width) * 16.0 / 2.0, 8.0)
			node.position = Vector2(float(width) * 16.0 / 2.0, 8.0)
