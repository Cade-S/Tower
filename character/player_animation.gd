extends Node2D
@onready var body = $Body
@onready var head = get_node("Body/Head")
@onready var front_arm = get_node("Body/Front_Arm")
@onready var back_arm = get_node("Body/Back_Arm")
@onready var player = get_parent()
@onready var aim_direction = player.mouse_direction
							#True = RIGHT
							#False = LEFT

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
	#0 = idle
	#1 = Walking
	#2 = Walk Backwards
	#3 = Running
	#4 = Jump
	#5 = FALL ??
	#6 = LAND
func _process(_delta: float) -> void:

	var body_state = body.animation
	var direction = body.flip_h
	
	if not player.is_aiming:
		if direction == false:
			front_arm.flip_h = false
			head.flip_h = false
		elif direction == true:
			front_arm.flip_h = true
			head.flip_h = true
	else: 
		front_arm.flip_h = false
		#body.flip_h = false
		head.flip_h = false
		
	match body_state:
		
		"IDLE":
			#head.play("IDLE")
			
			back_arm.play("IDLE")
			if player.is_aiming != true:
				front_arm.play("IDLE")

		"FALLING":
			#head.play("IDLE")
			if player.is_aiming != true:
				front_arm.play("FALLING")
			back_arm.play("FALLING")
		"LANDING":
			#head.play("IDLE")
			if player.is_aiming != true:
				front_arm.play("LANDING")
			back_arm.play("LANDING")
		"LEDGE":
			#head.play("IDLE")
			if player.is_aiming != true:
				front_arm.play("LEDGE")
			back_arm.play("LEDGE")
		"RUN":
			#head.play("IDLE")
			if player.is_aiming != true:
				front_arm.play("RUN")
			back_arm.play("RUN")
		"START_JUMP":
			#head.play("IDLE")
			if player.is_aiming != true:
				front_arm.play("START_JUMP")
			back_arm.play("START_JUMP")
		"START_RUN":
			#head.play("IDLE")
			if player.is_aiming != true:
				front_arm.play("START_RUN")
			back_arm.play("START_RUN")
		"START_WALK":
			#head.play("IDLE")
			if player.is_aiming != true:
				front_arm.play("START_WALK")
			back_arm.play("START_WALK")
		"WALK":
			#head.play("IDLE")
			if player.is_aiming != true:
				front_arm.play("WALK")
			back_arm.play("WALK")
