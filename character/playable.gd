extends CharacterBody2D

@export var GRAVITY = 600
@export var SPEED = 69.0
@export var SPRINT_SPEED = 120.0
@export var JUMP_VELOCITY = -250.0
@export var ACCELERATION = 350.0  # Adjust this to control how fast you pick up speed
@export var DECELERATION = 950.0  # Adjust this for how fast you slow down
var current_state = State.IDLE
var is_sprinting = false
var is_aiming = false
var target_speed = 0.0
var mouse_direction
var facing
const bulletpath = preload('res://projectile/bullet.tscn')
const shellpath = preload('res://projectile/shell.tscn')
var gunshot = preload('res://SoundFX/pewpew/gunshot.wav')
@onready var body_animation = get_node("PlayerSprite/Body")
@onready var head = get_node("PlayerSprite/Body/Head")
@onready var front_arm = get_node("PlayerSprite/Body/Front_Arm")
@onready var back_arm = get_node("PlayerSprite/Body/Front_Arm")


#Player states
enum State {
	IDLE,
	WALK,
	WALK_BACKWARDS,
	RUN,
	JUMP,
	FALL,
	LAND,
	LEDGE
}


#Shooting mechanic
func shoot():
	
	
	#gunshot sound
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
	shell.position = front_arm.get_child(0).global_position
	bullet.position = front_arm.get_child(0).global_position

	# Set velocities for movement
	var direction = (get_global_mouse_position() - bullet.position).normalized()
	var bullet_velocity = direction * bullet.get_node("RigidBody2D").bullet_speed
	var shell_velocity = direction * shell.shell_speed

	# Apply velocity
	bullet.get_node("RigidBody2D").linear_velocity = bullet_velocity
	shell.apply_force(shell_velocity, shell.position)








func _ready():
	pass



func _physics_process(delta: float) -> void:



#Gunplay and Camera
	if Input.is_action_pressed('RMB'):
		is_aiming = true
		front_arm.position.y = -4.0
		if facing == "left":
			front_arm.position.x = 2.7
		elif facing == "right":
			front_arm.position.x = -2.7

		front_arm.play("AIM_ONE_HAND")
		front_arm.look_at(get_global_mouse_position())

		head.look_at(get_global_mouse_position())


		if Input.is_action_just_pressed('LMB'):
			#print("POW!")
			shoot()
	else:
		front_arm.position.x = 0
		front_arm.position.y = 0
		front_arm.rotation = 0
		is_aiming = false
		head.rotation = 0
		front_arm.position.x
		

	
	
	
	if get_global_mouse_position() < self.global_position and is_aiming:
		#print("LEFT:mouse_directionTRUE")
		head.flip_v = true
		front_arm.flip_v = true
		mouse_direction = true
	else:
		#print("RIGHT: mouse_directionFALSE")
		head.flip_v = false
		front_arm.flip_v = false
		mouse_direction = false




#------------------------------------------------------------------------------
	#Ledge Grab
	if current_state in [State.JUMP, State.FALL]:
		check_ledge_grab()
		if current_state == State.LEDGE:
			#Ledge Animation
			body_animation.play("LEDGE")
			#print("Ledge animation")
			
			#For edge-case ledge issues, adds some velocity towards the ledge so
			#that the player is 'pushed' into the wall. Also handles sprite flipping
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
		
	#Apply gravity
	if !is_on_floor():
		velocity.y += GRAVITY * delta

		#If falling, ensure FALL animation is played only if not already in JUMP
		if current_state != State.FALL and current_state != State.JUMP:
			current_state = State.FALL
			body_animation.play("FALLING")
			#print("Transitioning to FALL state")  # Debugging

	else:
		# Handle landing
		if current_state == State.FALL:
			current_state = State.LAND
			body_animation.play("LANDING")
			#print("Transitioning to LAND state")  # Debugging

	# Handle movement and sprinting
	var direction = Input.get_axis("move_left", "move_right")
	if direction < 0:
		facing = "left"
	elif direction > 0:
		facing = "right"
	print(facing)


	# Only handle sprinting and walking when on the ground
	if is_on_floor() and current_state != State.LEDGE:
		is_sprinting = Input.is_action_pressed("sprint") && direction != 0  # Check if sprinting
		
		
		
		if is_sprinting:
			target_speed = SPRINT_SPEED
			if current_state != State.RUN and current_state != State.JUMP:
				current_state = State.RUN
				body_animation.play("START_RUN")  # Play START_RUN animation
				#print("Transitioning to RUN state")  # Debugging

		elif direction != 0:
			target_speed = SPEED
			if current_state != State.WALK and current_state != State.JUMP and current_state != State.WALK_BACKWARDS:
				current_state = State.WALK
				body_animation.play("START_WALK")  # Play START_WALK animation
				#print("Transitioning to WALK state")  # Debugging
				if is_aiming == true and mouse_direction == true:
					if direction > 0:
						current_state = State.WALK_BACKWARDS
						print("WALKING BACKWARDS")
					else:
						current_state = State.WALK

		else:
			target_speed = 0  # No movement, stop gradually
			if current_state != State.IDLE:
				current_state = State.IDLE
				body_animation.play("IDLE")  # Play IDLE animation
				#print("Transitioning to IDLE state")  # Debugging

	# Gradually change the horizontal velocity towards the target speed
	if direction != 0 and !current_state == State.LEDGE:
		velocity.x = move_toward(velocity.x, direction * target_speed, ACCELERATION * delta)
		body_animation.flip_h = direction < 0

	else:
		# Gradually slow down when no input is provided
		velocity.x = move_toward(velocity.x, 0, DECELERATION * delta)




	#Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		current_state = State.JUMP
		body_animation.play("START_JUMP")
		#print("Transitioning to JUMP state")  # Debugging
		return  # Exit to avoid falling logic



	# Apply movement
	move_and_slide()

	#Decides when the ledge grab collision should be disabled
	$LedgeGrab.disabled = current_state in [State.RUN, State.IDLE] or velocity.y < 0 or ($TopCheck.is_colliding() and current_state != State.LEDGE) or Input.is_action_pressed("crouch")

#Checks if in ledge grab state
func check_ledge_grab() -> void:
	if $WallCheck.is_colliding() and not $FloorCheck.is_colliding() and velocity.y == 0:
		current_state = State.LEDGE




func _on_body_animation_finished() -> void:
		#print("Animation finished: ", body_animation.animation)  # Debugging
	match current_state:


		State.LAND:
			# After landing, check for horizontal movement and transition accordingly
			if velocity.x == 0:
				current_state = State.IDLE
				body_animation.play("IDLE")  # Play IDLE animation
				#print("Transitioning to IDLE after LAND")  # Debugging
				
			else:
				current_state = State.WALK
				body_animation.play("WALK")  # Loop WALK animation
				#print("Transitioning to WALK after LAND")  # Debugging


		State.JUMP:
			# After jumping, transition to FALL if in the air
			if not is_on_floor():
				current_state = State.FALL
				body_animation.play("FALLING")  # Play FALLING animation
				#print("Transitioning to FALL from JUMP")


		State.FALL:
			# If falling and landing detected
			if is_on_floor():
				current_state = State.LAND
				body_animation.play("LANDING")  # Play LANDING animation
				#print("Transitioning to LAND from FALL")


		State.WALK:
			# If walking, ensure walking animation plays
			body_animation.play("WALK")  # Loop WALK animation
			#print("Continuing WALK animation")


		State.RUN:
			# If running, ensure running animation plays
			body_animation.play("RUN")  # Loop RUN animation
			#print("Continuing RUN animation")


		State.LEDGE:
			pass#Forgot to integrate, fix this
			
		State.WALK_BACKWARDS:
			print("Walk backwards")
