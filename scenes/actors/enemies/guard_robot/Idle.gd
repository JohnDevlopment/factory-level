extends State

var _player

func _setup() -> void:
	user_data.frames.play('Idle')
	user_data.detection_field.disabled = false

func physics_main(_delta: float):
	if not _player: return
	var player : Actor = _player
	if player.is_on_floor():
		return persistant_state.STATE_CHARGE

func cleanup() -> void:
	_player = null
	user_data.detection_field.disabled = true

func player_detected(player: Actor):
	_player = player

func player_exited(_aplayer: Actor):
	_player = null
