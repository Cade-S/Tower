extends CharacterBody2D
const bulletpath = preload('res://projectile/bullet.tscn')
const shellpath = preload('res://projectile/shell.tscn')
const gunshot = preload('res://SoundFX/pewpew/gunshot.wav')
var engine_sound = preload("res://SoundFX/pewpew/turret_engine.ogg")

@export var GRAVITY = 600
@export var health = 10
@export var direction = 1
@export var angle_range = 40

@onready var turret_head = get_node("turret_head")
@onready var ray_cast = $turret_head/bullet_release/RayCast2D
@onready var point_light = $turret_head/PointLight2D

var target
var shot = false
var player_detected = false
var beeped = false
var current_angle = 0
var scan_speed = 0.3
var timer = Timer.new()
var safe = false

var main_sm = LimboHSM

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	engine_sound.loop = true
	$engine.stream = engine_sound
	$engine.play()

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
	point_light.enabled = false
	turret_head.play("default")
	timer.timeout.disconnect(shoot)
	safe = false

func SCAN_UPDATE(delta: float):
	if turret_head.get_frame() == 1:
		if beeped == false:
			beeped = true
			$single_beep.play()
		point_light.enabled = true
	else:
		beeped = false
		point_light.enabled = false
	
	if abs(current_angle) > deg_to_rad(angle_range):
		direction *= -1
		turret_head.rotation = current_angle
	current_angle += direction * scan_speed * delta
	turret_head.rotation = current_angle
	
	if ray_cast.is_colliding():
		main_sm.dispatch(&"to_shoot")
		
func SHOOT_START():
	turret_head.play("firing")
	$five_beeps.play()
	point_light.enabled = true
	print("Shoot started")

func SHOOT_UPDATE(delta: float):
	if !$five_beeps.is_playing():
		timer.timeout.connect(shoot)
		if safe == true:
			main_sm.dispatch(&"to_scan")
		
		## Smoothly transition the rotation to face the target
		var target_direction = (target.global_position - turret_head.global_position).normalized()
		var target_angle = target_direction.angle()

		## Smoothly interpolate the rotation with damping
		#var current_angle = turret_head.rotation
		#var angle_difference = wrapf(target_angle - current_angle, -PI, PI)
		#var smooth_factor = 1  # Adjust this factor for smoother transitions
		
		#turret_head.rotation += angle_difference * smooth_factor * delta
		
		# After smooth transition, use look_at to face the target
		turret_head.look_at(target.global_position)


func _on_safe_area_body_exited(body: Node2D) -> void:
	if body == target:
		print("Safe")
		safe = true
