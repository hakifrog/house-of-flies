extends Label

signal game_end

@onready var flies = $"../../Flies"

var flies_total = 0
var flies_killed = 0

func _ready():
	flies_total = flies.get_child_count()
	text = str(flies_killed, "/", flies_total)

func _on_fly_killed():
	flies_killed += 1
	text = str(flies_killed, "/", flies_total)
	if flies_killed == flies_total:
		game_end.emit()
