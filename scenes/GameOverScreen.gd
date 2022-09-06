extends CanvasLayer

onready var animations: AnimationPlayer = $'%Animations'

var music_playing := false
var previous_scene := ''

func _ready() -> void:
	if not music_playing:
		yield(BackgroundMusic, 'finished')
		animations.play('Show Buttons')

func fade_in() -> void:
	assert(filename != "", "this node has no filename!")
	music_playing = true
	
	# Fade the screen in
	var tween := create_tween().set_ease(Tween.EASE_IN_OUT)\
	.set_trans(Tween.TRANS_SINE).set_pause_mode(SceneTreeTween.TWEEN_PAUSE_PROCESS)\
	.set_process_mode(Tween.TWEEN_PROCESS_IDLE)
	tween.connect('finished', self, '_on_fadein_finished')
	
	$Control.modulate.a = 0.0
	tween.tween_property($Control, 'modulate:a', 1.0, 3.0)#.set_delay(2.0)
	
	BackgroundMusic.play_music('gameover.ogg')

func _on_fadein_finished() -> void:
	SceneSwitcher.change_scene(filename, {
		previous_scene = previous_scene
	})
	queue_free()

func _on_ContinueButton_pressed() -> void:
	Game.set_paused(true)
	TransitionRect.fade_out()
	yield(TransitionRect, 'fade_finished')
	previous_scene = get_meta('previous_scene', 'unknown')
	assert(previous_scene != 'unknown')
	get_tree().change_scene(previous_scene)

func _on_QuitButton_pressed() -> void:
	Game.set_paused(true)
	TransitionRect.fade_out()
	yield(TransitionRect, 'fade_finished')
	get_tree().quit()
