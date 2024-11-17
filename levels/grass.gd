extends AnimatedSprite2D
var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var grass_texture = rng.randf_range(0,3)
	var flipped = rng.randf_range(0,1)
	if flipped == 0: flipped = true
	else: flipped = false
	self.frame = grass_texture
	self.flip_h = flipped


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
