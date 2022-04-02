extends Resource
class_name TilemapClobberData

#export(String, MULTILINE) var json_text := "" setget set_text,get_text
export var data := {}

#var _json_object
#
#func get_text() -> String: return json_text
#
#func set_text(t) -> void:
#	json_text = t
#	_json_object = JSON.parse(json_text)
#	if _json_object.error:
#		push_error("JSON parse failed: %s at line %d" % [_json_object.error_string, _json_object.error_line])
#		_json_object = null
#		return
#	_json_object = _json_object.result
#
#func get_object(): return _json_object
