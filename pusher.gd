extends Node2D
@export var pushForce = 80	
@export var bodyPath: NodePath = ".."
@onready var body: CharacterBody2D = get_node(bodyPath)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
		for i in body.get_slide_collision_count():
			var col = body.get_slide_collision(i)
			if col.get_collider() is RigidBody2D:
				col.get_collider().apply_central_impulse(-col.get_normal() * pushForce)
