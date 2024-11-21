extends CharacterBody2D
const bulletpath = preload('res://projectile/bullet.tscn')
const shellpath = preload('res://projectile/shell.tscn')
const gunshot = preload('res://SoundFX/pewpew/gunshot.wav')
var engine_sound = preload("res://SoundFX/pewpew/turret_engine.ogg")
var main_sm = LimboHSM

@export var GRAVITY = 600
@export var health = 50
@export var angle_range = 40
@export var SPEED = 50
var ACCELERATION = 300
var DECELERATION = 300
var direction
var steps
var rng = RandomNumberGenerator.new()

func _ready() -> void:
	initiate_state_machine()
	
func _physics_process(delta: float) -> void:
	
	if !is_on_floor():
		velocity.y += GRAVITY * delta	
	move_and_slide()
	
func initiate_state_machine():
	main_sm = LimboHSM.new()
	add_child(main_sm)    
	
	var WANDER_state = LimboState.new().named("WANDER").call_on_enter(WANDER_START).call_on_update(WANDER_UPDATE)
	var SHOOT_state = LimboState.new().named("SHOOT").call_on_enter(SHOOT_START).call_on_update(SHOOT_UPDATE)
	
	main_sm.initial_state = WANDER_state
	
	main_sm.add_child(WANDER_state)
	main_sm.add_child(SHOOT_state)
	
	main_sm.add_transition(WANDER_state, SHOOT_state, &"to_shoot")
	main_sm.add_transition(SHOOT_state, WANDER_state, &"to_wander")
	
	main_sm.initialize(self)
	main_sm.set_active(true)
	
func WANDER_START():
	direction = randf_range(0,1)
	steps = randf_range(10,100)
func WANDER_UPDATE(delta: float):
	if direction == 0: direction = -1
	for step in steps:
		print(step)
		print(direction)
		velocity.x = move_toward(velocity.x, direction * SPEED, ACCELERATION * delta)
func SHOOT_START():
	pass
func SHOOT_UPDATE(delta: float):
	pass
