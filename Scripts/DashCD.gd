extends Label
@onready var timer = $"../../Player/Timer"

func _process(delta):
	if visible:
		text = str("Dash in: ", timer.time_left)

func _on_player_dashed():
	visible = true
	text = str("Dash in: ", timer.time_left)


func _on_timer_timeout():
	visible = false
