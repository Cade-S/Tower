extends AudioStreamPlayer2D

var anim
@onready var state
var current_frame
var playable = true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	state = get_parent().main_sm.get_active_state().name
	anim = get_parent().get_node("PlayerSprite/Body")
	
	#print(player_state)
	#0 = idle
	#1 = Walking
	#2 = Running
	#3 = Jumping
	#4 = Falling
	#5 = Land ??
	#6 = Ledge
	if state in ["WALK", "SPRINT"]:
		current_frame = anim.get_frame()

	# Check if the current frame is one of the specified frames and playable is true
		if current_frame in [1, 4] and playable:
			self.play()
			#print("step sound played my boy")
			#print(current_frame)  # Print current frame instead of anim.get_frame()
			playable = false  # Set playable to false after playing the sound

		if current_frame not in [1, 4]:  # Only reset if not in the specified frames
			playable = true
		
