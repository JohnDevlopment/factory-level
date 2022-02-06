## An enemy actor type
tool
extends Actor
class_name Enemy, "res://assets/textures/icons/Enemy.svg"

signal defeated

## The stats of the @class enemy
# @type Stats
var stats: Stats

## The amount of time the @class Enemy is invincible after taking damage
# @type float
var armor_time: float = 1.0

var invincibility_timer: Timer

var direction: = Vector2.LEFT

func _enter_tree():
	if Engine.editor_hint: return
	invincibility_timer = Timer.new()
	invincibility_timer.one_shot = true
	invincibility_timer.wait_time = armor_time
	add_child(invincibility_timer)

func _get(property):
	match property:
		"armor_time":
			return armor_time
		"stats":
			return stats

func _get_property_list():
	return [
		{
			name = "Enemy",
			type = TYPE_NIL,
			usage = PROPERTY_USAGE_CATEGORY | PROPERTY_USAGE_SCRIPT_VARIABLE
		},
		{
			name = "armor_time",
			type = TYPE_REAL,
			usage = PROPERTY_USAGE_DEFAULT,
			hint = PROPERTY_HINT_RANGE,
			hint_string = "0.1,10,0.1,or_greater"
		},
		{
			name = "stats",
			type = TYPE_OBJECT,
			usage = PROPERTY_USAGE_DEFAULT,
			hint = PROPERTY_HINT_RESOURCE_TYPE,
			hint_string = "Resource"
		}
	]

func _ready():
	if Engine.editor_hint:
		set_process(false)
		set_physics_process(false)
		return
	
	stats.init_stats(self)

func _set(property, value):
	match property:
		"armor_time":
			armor_time = value
		"stats":
			stats = value
		_:
			return false
	return true

## Called when the enemy is damaged for specific behavior.
# @virtual
# @desc    Called at the end of @function decide_damage(). Used to implement
#          custom behavior after the enemy has taken damage.
func _on_damaged(_stats: Stats) -> void: pass

## Returns true if the enemy should take damage.
# @virtual
# @desc    This function is called by @function should_damage(). It returns
#          true by default but can be overriden to customize its behavior.
#          Used for enemy-specific
func _should_damage() -> bool: return true

## Called to decide the amount of damage to take based on the attacker's stats.
# @desc This function should be called by another actor dealing damage to this one.
#       The values in @a other_stats are used in conjuction with @property stats to
#       decide whether the @class Enemy should take damage or not, and how much.
func decide_damage(other_stats: Stats) -> void:
	if not should_damage(): return
	var dmg = stats.calculate_damage(other_stats)
	stats.health = int(max(0, stats.health - dmg))
	call("_on_damaged", other_stats)

## Calculates the enemy's direction and distance to the player.
# @const
# @desc Returns a dictionary with the direction and distance to the player, or null
#       if the player does not exist inside the tree.
func direction_to_player():
	if Game.has_player():
		var player: Actor = Game.get_player()
		var distance := player.get_center() - get_center()
		return {distance = distance, direction = distance.normalized()}

func emit_defeated() -> void:
	emit_signal('defeated')

## Returns the current health of the enemy.
# @const
func get_health() -> int: return stats.health

## Returns a metadata value with a fallback value.
# @const
# @desc  Returns the object's metadata entry for the given @a name. If @a name
#        does not exist, then @a default is returned.
func get_meta_or_default(name: String, default = null):
	if has_meta(name):
		return get_meta(name)
	return default

## Returns true if the @class Enemy should take damage
# @virtual
# @return  True if the Enemt should take damage, false otherwise
# @note    This function is called by @function decide_damage; if this returns
#          true, the @class Enemy takes damage according to the Stats of the other Actor.
func should_damage() -> bool:
	var result: bool = invincibility_timer.is_stopped()
	result = result && call("_should_damage")
	return result
