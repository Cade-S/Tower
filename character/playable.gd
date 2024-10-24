extends CharacterBody2D

@export var GRAVITY = 600
@export var SPEED = 69.0
@export var SPRINT_SPEED = 120.0
@export var JUMP_VELOCITY = -250.0
@export var ACCELERATION = 350.0  # Adjust this to control how fast you pick up speed
@export var DECELERATION = 950.0  # Adjust this for how fast you slow down



#Character states
enum State {
	IDLE,
	WALK,
	RUN,
	JUMP,
	FALL,
	LAND,
	LEDGE
}

var current_state = State.IDLE
var is_sprinting = false
var target_speed = 0.0  #The speed we're moving towards


func _physics_process(delta: float) -> void:
	

	#Ledge Grab
			
	if current_state in [State.JUMP, State.FALL]:
		check_ledge_grab()
		if current_state == State.LEDGE:
			#Ledge Animation
			$AnimatedSprite2D.play("LEDGE")
			print("Ledge animation")
			
			#For edge-case ledge issues
			velocity.x = 0
			var collider = $WallCheck.get_collision_normal(0)
			if collider.x == -1:
				$AnimatedSprite2D.flip_h = true
				if not is_on_wall():
					velocity.x = -25
			else:
				$AnimatedSprite2D.flip_h = false
				if not is_on_wall():
					velocity.x = 25
		
	# Apply gravity
	if !is_on_floor():
		velocity.y += GRAVITY * delta

		# If falling, ensure FALL animation is played only if not already in JUMP
		if current_state != State.FALL and current_state != State.JUMP:
			current_state = State.FALL
			$AnimatedSprite2D.play("FALLING")
			print("Transitioning to FALL state")  # Debugging

	else:
		# Handle landing
		if current_state == State.FALL:
			current_state = State.LAND
			$AnimatedSprite2D.play("LANDING")
			print("Transitioning to LAND state")  # Debugging

	# Handle movement and sprinting
	var direction = Input.get_axis("move_left", "move_right")

	if is_on_floor() and current_state != State.LEDGE:  # Only handle sprinting and walking when on the ground
		is_sprinting = Input.is_action_pressed("sprint") && direction != 0  # Check if sprinting
		if is_sprinting:
			target_speed = SPRINT_SPEED
			if current_state != State.RUN and current_state != State.JUMP:
				current_state = State.RUN
				$AnimatedSprite2D.play("START_RUN")  # Play START_RUN animation
				print("Transitioning to RUN state")  # Debugging
		elif direction != 0:
			target_speed = SPEED
			if current_state != State.WALK and current_state != State.JUMP:
				current_state = State.WALK
				$AnimatedSprite2D.play("START_WALK")  # Play START_WALK animation
				print("Transitioning to WALK state")  # Debugging
		else:
			target_speed = 0  # No movement, stop gradually
			if current_state != State.IDLE:
				current_state = State.IDLE
				$AnimatedSprite2D.play("IDLE")  # Play IDLE animation
				print("Transitioning to IDLE state")  # Debugging

	# Gradually change the horizontal velocity towards the target speed
	if direction != 0 and !current_state == State.LEDGE:
		velocity.x = move_toward(velocity.x, direction * target_speed, ACCELERATION * delta)
		$AnimatedSprite2D.flip_h = direction < 0
	else:
		# Gradually slow down when no input is provided
		velocity.x = move_toward(velocity.x, 0, DECELERATION * delta)




	#Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		current_state = State.JUMP
		$AnimatedSprite2D.play("START_JUMP")
		print("Transitioning to JUMP state")  # Debugging
		return  # Exit to avoid falling logic



	# Apply movement
	move_and_slide()

	$LedgeGrab.disabled = current_state in [State.RUN, State.IDLE] or velocity.y < 0 or ($TopCheck.is_colliding() and current_state != State.LEDGE) or Input.is_action_pressed("crouch")

func check_ledge_grab() -> void:
	if $WallCheck.is_colliding() and not $FloorCheck.is_colliding() and velocity.y == 0:
		current_state = State.LEDGE

# Function to handle animation when finished
func _on_animated_sprite_2d_animation_finished() -> void:
	print("Animation finished: ", $AnimatedSprite2D.animation)  # Debugging
	match current_state:
		State.LAND:
			# After landing, check for horizontal movement and transition accordingly
			if velocity.x == 0:
				current_state = State.IDLE
				$AnimatedSprite2D.play("IDLE")  # Play IDLE animation
				print("Transitioning to IDLE after LAND")  # Debugging
			else:
				current_state = State.WALK
				$AnimatedSprite2D.play("WALK")  # Loop WALK animation
				print("Transitioning to WALK after LAND")  # Debugging
		State.JUMP:
			# After jumping, transition to FALL if in the air
			if not is_on_floor():
				current_state = State.FALL
				$AnimatedSprite2D.play("FALLING")  # Play FALLING animation
				print("Transitioning to FALL from JUMP")
		State.FALL:
			# If falling and landing detected
			if is_on_floor():
				current_state = State.LAND
				$AnimatedSprite2D.play("LANDING")  # Play LANDING animation
				print("Transitioning to LAND from FALL")
		State.WALK:
			# If walking, ensure walking animation plays
			$AnimatedSprite2D.play("WALK")  # Loop WALK animation
			print("Continuing WALK animation")
		State.RUN:
			# If running, ensure running animation plays
			$AnimatedSprite2D.play("RUN")  # Loop RUN animation
			print("Continuing RUN animation")
		State.LEDGE:
			pass
