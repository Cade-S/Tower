extends RigidBody2D

@export var bullet_speed = 1000
var bullet_velocity = Vector2.ZERO
var particle = preload("res://projectile/test_particle.tscn")
var particle_instance = particle.instantiate()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Set the initial velocity based on the mouse position
	bullet_velocity = (get_global_mouse_position() - global_position).normalized() * bullet_speed
	linear_velocity = bullet_velocity
	self.contact_monitor = true
	self.max_contacts_reported = 1


	
	
	
	# Connect the body_entered signal
	self.connect("body_entered", Callable(self, "_on_body_entered"))



# Called every physics frame
func _physics_process(delta: float) -> void:
	if linear_velocity.length() > 0:
		
		# Update rotation to match current direction of linear_velocity
		rotation = linear_velocity.angle()
	else:
		queue_free()

func _on_body_entered(body):
	get_parent().get_node("ricochet").play()
	
	print("SHOT")
	particle_instance.position = self.global_position
	particle_instance.get_node("GPUParticles2D").emitting = true
	get_tree().current_scene.add_child(particle_instance)
	if body.is_in_group("player") or body.is_in_group("sam"):
		pass
		
	else:
		queue_free()

		self.visible = false
		#print("invisible")
		

		var timer = Timer.new()
		timer.one_shot = true
		timer.wait_time = 0.1
		add_child(timer)
		timer.connect("timeout", Callable(self, "_on_timeout"))
		timer.start()

func _on_timeout():
	queue_free()
