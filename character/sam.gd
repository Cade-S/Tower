extends CharacterBody2D

@export var WALK_SPEED = 45
@export var RUN_SPEED = 125.0
@export var JUMP_VELOCITY = -400.0
@export var ACCELERATION = 200
@export var DECELERATION = 900
@export var GRAVITY = 200
var target
var current_state = State.IDLE
var catching_up = false #If Sam needs to catch up to match speed with player
var following = true #Handles whether Sam follows player


enum State {
	IDLE,
	WALK_TO_PLAYER,
	RUN_TO_PLAYER,
	WALK_TO_IDLE_PLAYER
}

func _ready() -> void:
	if get_tree().has_group("player"):
		target = get_tree().get_nodes_in_group("player")[0]

func _physics_process(delta: float) -> void:
	var player_state = target.current_state
	#print(player_state)
	#0 = idle
	#1 = Walking
	#2 = Running
	#3 = Jumping
	#4 = Falling
	#5 = Land ??
	#6 = Ledge
	var distance = global_position.distance_to(target.global_position)
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += GRAVITY * delta


	# Gets the normalized distance between Sam and the Player
	var direction = (target.global_position - global_position).normalized()
	#print(distance)
	
	#Flip Sam's sprite based on player position
	if direction.x < 0:
		$AnimatedSprite2D.flip_h = true  # Facing left
		$wall_check.position.x = -70
	elif direction.x > 0:
		$AnimatedSprite2D.flip_h = false  # Facing right
		$wall_check.position.x = 70


	#Collects player state to decide Sam's state and behaviour
	if Input.is_action_just_pressed("summon_dog"):
		following = !following
		print("Following:", following)
		
		
		
		
		
		
	if following == true and $wall_check.is_colliding() == false: #if following player
		if player_state == 0: #IDLE
			if distance <= 10:
				current_state = State.IDLE
			elif distance <= 75 and current_state != State.IDLE:
				current_state = State.WALK_TO_IDLE_PLAYER
			else:
				current_state = State.RUN_TO_PLAYER
				
		if player_state == 1: #WALKING
			if distance <= 70:
				current_state = State.WALK_TO_PLAYER
				catching_up = false
			elif distance <= 100:
				current_state = State.WALK_TO_PLAYER
				catching_up = true
				
		if player_state == 2: #RUNNING
			if distance >= 60:
				current_state = State.RUN_TO_PLAYER
			elif distance >= 20 and current_state != State.RUN_TO_PLAYER:
				current_state = State.WALK_TO_IDLE_PLAYER
				
	else: current_state = State.IDLE #For not following player
		
			
	
	if current_state == State.RUN_TO_PLAYER:
		velocity.x = move_toward(velocity.x, direction.x * RUN_SPEED, ACCELERATION * delta)
		$AnimatedSprite2D.play("RUN")
		
			
				
	if current_state == State.WALK_TO_PLAYER:
		velocity.x = move_toward(velocity.x, direction.x * WALK_SPEED, ACCELERATION * delta)
		current_state = State.WALK_TO_IDLE_PLAYER
		$AnimatedSprite2D.play("WALK")
		#print("WALK")



	if current_state == State.IDLE:
		velocity.x = move_toward(velocity.x, 0, DECELERATION * delta)
		$AnimatedSprite2D.play("IDLE_BLINK")
		#print("Going IDLE")
	
	if current_state == State.WALK_TO_IDLE_PLAYER:
		#print("Walk to idle") #debug
		$AnimatedSprite2D.play("WALK")
		if distance >= 10:
			velocity.x = move_toward(velocity.x, direction.x * WALK_SPEED - 20, ACCELERATION * delta)
		else:
			current_state = State.IDLE
	
	

				

	move_and_slide()
