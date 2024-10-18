extends RayCast2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_colliding():
		var collider = get_collider()
		if collider and collider.name == "Player":
			reset_scene()
			
func reset_scene() -> void:
	get_tree().reload_current_scene()
