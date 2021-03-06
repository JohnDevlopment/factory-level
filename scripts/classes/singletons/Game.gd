## Game-wide functions and values.
# @name Game
# @singleton
tool
extends Node

## Indicates that a game parameter has changed.
# @arg String  param The parameter that was changed.
# @arg Variant value The value @a param was changed to.
# @desc This signal is emitted when certain functions are called. Which function
#       was called is indicated by @a param.
#
#       Param: dialog_mode@br
#       Type:  bool@br
#       Emitted when @function set_dialog_mode() is called. If true, then
#       dialog mode is active: in this mode, a dialog is in process, so actors
#       should not move or accept input.
#
#       Param: tree_paused@br
#       Type:  bool@br
#       Emitted when @function set_paused() is called.
#
#       Param: level_size@br
#       Type:  Vector2@br
#       Emitted when the level size is set with @function set_level_size().
#
#       Param: changing_scene@br
#       Type:  String@br
#       Emitted when the when @function go_to_scene() is called. Can be used to
#       evaluate code when the scene is about to change.
signal changed_game_param(param, value)

## Collision layer bits
enum CollisionLayer {
	WALLS = 0x01, ## Walls
	PLATFORMS = 0x02, ## Platforms
	PLAYER = 0x04, ## Player foreground collision
	OBJECTS = 0x08, ## Objects
	ENEMIES = 0x10, ## Enemy foreground collision
	PLAYER_HITBOX = 0x20, ## Player hitbox
	PLAYER_HURTBOX = 0x40, ## Player hurtbox
	ENEMY_HITBOX = 0x80, ## Enemy hitbox
	ENEMY_HURTBOX = 0x100, ## Enemy hurtbox
	TRIGGERS = 0x200, ## Invisible triggers
	STAIRS = 0x400 ## Staircases
}

enum CollisionLayerIndex {
	WALLS = 0, ## Walls
	PLATFORMS = 1, ## Platforms
	PLAYER = 2, ## Player foreground collision
	OBJECTS = 3, ## Objects
	ENEMIES = 4, ## Enemy foreground collision
	PLAYER_HITBOX = 5, ## Player hitbox
	PLAYER_HURTBOX = 6, ## Player hurtbox
	ENEMY_HITBOX = 7, ## Enemy hitbox
	ENEMY_HURTBOX = 8, ## Enemy hurtbox
	TRIGGERS = 9, ## Invisible triggers
	STAIRS = 10 ## Staircases
}

const TILE_SIZE := Vector2(16, 16)

const PLAYER_HURT_METHOD := 'hurt'

const VFX_PATHS := {
	robot_explosion = 'res://scenes/vfx/RobotExplosion.tscn',
	armor_break = 'res://scenes/vfx/SwitchRobotArmorBreak.tscn'
}

const DIVISIONS := 12

#var level_size := Vector2(1020, 610) setget set_level_size
#var dialog_mode := false setget set_dialog_mode

var keycards := 0

## A number indicating the level entrance.
# @type int
# @getter get_level_entrance()
# @desc This value can be set like any other property, but when it is read, it resets
#       itself to its default value of -1.
var level_entrance := -1 setget ,get_level_entrance

## The size of the screen (initialized on game load).
# @type Vector2
var screen_size := Vector2()

var _baked_normals : PoolVector2Array

func get_level_entrance() -> int:
	var temp = level_entrance
	level_entrance = -1
	return temp

## Returns the metadata entry for @a meta or a default value.
# @desc If the metadata entry @a meta is not defined, @a default becomes
#       the new value for said entry and is returned.
func get_meta_default(meta: String, default = null):
	if not has_meta(meta):
		set_meta(meta, default)
	return get_meta(meta)

func get_nearest_collision_normal(n: Vector2) -> Vector2:
	var nearest = 0
	var dot = 0.0
	
	for i in _baked_normals.size():
		var origin := _baked_normals[i]
		var d = n.dot(origin)
		if d > dot:
			dot = d
			nearest = i
	
	return _baked_normals[nearest]

## Fetch the player node.
# @desc Returns a reference to the player node. If the player is not in the
#       scene tree, @code null is returned and an error is emitted.
func get_player() -> Actor: return get_tree().get_nodes_in_group("player")[0]

## Returns all cameras marked as player cameras.
# @desc All cameras belonging to the group @code player_camera are returned.
func get_player_cameras() -> Array: return get_tree().get_nodes_in_group('player_camera')

## Change scenes.
# @desc Switch to the given @a scene. Emits the @code changed_game_param signal.
func go_to_scene(scene: String) -> void:
	get_tree().change_scene(scene)
	emit_signal('changed_game_param', 'changing_scene', scene)

## Returns true if the player is inside the scene tree.
func has_player() -> bool: return get_tree().has_group('player')

## Set the pause status of the scene tree.
# @desc Pauses the scene tree if @a paused is true or unpauses it otherwise.
#
#       Emits the @code changed_game_param signal.
func set_paused(paused: bool) -> void:
	get_tree().paused = paused
	emit_signal("changed_game_param", "tree_paused", paused)

## Spawn the given @a vfx at the given position @a pos.
# @desc The instanced node is added to @a parent below the @a below_node.
#       If @a below_node is a valid reference to a @class Node, then
#       @function{add_child_below_node} is called, otherwise
#       @function{add_child} is called instead.
func spawn_vfx(parent: Node, below_node: Node, vfx: String, pos: Vector2):
	var node
	if VFX_PATHS.get(vfx) == null:
		push_error("No vfx by the name '%s' is defined" % vfx)
		return
	
	# Check that the path points to a scene
	node = load(VFX_PATHS[vfx])
	assert(node is PackedScene)
	
	# Instance the scene and place it at the specified position
	node = node.instance() as Node2D
	node.global_position = pos
	
	if is_instance_valid(below_node):
		parent.add_child_below_node(below_node, node)
	else:
		parent.add_child(node)
	
	return node

func _ready() -> void:
	pause_mode = Node.PAUSE_MODE_PROCESS
	screen_size = Vector2(
		ProjectSettings.get_setting('display/window/size/width'),
		ProjectSettings.get_setting('display/window/size/height')
	)
	
	var angle_increment : float = 6.28319 / float(DIVISIONS)
	for i in range(1, DIVISIONS+1):
		var x : float = angle_increment * i
		_baked_normals.push_back(Vector2.UP.rotated(x))
