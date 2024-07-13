extends Node

@onready var main_theme = $Sound/MainTheme
@onready var flies = $Flies
@onready var flies_counter = $UI/FliesCounter
@onready var lose_ui = $UI/Lose
@onready var win_ui = $UI/Win
@onready var message = $UI/Win/Message
@onready var timer = $Sound/Timer2
@onready var timer_sound = $Sound/Timer
@onready var continue_game = $UI/continue

@onready var player = $Player

@export var mute_music:bool = false

var flies_total:int = 0
var paused = false

func _ready():
	continue_game.hide()
	
	timer_sound.play()
	timer.start()
	lose_ui.hide()
	win_ui.hide()
	
	if !mute_music:
		main_theme.play()
	
	for fly in flies.get_children():
		fly.killed.connect(flies_counter._on_fly_killed.bind())


func _physics_process(delta):
	if Input.is_action_just_released("RESTART"):
		get_tree().reload_current_scene()
	
	if Input.is_action_just_released("pause"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		continue_game.show()
		get_tree().paused = true

func _on_main_theme_finished():
	main_theme.play()

func _on_timer_finished():
	level_end(false)

func level_end(win:bool):
	player.queue_free()
	if !win:
		lose_ui.show()
	else:
		message.text = str("WELL DONE\nYOUR BEST TIME IS", 60 - int(timer.time_left), "\nSHARE YOUR RESULT IN THE COMMENTS\nPRESS L TO RESTART")
		win_ui.show()

func _on_flies_counter_game_end():
	level_end(true)

func _on_continue_pressed():
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	continue_game.hide()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
