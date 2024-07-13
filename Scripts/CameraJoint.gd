extends Node3D

@onready var vertical_axis = $VerticalAxis
@onready var spring_arm = $VerticalAxis/SpringArm3D
@onready var player = $".."

@export var camera_sensitivity = 0.5
@export var camera_zoom_step = 0.3

func _ready():
	spring_arm.add_excluded_object(player)

func _input(event):
	if event is InputEventMouseMotion:
		# horizontal rotation
		rotate_y(deg_to_rad(-event.relative.x * camera_sensitivity))
		# vertical rotation
		vertical_axis.rotate_x(deg_to_rad(-event.relative.y * camera_sensitivity))
		vertical_axis.rotation.x = clamp(vertical_axis.rotation.x, deg_to_rad(-90.0), deg_to_rad(45.0))

func _process(delta):
	if Input.is_action_just_released("zoom_in"):
		spring_arm.spring_length -= camera_zoom_step
	if Input.is_action_just_released("zoom_out"):
		spring_arm.spring_length += camera_zoom_step
	spring_arm.spring_length = clamp(spring_arm.spring_length, 1.0, 10.0)


