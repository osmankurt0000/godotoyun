extends Camera2D

# Change factor
const LOOK_AHEAD_FACTOR = 0.1

# Facing is the variable q that indicates the direction to be looked at.
var facing = 0
# onready var is a type of variable that will only have its value when starting the script, good for getting nodes or function values.
onready var prev_camera_pos = get_camera_position()
	
func _on_grounded_updated(is_grounded):
	drag_margin_v_enabled = !is_grounded
	
# The process is similar to physics_process, but it is recommended for things that depend only on the machine, without having a fixed cyclic value.
func _process(_delta):
	_check_facing()
	prev_camera_pos = get_camera_position()
	
# Check the correct side, sign returns the signal. Then, we change the position of the camera.	
func _check_facing():
	var new_facing = sign(get_camera_position().x - prev_camera_pos.x)
	if new_facing != 0 and facing != new_facing and owner.move_direction == new_facing:
		facing = new_facing
		var target_offset = get_viewport_rect().size.x * LOOK_AHEAD_FACTOR * facing
		# The Tween node is a great node for making transitions from non-absolute values.
		$ShiftTween.interpolate_property(
			self, 
			"position:x", 
			position.x, 
			target_offset, 
			2.0, 
			Tween.TRANS_SINE, 
			Tween.EASE_OUT, 
			0) 
		$ShiftTween.start()
