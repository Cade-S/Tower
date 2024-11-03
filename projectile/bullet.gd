extends RigidBody2D

@export var bullet_speed = 900
var bullet_velocity = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Set the initial velocity based on the mouse position
	bullet_velocity = (get_global_mouse_position() - global_position).normalized() * bullet_speed
	linear_velocity = bullet_velocity  # Directly set linear_velocity

# Called every physics frame
func _physics_process(delta: float) -> void:
	if linear_velocity.length() > 0:
		# Update rotation to match current direction of linear_velocity
		rotation = linear_velocity.angle()
		


func _on_body_entered(body: Node):
	print("PING")
	if body.is_in_group("player") or body.is_in_group("sam"):
		pass	 
	else:
		queue_free()
		
