extends RayCast2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_colliding():
		var collider = get_collider().name
		if collider == "grab_me" and $Timer.is_stopped():
			$Timer.start()



func _on_timer_timeout() -> void:
	print("Timer end")# Replace with function body.
