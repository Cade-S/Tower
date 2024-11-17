extends CanvasLayer
var target
var sam_cursor = load("res://UI/sam_cursor.png")
var player_cursor = load("res://UI/player_cursor.png")
var aim_cursor = load("res://UI/aim_cursor.png")
var ammo_icon = load("res://projectile/bullet.png")
var sam
var player
var ammo
var health
@onready var heartrate = $heartrate
@onready var ammo_bar = $ammo
@onready var follow_button = $sam_follow_button
@onready var health_label = $heartrate/Label
var healthupdate = true
var dog = true


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	heartrate.play()
	if get_tree().has_group("sam"):
		sam = get_tree().get_nodes_in_group("sam")[0]
	else: dog = false
	if get_tree().has_group("player"):
		player = get_tree().get_nodes_in_group("player")[0]
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	health_label.text = str("Health: ", player.health)
	ammo = player.rounds_left
	if player.reloading == false:
		ammo_bar.frame = ammo
	else:
		ammo_bar.frame = 9
	
	if player.is_aiming == true:
		Input.set_custom_mouse_cursor(aim_cursor)
	elif dog == true:
		if sam.following == true:
			follow_button.frame = 1
			Input.set_custom_mouse_cursor(player_cursor)
	elif dog == true:
		follow_button.frame = 0
		Input.set_custom_mouse_cursor(sam_cursor)
	else:
		Input.set_custom_mouse_cursor(player_cursor)



func _on_button_pressed() -> void:
		if Input.is_action_just_released("LMB"):
			sam.following = !sam.following
			
