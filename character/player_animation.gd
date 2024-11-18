extends Node2D
@onready var body = $Body
@onready var head = get_node("Body/Head")
@onready var head_anim = get_node("Body/Head/AnimationPlayer")
@onready var front_arm = get_node("Body/Front_Arm")
@onready var back_arm = get_node("Body/Back_Arm")
@onready var player = get_parent()
@onready var aim_direction = player.mouse_direction
@onready var body_state = body.animation
							#True = RIGHT
							#False = LEFT

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	body_state = body.animation
	var direction = body.flip_h
	
	#if not player.is_aiming:
		#if direction == false:
			#self.scale.x = -1
			##front_arm.flip_h = false
			##head.flip_h = false
		#elif direction == true:
			##front_arm.flip_h = true
			##head.flip_h = true
			#self.scale.x = 1
	#elif player.main_sm.get_active_state().name != "SPRINT": 
		#front_arm.flip_h = false
		##body.flip_h = false
		#head.flip_h = false
		
	match body_state:
		
		"IDLE":
			head_anim.play("HEAD_IDLE")
			back_arm.play("IDLE")
			if player.is_aiming != true:
				front_arm.play("IDLE")

		"FALLING":
			head_anim.play("HEAD_FALLING")
			if player.is_aiming != true:
				front_arm.play("FALLING")
			back_arm.play("FALLING")
		"LANDING":
			head_anim.play("HEAD_LANDING")
			if player.is_aiming != true:
				front_arm.play("LANDING")
			back_arm.play("LANDING")
		"LEDGE":
			#head.play("IDLE")
			if player.is_aiming != true:
				front_arm.play("LEDGE")
			back_arm.play("LEDGE")
		"RUN":
			head_anim.play("HEAD_RUN")
			if player.is_aiming != true:
				front_arm.play("RUN")
			back_arm.play("RUN")
		"START_JUMP":
			head_anim.play("HEAD_START_JUMP")
			if player.is_aiming != true:
				front_arm.play("START_JUMP")
			back_arm.play("START_JUMP")
		"START_RUN":
			head_anim.play("HEAD_RUN")
			if player.is_aiming != true:
				front_arm.play("START_RUN")
			back_arm.play("START_RUN")
		"START_WALK":
			head_anim.play("HEAD_WALK")
			if player.is_aiming != true:
				front_arm.play("START_WALK")
			back_arm.play("START_WALK")
		"WALK":
			head_anim.play("HEAD_WALK")
			if player.is_aiming != true:
				front_arm.play("WALK")
			back_arm.play("WALK")





func _on_body_frame_changed() -> void:
	if head_anim.get_current_animation() != null:
		head_anim.seek(body.frame)
	#print(head_anim.get_current_animation_position())
