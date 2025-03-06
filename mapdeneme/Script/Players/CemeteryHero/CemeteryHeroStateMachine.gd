extends StateMachine

# We add the states and then set the initial.
func _ready():
	add_state("idle")
	add_state("walk")
	add_state("jump")
	add_state("fall")
	add_state("hurt")
	add_state("crouch")
	add_state("attack")
	add_state("dash")
	add_state("death")
	add_state("end_level")
	# yield is something like 'wait', so in this case, wait for idle_frame.
	yield(get_tree(),"idle_frame")
	# call_deferred is something like "call this function when possible".
	call_deferred("set_state", states.idle)
# Controls jump.	
func _handle_jump(_delta):
	if [states.idle, states.walk, states.crouch].has(state):
		if Input.is_action_pressed("jump"):	
			parent.jump()
	elif state == states.jump:
		# If we release the jump button during the jump and the jump value is low, we adjust to the minimum value.		
		if Input.is_action_just_released("jump"):
			if parent.velocity.y < parent.min_jump_velocity:
				parent.velocity.y = parent.min_jump_velocity		
# Contains the current state logic
func _state_logic(delta):
	parent.check_if_out_of_bound()
	if ![states.end_level, states.death, states.hurt, states.crouch, states.attack, states.dash].has(state):
		parent.handle_movement_input(delta)

	if state == states.end_level:
		parent.player_body.scale.x = 1
				
	if ![states.dash].has(state):
		parent.apply_gravity(delta)		
		parent.move(delta)
	else:
		parent.dash_movement(delta)
		
	_handle_jump(delta)


# Make appropriate transitions between states.
func _get_transitions(_delta):
	match state:
		states.idle:
			if parent.velocity.x != 0:
				return states.walk
			elif Input.is_action_pressed("crouch"):
				return states.crouch
			elif Input.is_action_just_pressed("weak_attack"):
				return states.attack	
			elif Input.is_action_just_pressed("heavy_attack") and parent.energy_controller_node.energy > 0 and parent.dash_cooldown_node.is_stopped():
				return states.dash		
				
			elif !parent.is_on_floor() and parent.get_node("CoyoteTimer").is_stopped():
				if parent.velocity.y < 0:
					return states.jump 
				else:
					if !parent.is_on_floor():
						return states.fall
		states.walk:		
			if parent.velocity.x == 0:
				return states.idle
				
			elif Input.is_action_just_pressed("weak_attack"):
				return states.attack		
				
			elif Input.is_action_just_pressed("heavy_attack") and parent.energy_controller_node.energy > 0 and parent.dash_cooldown_node.is_stopped():
				return states.dash
													
			elif !parent.is_on_floor() and parent.get_node("CoyoteTimer").is_stopped():
				if parent.velocity.y < 0:
					return states.jump 
				else:
					if !parent.is_on_floor():
						return states.fall
		states.jump:		
			if parent.is_on_floor():
				return states.idle
			elif Input.is_action_just_pressed("heavy_attack") and parent.energy_controller_node.energy > 0 and parent.dash_cooldown_node.is_stopped():
				return states.dash	
			elif parent.velocity.y >= 0:					
				return states.fall
		states.fall:
			if parent.is_on_floor():
				return states.idle		
			elif Input.is_action_just_pressed("heavy_attack") and parent.energy_controller_node.energy > 0 and parent.dash_cooldown_node.is_stopped():
				return states.dash					
			elif parent.velocity.y < 0:
				return states.jump
		states.hurt:
			if parent.is_on_floor() and parent.get_node("HurtedTimerControl").is_stopped():
				return states.idle
		states.crouch:
			if not Input.is_action_pressed("crouch"):
				return states.idle	
			if parent.velocity.y < 0:
				return states.jump 
			else:
				if !parent.is_on_floor():
					return states.fall
		states.attack:
			if !parent.is_on_floor():
				return states.fall
		states.dash:
			pass
						
# Function for entering a new state.
func _enter_state(_new_state, _old_state):
	match _new_state:
		states.idle:
			parent.assign_animation("idle")
		states.walk:
			parent.assign_animation("walk")
		states.jump:
			parent.assign_animation("jump")
		states.fall:
			parent.assign_animation("fall")
		states.hurt:
			parent.assign_animation("hurt")
			parent.snap_vector = Vector2()
			yield(get_tree(), "idle_frame")
			if _old_state != states.hurt:
				parent.hurt()
		states.crouch:
			parent.move_direction = 0
			parent.assign_animation("crouch")
		states.attack:
			parent.move_direction = 0
			# Monitorable and monitoring is a state that Area2D nodes has, it basically turns the monitoring state of the Area2D interaction.
			parent.attack_collision.monitorable = true
			parent.attack_collision.monitoring = true			
			parent.assign_animation("attack")
		states.dash:
			parent.set_enemy_collision_bit(false)
			# disabled set CollisionShape on/off.
			parent.dash_collision.disabled = false							
			parent.consume_energy(1)
			var input_direction = parent.get_input_direction()
			parent.dash_cooldown_node.start()
			parent.dash(input_direction)
		states.death:
			parent.assign_animation("hurt")
			parent.snap_vector = Vector2()
			yield(get_tree(), "idle_frame")
			parent.hurt()
			parent.get_node("CollisionShape2D").queue_free()
		states.end_level:
			parent.move_direction = 1
			parent.assign_animation("walk")
			parent.velocity.y = 0			
# State exit function.
func _exit_state(old_state, _new_state):
	match old_state:
		states.attack:
			yield(get_tree(),"idle_frame")
			parent.attack_collision.monitorable = false
			parent.attack_collision.monitoring = false
		states.hurt:
			parent.get_node("InvincibleTimer").start()
			parent.animation_node.play("Invincible")
		states.dash:
			parent.velocity = parent.velocity * 0.10	
			
func _on_Sprite_animation_finished():
	if parent.player_sprite_node.animation == "attack":
		set_state(states.idle)
