## Math functions
# @name Math
# @singleton
extends Node

## Default epislon for several functions.
# @type float
const CMP_EPSILON := 0.001

## Returns @code true if two values are approximately equal to each other.
# @desc This is the same as GDScript's @function is_equal_approx(), but with the
#       caveat that one can set the epsilon.
static func is_almost_equal(a: float, b: float, epsilon: float = CMP_EPSILON) -> bool:
	if a == b: return true
	
	var tolerance := a * epsilon
	if tolerance < epsilon: tolerance = epsilon
	
	return abs(a - b) < tolerance

## Returns @code true if the value is approximately zero.
# @desc This function does the same thing as GDScript's @function is_zero_approx(), with
#       the additional argument controlling the epsilon.
static func is_almost_zero(a: float, epsilon: float = CMP_EPSILON) -> bool:
	return abs(a) < epsilon

## Returns @code true if the value is within a range
# @desc Returns @code true if @a value is within the range [ @a min_value,@a max_value ].
static func is_in_range(value: float, min_value: float, max_value: float) -> bool:
	return (value >= min_value) && (value <= max_value)
