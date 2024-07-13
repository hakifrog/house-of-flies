extends CharacterBody3D

signal killed

@onready var path_follow_3d = $Path3D/PathFollow3D
@onready var gibs_scene = $Path3D/PathFollow3D/Pivot/gibs
@onready var animation_tree = $Path3D/PathFollow3D/Pivot/AnimationTree
@onready var hitbox = $Path3D/PathFollow3D/Pivot/fly/Armature_002/Skeleton3D/BoneAttachment3D/Hitbox

@onready var squash = $Path3D/PathFollow3D/Pivot/Sounds/SQUASH
@onready var buzzing = $Path3D/PathFollow3D/Pivot/Sounds/BUZZING

@export var movement_speed:float = 6

@export_enum("fly_move", "fly_idle", "fly_fly", "none") var movement_type:String = "fly_move"

@export_flags_3d_physics var gib_collision_layer:int = 1
@export_flags_3d_physics var gib_collision_mask:int = 1
@export var explosion_speed = 4.0
@export var min_gib_lifetime = 1.2
@export var max_gib_lifetime = 1.8
@export var gib_amount:int = 5

func _ready():
	buzzing.play()
	if movement_type != "none":
		animation_tree.set(str("parameters/conditions/", movement_type), true)
	else:
		animation_tree.active = false

func _physics_process(delta):
	if movement_type != "fly_idle":
		path_follow_3d.progress += movement_speed * delta

func fucking_die():
	var parent = get_parent()
	var gibs = gibs_scene.get_children()
	
	for num in gib_amount:
		var child = gibs.pick_random()
		if child is MeshInstance3D:
			var gib = preload("res://Scenes/gib.tscn").instantiate()
			gib.init_from_mesh(child)
			parent.add_child(gib)
			
			var velocity:Vector3 = Vector3(randf_range(-1, 1), randf_range(0, 1), randf_range(-1, 1))
			gib.linear_velocity = velocity.normalized() * 4
			
			gib.lifetime = randf_range(min_gib_lifetime, max_gib_lifetime)

func _on_hitbox_area_entered(area):
	DebugDraw2D.set_text("fly hit")
	if area.is_in_group("weapon"):
		squash.play()
		hitbox.monitoring = false
		hide()
		killed.emit()
		fucking_die()


func _on_squash_finished():
	queue_free()


func _on_buzzing_finished():
	buzzing.play()

