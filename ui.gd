extends CanvasLayer
var target
var sam_cursor = load("res://UI/sam_cursor.png")
var player_cursor = load("res://UI/player_cursor.png")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
		if get_tree().has_group("sam"):
			target = get_tree().get_nodes_in_group("sam")[0]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if target.following == true:
		$sam_follow_button.frame = 1
		Input.set_custom_mouse_cursor(player_cursor)
	else:
		$sam_follow_button.frame = 0
		Input.set_custom_mouse_cursor(sam_cursor)



func _on_button_pressed() -> void:
		if Input.is_action_just_released("left_mouse"):
			target.following = !target.following
			
