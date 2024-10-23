extends Node2D

@export var pushForce = 80  # Lowered the force
@export var bodyPath: NodePath = ".."
@onready var body: CharacterBody2D = get_node(bodyPath)



func _physics_process(delta):
	for i in body.get_slide_collision_count():
		var c = body.get_slide_collision(i)
		if c.get_collider() is RigidBody2D:
			c.get_collider().apply_central_impulse(-c.get_normal() * pushForce)
