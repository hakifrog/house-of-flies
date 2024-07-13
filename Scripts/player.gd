extends CharacterBody3D

signal dashed

@onready var pivot = $Pivot
@onready var animation_tree = $Pivot/AnimationTree

@onready var dash:AudioStreamPlayer3D = $Pivot/Sounds/Dash
@onready var jump:AudioStreamPlayer3D = $Pivot/Sounds/Jump
@onready var land = $Pivot/Sounds/Land

@onready var timer = $Timer

@export var camera_h: Node3D
@export var camera_v: Node3D

@export var speed = 20.0

@export var floor_acceleration = 15.0
@export var air_acceleration = 5.0
@export var air_speed_tax = 0.2
@export var fall_acceleration = 75.0

@export var jump_strength_min = 3.0
@export var jump_strength_max = 15.0

@export var dash_strength = 20.0
@export var dash_velocity_treshold = 45.0


var target_velocity = Vector3.ZERO
var jump_strength = jump_strength_min

var aim_mode:bool = false
var can_dash:bool = true

var is_on_floor_prev:bool = false

var state_machine

func _ready():
	state_machine = animation_tree["parameters/playback"]

func _physics_process(delta):
	var just_landed:bool = false
	
	# movement direction
	var move_direction = Vector3.ZERO
	var camera_direction = -camera_v.transform.basis.z
	var dash_direction = move_direction
	
	aim_mode = Input.is_action_pressed("aim")
	move_direction.z = Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")
	move_direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	# rotate mdirection horizontally
	move_direction = move_direction.rotated(Vector3.UP, camera_h.rotation.y)
	camera_direction = camera_direction.rotated(Vector3.UP, camera_h.rotation.y)
		
	if move_direction != Vector3.ZERO:
		move_direction = move_direction.normalized()
		camera_direction.normalized()
		# player model rotation towards movement direction
		pivot.basis = Basis(Quaternion(pivot.basis).slerp(Quaternion(Basis.looking_at(move_direction)), 0.3))
	
	# dash to where the camera is facing if dash mode is active
	if aim_mode:
		Engine.time_scale = 0.1
		dash_direction = camera_direction
	else:
		Engine.time_scale = 1
		dash_direction = move_direction
	
	# dash implementation
	if !is_on_floor() && Input.is_action_just_pressed("jump") && can_dash:
		dashed.emit()
		can_dash = false
		timer.start()
		target_velocity = dash_direction * dash_strength
		dash.play()
	
	if is_on_floor() && Input.is_action_pressed("jump"):
		move_direction = Vector3.ZERO
		jump_strength = clamp(jump_strength + 1, jump_strength_min, jump_strength_max)
		animation_tree.set("parameters/conditions/jump", true)
		jump.play()
		
	if is_on_floor() && Input.is_action_just_released("jump"):
		target_velocity.y = jump_strength
		target_velocity.x = move_direction.x * speed
		target_velocity.z = move_direction.z * speed
		jump_strength = jump_strength_min
		animation_tree.set("parameters/conditions/jump", false)
	
	# attacking logic
	if Input.is_action_just_pressed("attack"):
		state_machine.travel("AttackBlend")
	
		# calculating running velocity
	if is_on_floor():
		target_velocity.x = lerpf(target_velocity.x, move_direction.x * speed, floor_acceleration * delta)
		target_velocity.z = lerpf(target_velocity.z, move_direction.z * speed, floor_acceleration * delta)
		if !is_on_floor_prev:
			just_landed = true
		else:
			just_landed = false
		is_on_floor_prev = true
	
	# calculating air velocity
	if !is_on_floor():
		target_velocity.x = target_velocity.x + (move_direction.x * air_speed_tax) - (air_acceleration * delta)
		target_velocity.z = target_velocity.z + (move_direction.z * air_speed_tax) - (air_acceleration * delta)
		
		# gravity and stuff
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)
		if aim_mode:
			pivot.basis = Basis(Quaternion(pivot.basis).slerp(Quaternion(Basis.looking_at(camera_direction)), 0.3))
		
		just_landed = false
		is_on_floor_prev = false
	
	if is_on_ceiling():
		target_velocity.y = 0
	
	if just_landed:
		land.play()
	
	var is_guy_dashing = target_velocity.length() > dash_velocity_treshold
	
	animation_tree.set("parameters/conditions/idle", move_direction == Vector3.ZERO && is_on_floor())
	animation_tree.set("parameters/conditions/run", move_direction != Vector3.ZERO && is_on_floor())
	animation_tree.set("parameters/conditions/fly", !is_on_floor() && !is_guy_dashing)
	animation_tree.set("parameters/conditions/dash", !is_on_floor() && is_guy_dashing)
	
	#character movement
	velocity = target_velocity
	move_and_slide()


func _on_timer_timeout():
	can_dash = true
