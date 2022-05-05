## A manually-control cubic interpolator
# @desc Use this class if you want to interpolate a value
#       and you want to be able to advance the step manually.
extends Reference
class_name CubicInterpolator

var _initial_value
var _current_value
var _final_value
var _delta_value
var _type : int
var _elapsed : float
var _duration : float

## Indicate whether the interpolation is finished or not.
# @type bool
var finished : bool = true

## Returns the type of value being interpolated.
func get_type() -> int: return _type

## Returns the current value of the interpolation.
func get_value(): return _current_value

## Initialize an interpolation from one value to the other.
# @desc The interpolation lasts for @a duration seconds.
#       @a from and @a to must be of the same type or be a float and an integer.
#       (In the second case @a to is converted to the type of @a from).
func start_interpolation(from, to, duration: float) -> int:
	assert(duration > 0.0, "duration must be nonzero and positive")
	
	_type = typeof(from)
	
	# If both parameters are numbers but one is an integer, convert the second
	if _type == TYPE_INT and typeof(to) == TYPE_REAL:
		to = int(to)
	elif _type == TYPE_REAL and typeof(to) == TYPE_INT:
		to = float(to)
	else:
		# Arguments are incompatible types
		assert(_type == typeof(to), "parameters 1 and 2 are not the same type")
	
	# First parameter is invalid type
	# Assume second parameter is same type
	assert(_type in [TYPE_REAL, TYPE_INT, TYPE_VECTOR2], "invalid type %d" % _type)
	
	match _type:
		TYPE_REAL, TYPE_INT:
			_initial_value = float(from)
			_final_value = float(to)
		TYPE_VECTOR2:
			_initial_value = from
			_final_value = to
		_:
			push_error("invalid 'from' parmeter: type %d is invalid")
			return ERR_INVALID_PARAMETER
	
	_elapsed = 0
	_duration = duration
	_delta_value = _final_value - _initial_value
	_current_value = _initial_value
	
	finished = false
	
	return OK

## Call this function to advance the interpolation by one "step".
# @desc Pass in the delta value of whichever process you're doing it in.
#       If you don't have access to this value you can call
#       @function get_physics_process_delta_time or
#       @function get_process_delta_time to get this value.
#
#       When the interpolation is finished, @property finished will be set to true,
#       so be sure to check for that.
func step(delta: float):
	if finished:
		return _current_value
	
	var result
	
	_elapsed += delta
	if _elapsed > _duration:
		_elapsed = _duration
		_current_value = _final_value
		finished = true
		result = _current_value
	else:
		match _type:
			TYPE_INT, TYPE_REAL:
				_current_value = _ease_out(_elapsed, _initial_value, _delta_value, _duration)
				if _type == TYPE_INT:
					result = int(_current_value)
				else:
					result = _current_value
			TYPE_VECTOR2:
				var cv : Vector2 = _current_value
				var iv : Vector2 = _initial_value
				cv.x = _ease_out(_elapsed, iv.x, _delta_value.x, _duration)
				cv.y = _ease_out(_elapsed, iv.y, _delta_value.y, _duration)
				_current_value = cv
				result = _current_value
			_:
				push_error("invalid type")
	
	return result

func _to_string() -> String:
	return str(_current_value)

static func _ease_out(time: float, initial_value: float, delta_value: float, duration: float):
	time = time / duration - 1.0
	return delta_value * (pow(time, 3) + 1) + initial_value
