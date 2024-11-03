extends RigidBody2D
var shell_speed = 20
var shell_velocity = Vector2(0,0)
var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	var rotate = rng.randf_range(0,360)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
