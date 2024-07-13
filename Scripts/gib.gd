extends RigidBody3D

@onready var bounce = $Bounce

@export var lifetime = 1.0
var elapsed_time = 0.0

func _process(delta):
	elapsed_time += delta
	if elapsed_time >= lifetime:
		queue_free()

func init_from_mesh(source:MeshInstance3D):
	global_transform = source.global_transform
	
	var mesh_instance = source.duplicate()
	mesh_instance.transform = Transform3D.IDENTITY
	add_child(mesh_instance)
	
	$CollisionShape3D.shape = source.mesh.create_convex_shape()

func _on_body_entered(body):
	bounce.play()
