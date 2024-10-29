extends CharacterBody2D

@export var WALK_SPEED = 45
@export var RUN_SPEED = 130.0
@export var JUMP_VELOCITY = -400.0
@export var ACCELERATION = 200
@export var DECELERATION = 900
@export var GRAVITY = 200
var target
var current_state = State.IDLE

enum State {
	IDLE,
	WALK,
	RUN
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


	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = (target.global_position - global_position).normalized()
	#print(distance)
	
	#Flip sprite based on player position
	if direction.x < 0:
		$AnimatedSprite2D.flip_h = true  # Facing left
	elif direction.x > 0:
		$AnimatedSprite2D.flip_h = false  # Facing right



		
	if current_state == State.RUN:
		velocity.x = move_toward(velocity.x, direction.x * RUN_SPEED, ACCELERATION * delta)
		$AnimatedSprite2D.play("RUN")
	#	if player_state == 0:
				
	if distance >= 50 and current_state != State.RUN:
		velocity.x = move_toward(velocity.x, direction.x * WALK_SPEED, ACCELERATION * delta)
		current_state = State.WALK
		$AnimatedSprite2D.play("WALK")
		#print("WALK")
		if distance >= 90:
			#print("Going RUN")
			current_state = State.RUN


		
	 
	

		
	if distance <= 30:
		velocity.x = move_toward(velocity.x, 0, DECELERATION * delta)
		current_state = State.IDLE
		$AnimatedSprite2D.play("IDLE_BLINK")
		#print("Going IDLE")

	move_and_slide()
