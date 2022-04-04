## A data structure representing the stats of an actor.
# @desc Each and every stat listed is meant to apply to the owner
#       of the @class Stat.
extends Resource
class_name Stats

## The max health of the owner.
# @type int
# @desc Clamped to the range [1,500].
export(int, 1, 500) var max_health: int = 5

## The max mana (magic points) of the owner.
# @type int
# @desc Clamped to the range [1,500].
export(int, 0, 500) var max_mana: int = 0

## The attack power of the owner.
# @type int
# @desc Clamped to the range [1,100].
export(int, 1, 100) var attack: int = 1

## The defense power of the owner
# @type int
# @desc Clamped to the range [0,100].
export(int, 0, 100) var defense: int = 0

## The name of the owner.
# @type String
export var owner_name: = ""

## The current health of the owner.
# @type int
var health: int = 0

## The current mana of the owner.
# @type int
var mana: int = 0

## The central function for calculating damage.
# @desc The attacker's @a other_stats and this class'
#       stats are combined in a math calculation to determine
#       how much damage the owner should take.
#       The result of that calculation is returned.
func calculate_damage(other_stats: Stats) -> int:
	var result = max(0, other_stats.attack - defense)
	return int(result)

#func get_meta_or_default(name: String, default = null):
#	if has_meta(name):
#		return get_meta(name)
#	return default

## Initialize the stats of the @a owner.
# @desc This should be called either when the owner is ready or when it enters
#       scene tree. @a owner is, as implied, the actor that owns these stats.
func init_stats(owner: Object):
	health = max_health
	mana = max_mana
	set_meta("owner", owner)

func _to_string():
	if not owner_name.empty():
		return "[Stats for %s]" % owner_name
	return "[Stats:%d]" % get_instance_id()
