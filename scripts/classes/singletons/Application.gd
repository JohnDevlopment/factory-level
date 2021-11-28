extends Node

func exit(code: int = 0, message: String = "") -> void:
	var error_info = ErrorInfo.new(code, message)
	_exit(error_info)

static func get_screen_size() -> Vector2:
	return Vector2(
		ProjectSettings.get_setting("display/window/size/width"),
		ProjectSettings.get_setting("display/window/size/height")
	)

static func print_fields(fields: Array) -> void:
	for i in fields:
		print(i.name, " = ", i.value)

func _exit(error_info: ErrorInfo) -> void:
	if error_info.code: error_info.print()
	get_tree().quit(error_info.code)

func _ready() -> void:
	pause_mode = Node.PAUSE_MODE_PROCESS
