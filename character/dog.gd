extends RigidBody2D

var target
var speed = 110  # Movement speed in pixels per second

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Find the target (e.g., player)
	if get_tree().has_group("player"):
		target = get_tree().get_nodes_in_group("player")[0]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if target:
		move_toward_target(delta)

# Function to move the object toward the target
func move_toward_target(delta: float) -> void:
	# Get the direction toward the target
	var distance = global_position.distance_to(target.global_position)
	

	
	if distance > 75:

		$AnimatedSprite2D.play("RUN")
		var direction = (target.global_position - global_position).normalized()

		# Only move horizontally (along the X-axis), leave Y-axis unaffected by movement
		var new_velocity = linear_velocity
		new_velocity.x = direction.x * speed

		# Set the velocity to move horizontally while gravity affects the Y-axis
		linear_velocity = new_velocity

		# Flip the sprite based on horizontal direction
		if direction.x < 0:
			$AnimatedSprite2D.flip_h = true  # Facing left
		elif direction.x > 0:
			$AnimatedSprite2D.flip_h = false  # Facing right
			
	else:
		$AnimatedSprite2D.play("IDLE_BLINK")
		# Stop movementda
		linear_velocity.x = 0
