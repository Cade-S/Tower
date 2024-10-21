extends CharacterBody2D

@export var GRAVITY = 600
@export var SPEED = 69.0
@export var SPRINT_SPEED = 120.0
@export var JUMP_VELOCITY = -200.0
@export var ACCELERATION = 350.0  # Adjust this to control how fast you pick up speed
@export var DECELERATION = 950.0  # Adjust this for how fast you slow down


# Character states
enum State {
	IDLE,
	WALK,
	RUN,
	JUMP,
	FALL,
	LAND
}

var current_state = State.IDLE
var is_sprinting = false
var target_speed = 0.0  # The speed we're moving towards
var is_grabbing = false


func _physics_process(delta: float) -> void:
	
# Detect if the player is colliding with the object "grab_me"
	if $Grab_64.is_colliding():
		var collider = $Grab_64.get_collider().name
		if collider == "grab_me" and $Grab_64/Timer.is_stopped():
			is_grabbing = true
			velocity = Vector2.ZERO  # Freeze movement while grabbing
		else:
			is_grabbing = false
			
			
	# Handle input for jump while grabbing
	if is_grabbing:
		if Input.is_action_pressed("jump"):
			$Grab_64/Timer.start()
			is_grabbing = false

			
	# Apply gravity
	if !is_on_floor() and !is_grabbing:
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

	if is_on_floor():  # Only handle sprinting and walking when on the ground
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
	if direction != 0:
		velocity.x = move_toward(velocity.x, direction * target_speed, ACCELERATION * delta)
		$AnimatedSprite2D.flip_h = direction < 0
	else:
		# Gradually slow down when no input is provided
		velocity.x = move_toward(velocity.x, 0, DECELERATION * delta)



	# Handle jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		current_state = State.JUMP
		$AnimatedSprite2D.play("START_JUMP")
		print("Transitioning to JUMP state")  # Debugging
		return  # Exit to avoid falling logic



	# Apply movement
	move_and_slide()





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
