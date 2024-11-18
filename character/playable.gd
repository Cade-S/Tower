extends CharacterBody2D

#region Init vars

var main_sm: LimboHSM
@export var GRAVITY = 600
@export var SPEED = 69.0
@export var SPRINT_SPEED = 120.0
@export var JUMP_VELOCITY = -250.0
@export var ACCELERATION = 350.0  # Adjust this to control how fast you pick up speed
@export var DECELERATION = 950.0  # Adjust this for how fast you slow down
@export var target_speed = 0.0

var mouse_direction
var direction
var backwards = false


var is_sprinting = false
var is_aiming = false
var jump
var land_finished = true
var ledge
var crouch 

const bulletpath = preload('res://projectile/bullet.tscn')
const shellpath = preload('res://projectile/shell.tscn')
var gunshot = preload('res://SoundFX/pewpew/gunshot.wav')
var reload = preload('res://SoundFX/pewpew/159406__jackjan__handgun-reload.mp3')
@export var shoot_cooldown = 0.5
@export var reload_time = 1.5
@onready var cooldown_timer = Timer.new()
@onready var reload_timer = Timer.new()
@export var clip_size = 8
var rounds_left = 8
var reloading = true
var try_to_shoot = false
var health = 100
var shot = false

@onready var body_animation = get_node("PlayerSprite/Body")
@onready var head = get_node("PlayerSprite/Body/Head")
@onready var front_arm = get_node("PlayerSprite/Body/Front_Arm")
@onready var back_arm = get_node("PlayerSprite/Body/Front_Arm")
#endregion

#--------------------------------------------------------------------------------------------------

#region ready()

func _ready():
	initiate_state_machine()
	cooldown_timer.wait_time = shoot_cooldown
	cooldown_timer.one_shot = true
	reload_timer.wait_time = reload_time
	reload_timer.one_shot = true
	add_child(cooldown_timer)
	add_child(reload_timer)
#endregion

#--------------------------------------------------------------------------------------------------

func _physics_process(delta: float) -> void:
	#print(main_sm.get_active_state().name)
	direction = Input.get_axis("move_left", "move_right")
	is_sprinting = Input.is_action_pressed("sprint")
	velocity.x = move_toward(velocity.x, direction * target_speed, ACCELERATION * delta)
	jump = Input.is_action_just_pressed("jump")
	crouch = Input.is_action_pressed("crouch")
	ledge = $WallCheck.is_colliding() and not $FloorCheck.is_colliding() and velocity.y == 0
	
	#reload
	if reload_timer.is_stopped() and reloading == true:
		rounds_left = clip_size
		reloading = false
		
			
			
	for i in self.get_slide_collision_count():
		var c = self.get_slide_collision(i)
		if c.get_collider().name == "Bullet":
			shot = true
		
	if shot:
		health -= 1
		shot = false
		print("HEALTH:", health)
	
	print(direction)
	if direction > 0:
		self.scale.x = 1
	elif direction < 0:
		self.scale.x = -1

#--------------------------------------------------------------------------------------------------

#region Physics

	if !is_on_floor():
		velocity.y += GRAVITY * delta	
	move_and_slide()
#endregion

#--------------------------------------------------------------------------------------------------

#Gunplay and Camera
	if Input.is_action_pressed('RMB'):
		is_aiming = true


		front_arm.play("AIM_ONE_HAND")
		front_arm.look_at(get_global_mouse_position())

		head.look_at(get_global_mouse_position())

		if Input.is_action_just_pressed('LMB') and cooldown_timer.is_stopped() and reload_timer.is_stopped():
			#print("POW!")
			shoot()
	else:
		head.rotation = 0
		front_arm.rotation = 0
		is_aiming = false




#--------------------------------------------------------------------------------------------------

	#Decides when the ledge grab collision should be disabled
	$LedgeGrab.disabled = velocity.y < 0 or ($TopCheck.is_colliding() and main_sm.get_active_state().name != "LEDGE") or crouch

#---------------------------------------------------------------------------------------------------

#region Shoot Function

func shoot():
	try_to_shoot = true
	if rounds_left > 0: #If you have ammo, shoot
		rounds_left -= 1
		#gunshot sound
		$gunshot.stream = gunshot
		$gunshot.play()
		
		#Instantiate new shell and bullet
		var shell = shellpath.instantiate()
		var bullet = bulletpath.instantiate()
		shell.position = front_arm.get_child(0).global_position
		bullet.position = front_arm.get_child(0).global_position
		#Add them to scene
		get_parent().add_child(bullet)
		get_parent().add_child(shell)
		
		# Set a random initial rotation
		shell.rotation = randf() * TAU

		# Set position for both shell and bullet


		# Set velocities for movement
		var veldirection = (get_global_mouse_position() - bullet.position).normalized()
		var bullet_velocity = veldirection * bullet.get_node("Bullet").bullet_speed
		var shell_velocity = veldirection * shell.shell_speed

		# Apply velocity
		bullet.get_node("Bullet").linear_velocity = bullet_velocity
		shell.apply_force(shell_velocity, shell.position)
		cooldown_timer.start()
	else: #RELOAD
		reload_timer.start()
		reloading = true
		$reload.stream = reload
		$reload.play()
	try_to_shoot = false


#endregion

#---------------------------------------------------------------------------------------------------

#region State Machine

#LimboAI for Godot ver: 4.3

func initiate_state_machine():
	main_sm = LimboHSM.new()
	add_child(main_sm)	
	


	var IDLE_state = LimboState.new().named("IDLE").call_on_enter(IDLE_START).call_on_update(IDLE_UPDATE)
	var WALK_state = LimboState.new().named("WALK").call_on_enter(WALK_START).call_on_update(WALK_UPDATE)
	var WALK_BACKWARDS_state = LimboState.new().named("WALK_BACKWARDS").call_on_enter(WALK_BACKWARDS_START).call_on_update(WALK_BACKWARDS_UPDATE)
	var SPRINT_state = LimboState.new().named("SPRINT").call_on_enter(SPRINT_START).call_on_update(SPRINT_UPDATE)
	var JUMP_state = LimboState.new().named("JUMP").call_on_enter(JUMP_START).call_on_update(JUMP_UPDATE)
	var FALL_state = LimboState.new().named("FALL").call_on_enter(FALL_START).call_on_update(FALL_UPDATE)
	var LAND_state = LimboState.new().named("LAND").call_on_enter(LAND_START).call_on_update(LAND_UPDATE)
	var LEDGE_state = LimboState.new().named("LEDGE").call_on_enter(LEDGE_START).call_on_update(LEDGE_UPDATE)	


	main_sm.add_child(IDLE_state)
	main_sm.add_child(WALK_state)
	main_sm.add_child(WALK_BACKWARDS_state)
	main_sm.add_child(SPRINT_state)
	main_sm.add_child(JUMP_state)
	main_sm.add_child(FALL_state)
	main_sm.add_child(LAND_state)
	main_sm.add_child(LEDGE_state)
	
	main_sm.initial_state = IDLE_state
	
	main_sm.add_transition(IDLE_state, WALK_state, &"to_walk")
	main_sm.add_transition(main_sm.ANYSTATE, IDLE_state, &"state_ended")
	main_sm.add_transition(WALK_state, SPRINT_state, &"to_sprint")
	main_sm.add_transition(IDLE_state, JUMP_state, &"to_jump")
	main_sm.add_transition(WALK_state, JUMP_state, &"to_jump")
	main_sm.add_transition(WALK_BACKWARDS_state, JUMP_state, &"to_jump")
	main_sm.add_transition(SPRINT_state, JUMP_state, &"to_jump")
	main_sm.add_transition(JUMP_state, LEDGE_state, &"to_ledge")
	main_sm.add_transition(main_sm.ANYSTATE, FALL_state, &"to_fall")
	main_sm.add_transition(FALL_state, LAND_state, &"to_land")
	
	main_sm.initialize(self)
	main_sm.set_active(true)
#------------------------------------------------------------------------------------------------


func IDLE_START():
	body_animation.play("IDLE")
func IDLE_UPDATE(delta: float):
	if direction != 0:
		main_sm.dispatch(&"to_walk")
	if jump:
		main_sm.dispatch(&"to_jump")
	if velocity.y != 0:
		main_sm.dispatch(&"to_fall")

func WALK_START():
	body_animation.play("START_WALK")
	#print("Animation set")
func WALK_UPDATE(delta: float):
	target_speed = SPEED
	if direction == 0:
		main_sm.dispatch(&"state_ended")
	if is_sprinting:
		main_sm.dispatch(&"to_sprint")
	if jump:
		main_sm.dispatch(&"to_jump")
	if direction != mouse_direction and is_aiming:
		body_animation.play_backwards()
		backwards = true
	elif backwards == true:
		body_animation.play
		backwards = false


func WALK_BACKWARDS_START():
	pass
func WALK_BACKWARDS_UPDATE(delta: float):
	if jump:
		main_sm.dispatch(&"to_jump")

func SPRINT_START():
	body_animation.play("START_RUN")
func SPRINT_UPDATE(delta: float):
	target_speed = SPRINT_SPEED
	if !is_sprinting or velocity.x == 0:
		main_sm.dispatch(&"state_ended")
	if jump:
		main_sm.dispatch(&"to_jump")

func JUMP_START():
	body_animation.play("START_JUMP")
	velocity.y += JUMP_VELOCITY
	land_finished = false
func JUMP_UPDATE(delta: float):
	if ledge:
		main_sm.dispatch(&"to_ledge")
	if not is_on_floor() and velocity.y > 0:
		main_sm.dispatch(&"state_ended")

func FALL_START():
	body_animation.play("FALLING")
func FALL_UPDATE(delta: float):
	if is_on_floor():
		main_sm.dispatch(&"to_land")

func LAND_START():
	body_animation.play("LANDING")
func LAND_UPDATE(delta: float):
	if land_finished:
		#print("Animation finished")
		main_sm.dispatch(&"state_ended")

func LEDGE_START():
	body_animation.play("LEDGE")
func LEDGE_UPDATE(delta: float):
	velocity.x = 0
	var collider = $WallCheck.get_collision_normal(0)
	if collider.x == -1:
		body_animation.flip_h = true
		if not is_on_wall():
			velocity.x = -25
	else:
		body_animation.flip_h = false
		if not is_on_wall():
			velocity.x = 25
	if $WallCheck.is_colliding() and !is_on_floor() and velocity.y == 0:
		ledge = true
	else:
		ledge = false
	if !ledge:
		main_sm.dispatch(&"state_ended")

#-------------------------------------------------------------------------------

func _on_body_animation_finished() -> void:
	#print("Animation finished: ", body_animation.animation)  # Debugging
	match body_animation.get_animation():
		
		"START_WALK":
			body_animation.play("WALK")
		"START_RUN":
			body_animation.play("RUN")
		"FALLING":
			pass
		"LANDING":
			land_finished = true
#endregion

#---------------------------------------------------------------------------------------------------
