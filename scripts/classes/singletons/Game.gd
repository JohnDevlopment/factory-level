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
	ENEMY = 0x08, ## Enemy foreground collision
	PLAYER_HITBOX = 0x10, ## Player hitbox
	PLAYER_HURTBOX = 0x20, ## Player hurtbox
	ENEMY_HITBOX = 0x40, ## Enemy hitbox
	ENEMY_HURTBOX = 0x80, ## Enemy hurtbox,
	NPC = 0x0100, ## NPC foreground collision
	NPC_DETECTION = 0x0200 ## NPC detection field
}

const TILE_SIZE := Vector2(16, 16)

#var level_size := Vector2(1020, 610) setget set_level_size
#var dialog_mode := false setget set_dialog_mode

## A number indicating the level entrance.
# @type int
# @getter get_level_entrance()
# @desc This value can be set like any other property, but when it is read, it resets
#       itself to its default value of -1.
var level_entrance := -1 setget ,get_level_entrance

func get_level_entrance() -> int:
	var temp = level_entrance
	level_entrance = -1
	return temp

## Fetch the player node.
# @desc Returns a reference to the player node. If the player is not in the
#       scene tree, @code null is returned and an error is emitted.
func get_player() -> Actor: return get_tree().get_nodes_in_group("player")[0]

## Change scenes.
# @desc Switch to the given @a scene. Emits the @code changed_game_param signal.
func go_to_scene(scene: String) -> void:
	get_tree().change_scene(scene)
	emit_signal('changed_game_param', 'changing_scene', scene)

## Returns true if the player is inside the scene tree.
func has_player() -> bool: return get_tree().has_group('player')

# Set or clear dialog mode.
# @desc Depending on whether @a enabled is true or false, this sets or disables
#       dialog mode. In dialog mode, affected nodes stop working and do not
#       accept input from the user, allowing dialog boxes to work without interruption.
#
#       Emits the @code changed_game_param signal.
#func set_dialog_mode(enabled: bool):
#	dialog_mode = enabled
#	emit_signal("changed_game_param", "dialog_mode", enabled)

# Set the size of the current level.
# @desc Sets the size of the level to @a size. The size of the level should be
#       in tiles; the value can be converted to pixels using the @constant TILE_SIZE constant.
#
#       Emits the @code change_game_param signal.
#func set_level_size(size: Vector2):
#	level_size = size
#	emit_signal('changed_game_param', 'level_size', level_size)

## Set the pause status of the scene tree.
# @desc Pauses the scene tree if @a paused is true or unpauses it otherwise.
#
#       Emits the @code changed_game_param signal.
func set_paused(paused: bool) -> void:
	get_tree().paused = paused
	emit_signal("changed_game_param", "tree_paused", paused)

func _ready() -> void:
	pause_mode = Node.PAUSE_MODE_PROCESS
