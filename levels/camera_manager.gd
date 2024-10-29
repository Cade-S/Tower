extends Node


var current_camera_zone: int = 0
var player
@export var Camera_Zone0: PhantomCamera2D
@export var Camera_Zone1: PhantomCamera2D
@export var Camera_Zone2: PhantomCamera2D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if get_tree().has_group("player"):
		player = get_tree().get_nodes_in_group("player")[0]

func update_current_zone(body, zone_a, zone_b):
	if body == player:
		match current_camera_zone:
			zone_a:
				current_camera_zone = zone_b
			zone_b:
				current_camera_zone = zone_a
		update_camera()
			
func update_camera():
	var cameras = [Camera_Zone0, Camera_Zone1]
	
	for camera in cameras:
		if camera != null:
			camera.priority = 0
	match current_camera_zone:
			0:
				Camera_Zone0.priority = 1
			1:
				Camera_Zone1.priority = 1


	print("Camera Zone:", current_camera_zone)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	








	




func _on_zone_01_body_entered(body: Node2D) -> void:
	update_current_zone(player,0,1)
