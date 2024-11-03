extends RigidBody2D

var shell_speed = 20
var shell_velocity = Vector2(0, 0)
var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	# Set a random initial rotation
	rotation = rng.randf_range(0, TAU)
	
	# Lock rotation initially
	lock_rotation = true

	# Connect to collision signal using Callable
	connect("body_entered", Callable(self, "_on_first_collision"))

func _on_first_collision(body):
	# Unlock rotation after the first collision
	lock_rotation = false
