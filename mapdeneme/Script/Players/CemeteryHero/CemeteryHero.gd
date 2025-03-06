extends BaseCharacterScript

const PRE_DASH_EFFECT = preload("res://Scenes/PlayableCharacters/DashEffect.tscn")

# We store some paths in variables to easy acess
onready var dash_cooldown_node = $DashCooldown
onready var attack_collision = $Body/AttackCollision
onready var dash_collision = $Body/DashCollisionDamage/CollisionShape2D
# We define how many units we want to move when we Jump
onready var max_jump_height = 2.85  * GlobalValues.CELL_SIZE
onready var min_jump_height = 1.15 * GlobalValues.CELL_SIZE

# We define how many units we want to move when we dash.
onready var dash_velocity = 30 * GlobalValues.CELL_SIZE
# Define the cooldown time for dash.
var dash_cooldown = 1.0

# Damages
var attack_damage = 3	
var dash_damage = 2
	
func _ready():
	# We define some generic variables that BaseCharacterScript class has and may vary on inherited ones.
	life = 6
	energy = 3
	max_energy = 3
	recover_energy_timer = 3
	move_speed =  7 * GlobalValues.CELL_SIZE
	hurt_knockback = Vector2(5 * GlobalValues.CELL_SIZE, -8 * GlobalValues.CELL_SIZE)
	dash_cooldown_node.wait_time = dash_cooldown
	# We got our jump_velocity based on the global settings, like gravity and etc.
	var jump_velocity = GlobalValues.get_jump_velocity(max_jump_height, min_jump_height)
	max_jump_velocity = jump_velocity[0]
	min_jump_velocity = jump_velocity[1]
	# Update life and energy HUDs.
	_set_life(life)
	energy_controller_node.set_properties(energy, max_energy, recover_energy_timer)	
	
# We get the move direction and set the sprite scale to that direction
func handle_movement_input(_delta):
	move_direction = - int(Input.is_action_pressed("move_left")) + int(Input.is_action_pressed("move_right"))
	if move_direction != 0:
		player_body.scale.x = move_direction	

# We get the player input direction
func get_input_direction():
	var input_direction = Vector2()
	input_direction.x = - int(Input.is_action_pressed("move_left")) + int(Input.is_action_pressed("move_right"))
	input_direction.y =	int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up"))
	return input_direction

# Handle dash movement
func dash_movement(_delta):
	# Clamps keep a value between a min and max.
	global_position.x = clamp(global_position.x, $Camera2D.limit_left, $Camera2D.limit_right)

	var _movement = move_and_slide(velocity, Vector2.UP)

# Assign an animation to play, it's important in this case that both the animation name and emission texture have the same name.
func assign_animation(animation_name):
	_adjust_animation_collision_shape(animation_name)
	player_sprite_node.play(animation_name)
	
# We adjust the collision shape to match the current animation
func _adjust_animation_collision_shape(animation_name):
	match animation_name:
		"idle", "walk", "attack", "fall", "jump":
			collision_shape.shape.radius = 11
			collision_shape.shape.height = 20
			collision_shape.position = Vector2(0,-21)			
		"crouch":
			collision_shape.shape.radius = 11
			collision_shape.shape.height = 8
			collision_shape.position = Vector2(0,-15)

# Check when we hit an enemy and then apply damage
func _on_AttackCollision_body_entered(body):
	if body.has_method("damage"):
		body.damage(attack_damage, self)

func _on_DashCollisionDamage_body_entered(body):
	if body.has_method("damage"):
		body.damage(dash_damage, self)

# Receive the direction of dash and then apply it.		
func dash(input_direction):
	$GhostTimer.start()
	$DashDuration.start()
	if input_direction == Vector2.ZERO:
		input_direction.x = $Body.scale.x
		
	if input_direction.x != 0 and input_direction.y != 0:
		velocity = (dash_velocity / sqrt(2)) * input_direction
	else:
		velocity = dash_velocity * input_direction
# Triggered on the end of dash
func _on_DashDuration_timeout():
	$GhostTimer.stop()
	dash_collision.disabled = true	
	if $StateMachine.state != $StateMachine.states.end_level:
		if is_on_floor():
			$StateMachine.set_state($StateMachine.states.idle)
		else:	
			$StateMachine.set_state($StateMachine.states.fall)
	$InvincibleTimer.start()
# We instance the actual texture frame of the character and apply as an effect.
func _on_GhostTimer_timeout():
	var ghost_effect = PRE_DASH_EFFECT.instance()
	get_parent().add_child(ghost_effect)
	ghost_effect.dash_effect()
	ghost_effect.global_position = player_sprite_node.global_position
	ghost_effect.scale.x = player_body.scale.x
	ghost_effect.texture = player_sprite_node.frames.get_frame(player_sprite_node.animation, player_sprite_node.frame)
# To give a feedback that the dash can be used again we put the ghost effect once.
func _on_DashCooldown_timeout():
	var ghost_effect = PRE_DASH_EFFECT.instance()
	get_parent().add_child(ghost_effect)
	ghost_effect.return_dash_effect()
	ghost_effect.global_position = player_sprite_node.global_position
	ghost_effect.scale.x = player_body.scale.x
	ghost_effect.texture = player_sprite_node.frames.get_frame(player_sprite_node.animation, player_sprite_node.frame)
