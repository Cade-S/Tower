extends CharacterBody2D
const bulletpath = preload('res://projectile/bullet.tscn')
const shellpath = preload('res://projectile/shell.tscn')
var gunshot = preload('res://SoundFX/pewpew/gunshot.wav')
@export var GRAVITY = 600
@onready var turret_head = get_node("turret_head")
var target
var shot = false
@export var health = 10
var main_sm = LimboHSM
var player_detected = false
var direction = 1
var current_angle = 0
@onready var ray_cast = $turret_head/bullet_release/RayCast2D
var scan_speed = 0.3
@export var angle_range = 40
var timer = Timer.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initiate_state_machine()
	ray_cast.enabled = true
	
	if get_tree().has_group("player"):
		target = get_tree().get_nodes_in_group("player")[0]

	
	timer.wait_time = 0.1  # Set to 3 seconds
	timer.autostart = true  # Starts automatically when the scene loads
	timer.one_shot = false  # Makes the timer repeat after each timeout
	add_child(timer)
	#timer.timeout.connect(shoot)
	


func _process(delta: float) -> void:
	#turret_head.look_at(target.global_position)
	
	if !is_on_floor():
		velocity.y += GRAVITY * delta	
	move_and_slide()
	
	for i in self.get_slide_collision_count():
		var c = self.get_slide_collision(i)
		if c.get_collider().name == "Bullet":
			shot = true
			
	if shot:
		health -= 1
		shot = false
		print("HEALTH:", health)
	if health <= 0:
			queue_free()

func shoot():
	$gunshot.stream = gunshot
	$gunshot.play()
	
	#Instantiate new shell and bullet
	var shell = shellpath.instantiate()
	var bullet = bulletpath.instantiate()

	#Add them to scene
	get_parent().add_child(bullet)
	get_parent().add_child(shell)
	
	# Set a random initial rotation
	shell.rotation = randf() * TAU

	# Set position for both shell and bullet
	shell.position = turret_head.get_child(0).global_position
	bullet.position = turret_head.get_child(0).global_position

	# Set velocities for movement
	var direction = (target.global_position - bullet.position).normalized()
	var bullet_velocity = direction * bullet.get_node("Bullet").bullet_speed
	var shell_velocity = direction * shell.shell_speed

	# Apply velocity
	bullet.get_node("Bullet").linear_velocity = bullet_velocity
	shell.apply_force(shell_velocity, shell.position)
	
func initiate_state_machine():
	main_sm = LimboHSM.new()
	add_child(main_sm)	
	
	var SCAN_state = LimboState.new().named("SCAN").call_on_enter(SCAN_START).call_on_update(SCAN_UPDATE)
	var SHOOT_state = LimboState.new().named("SHOOT").call_on_enter(SHOOT_START).call_on_update(SHOOT_UPDATE)
	
	main_sm.initial_state = SCAN_state
	
	main_sm.add_child(SCAN_state)
	main_sm.add_child(SHOOT_state)
	
	main_sm.add_transition(SCAN_state, SHOOT_state, &"to_shoot")
	main_sm.add_transition(SHOOT_state, SCAN_state, &"to_scan")
	
	
	
	main_sm.initialize(self)
	main_sm.set_active(true)
	
	
func SCAN_START():
	turret_head.play("default")
	timer.timeout.disconnect(shoot)
func SCAN_UPDATE(delta: float):
	print("Direction:", direction)
	print("current angle:", current_angle)
	
	if abs(current_angle) > deg_to_rad(angle_range):
		direction *= -1
		turret_head.rotation = current_angle
	current_angle += direction * scan_speed * delta
	turret_head.rotation = current_angle
	
	if ray_cast.is_colliding():
		main_sm.dispatch(&"to_shoot")
		
func SHOOT_START():
	turret_head.play("firing")
	timer.timeout.connect(shoot)
func SHOOT_UPDATE(delta: float):
	if not ray_cast.is_colliding():
		main_sm.dispatch(&"to_scan")
	turret_head.look_at(target.position)
