extends Node2D
@onready var base = $base
@onready var head = $head
@onready var base_anim = $base/base
@onready var head_anim = $head/head
var rng = RandomNumberGenerator.new()
var head_velocity = Vector2(0.5,0.5)
var base_velocity = Vector2(0.5,0.5)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	head.rotation = rng.randf_range(0, TAU)
	base.rotation = rng.randf_range(0, TAU)
	$sparks.emitting = true
	$flames.emitting = true
	head.apply_force(head_velocity, head.position)
	base.apply_force(base_velocity, base.position)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
