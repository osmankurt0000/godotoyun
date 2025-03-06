extends KinematicBody2D


class_name BaseCharacterScript

const SLOPE_STOP = 64

signal grounded_updated(is_grounded)

# We store some paths in variables to easy acess
onready var collision_shape = $CollisionShape2D
onready var player_sprite_node = $Body/Sprite

onready var player_body = $Body
onready var animation_node = $AnimationPlayer
onready var floor_raycast = $Body/DetectFloorRaycast/RayCast2D
onready var energy_controller_node = $CanvasLayer/EnergyController

# Control character velocity
var velocity = Vector2()

# We define how many units we want to move when we do movement.
var move_speed = 0
var hurt_knockback = Vector2()
# Some control variables
var move_direction = 0
var snap_vector = Vector2()
var is_jumping = false
	
var is_on_slope = false

var life = 0
var energy = 0
var max_energy = 0
var recover_energy_timer = 0

# We calculate these two variables in GlobalValues.gd Script, using a formula
onready var	max_jump_velocity
onready var	min_jump_velocity

# Apply gravity to the character.
func apply_gravity(delta):
	if $CoyoteTimer.is_stopped():
		velocity.y += GlobalValues.gravity * delta

		if is_jumping and velocity.y >= 0:
			is_jumping = false

# We move our character
func move(_delta):
	velocity.x =  lerp(velocity.x, move_speed * move_direction, _get_h_weight())
# We say that if the ground speed is 0, we should stop sliding, if not, continue. This is good for mobile platforms.
	var stop_on_slope = true if get_floor_velocity().x == 0 else false	
	
# If we are not moving and the movement speed is less than the slide value, stop the player.	
	if move_direction == 0 and abs(velocity.x) < SLOPE_STOP:
		velocity.x =  lerp(velocity.x, 0, _get_h_weight())
		
	var was_grounded = is_on_floor()

# The move_and_slide_with_snap function is a standard function, it is suitable for platforms
# and helps in detecting moving platforms, glides and others.
# It can be checked out at: https://godot-es-docs.readthedocs.io/en/latest/tutorials/physics/using_kinematic_body_2d.html	
	velocity = move_and_slide_with_snap(velocity, snap_vector, Vector2.UP, stop_on_slope, 4 , 1)

# Clamps keep a value between a min and max, we add 200 on the final so our character can do the end level by getting out of the map..
	global_position.x = clamp(global_position.x, $Camera2D.limit_left, $Camera2D.limit_right + 200)
	
	if global_position.x >  $Camera2D.limit_right + player_sprite_node.frames.get_frame(player_sprite_node.animation, player_sprite_node.frame).get_width():
		yield(get_tree(),"idle_frame")
		var _change_scene = get_tree().change_scene("res://Scenes/Menu/CharacterSelection.tscn")
		
	# This repetition informs the colliders obtained in the last move_and_slide_with_snap	
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		# We check if we are on a slope
		var normal = collision.normal
		if ( abs(normal.x) and abs(normal.y) ) != (1 or 0):
			is_on_slope = false
		else:
			if floor_raycast.is_colliding():
				is_on_slope = true
			else:
				is_on_slope = false

# If we were on the ground and we are not jumping, start the coyote timer.
# This timer helps the game feel of the game, giving the player a short break after jumping off a platform.
	if !is_on_floor() and was_grounded and !is_jumping and $StateMachine.state != $StateMachine.states.hurt:
		$CoyoteTimer.start()	
		velocity.y = 0
		
	if was_grounded == null or is_on_floor() != was_grounded:
		emit_signal("grounded_updated", is_on_floor())	
		
	snap_vector = Vector2(0,24) if is_on_floor() and !is_jumping else Vector2(0,0)
	
# Controls the speed value of X (when you press to move right or left
# If not on the ground (ie in the air) have a little less control, smaller values ​​here means less control
func _get_h_weight():
	if is_on_floor() or !$CoyoteTimer.is_stopped():
		return 1.0 if is_on_slope else 0.5
	else:		
		if move_direction == 0:
			return 0.02
		elif move_direction == sign(velocity.x) and abs(velocity.x) > move_speed:
			return 0.2
		else:
			return 0.02

func jump():
	get_node("CoyoteTimer").stop()
	velocity.y = max_jump_velocity
	snap_vector = Vector2()
	is_jumping = true

# When whe take damage, update the life hud and set hurt state
func damage(quantity, damage_direction, _damage_dealer):
	life -= quantity
	_set_life(life)
	if life > 0:
		$StateMachine.set_state($StateMachine.states.hurt)
		hurt_knockback.x = damage_direction * abs(hurt_knockback.x)
		$HurtedTimerControl.start()
		player_body.scale.x = sign( -hurt_knockback.x)
		player_sprite_node.modulate = Color(2,1,1,1)
		set_enemy_collision_bit(false)
	else:
		hurt_knockback.x = damage_direction * abs(hurt_knockback.x)
		$HurtedTimerControl.start()
		player_body.scale.x = sign( -hurt_knockback.x)
		player_sprite_node.modulate = Color(2,1,1,1)
		set_enemy_collision_bit(false)		
		$StateMachine.set_state($StateMachine.states.death)

# Apply knockback	
func hurt():
	snap_vector = Vector2()
	move_direction = 0
	velocity = hurt_knockback

# Enable/disable collision with enemies
func set_enemy_collision_bit(boolean):
	self.set_collision_mask_bit(2, boolean)
	self.set_collision_mask_bit(4, boolean)

# After take hit, we wanna set an invincible time and then it ends, return the collision
func _on_InvincibleTimer_timeout():
	$StateMachine.set_state($StateMachine.state)
	yield(get_tree(), "idle_frame")
	set_enemy_collision_bit(true)
	
# Check if we fall off the level
func check_if_out_of_bound():
	# This is just to set an additional value to get if we're out of bounds from the screen. (AKA if we fall of the scenary)
	var character_vertical_size = player_sprite_node.frames.get_frame(player_sprite_node.animation, player_sprite_node.frame).get_height()
	if global_position.y > $Camera2D.limit_bottom + character_vertical_size:
		life = 0
		$CanvasLayer/LifeController.set_life(life)
		var _change_scene = get_tree().reload_current_scene()

# Update life
func _set_life(life_value):
	life = life_value
	$CanvasLayer/LifeController.set_life(life)

# Update energy
func consume_energy(quantity):
	energy_controller_node.use_energy(quantity)

func end_level():
	$StateMachine.set_state($StateMachine.states.end_level)
