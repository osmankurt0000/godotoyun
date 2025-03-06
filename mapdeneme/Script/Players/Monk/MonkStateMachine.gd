extends StateMachine

# We add the state
func _ready():
	add_state("idle")
	add_state("walk")
	add_state("jump")
	add_state("fall")
	add_state("hurt")
	add_state("crouch")
	add_state("crouch_kick")
	add_state("kick")
	add_state("flying_kick")
	add_state("pre_punch")
	add_state("punch")
	add_state("death")
	add_state("end_level")
	yield(get_tree(),"idle_frame")
	call_deferred("set_state", states.idle)
	pass # Replace with function body.
	
func _handle_jump(_delta):
	if [states.idle, states.walk, states.crouch].has(state):
		if Input.is_action_pressed("jump"):	
			parent.jump()
	elif state == states.jump:
		# Se soltarmos o botão de pulo durante o pulo e o valor do pulo for baixo, ajustamos até o valor mínimo.			
		if Input.is_action_just_released("jump"):
			if parent.velocity.y < parent.min_jump_velocity:
				parent.velocity.y = parent.min_jump_velocity		
# Contains the current state logic
func _state_logic(delta):
		
	parent.apply_gravity(delta)
	parent.check_if_out_of_bound()
			
	if ![states.end_level, states.death, states.hurt, states.crouch, states.crouch_kick, states.kick, states.pre_punch, states.punch].has(state):
		parent.handle_movement_input(delta)
	
	if state == states.end_level:
		parent.player_body.scale.x = 1
		
	parent.move(delta)
	_handle_jump(delta)
	if state == states.pre_punch:
		parent.charged_attack(delta)
	pass

# Make appropriate transitions between states.
func _get_transitions(_delta):
	match state:
		states.idle:
			if parent.velocity.x != 0:
				return states.walk
			elif Input.is_action_pressed("crouch"):
				return states.crouch
			elif Input.is_action_just_pressed("weak_attack"):
				return states.kick	
			elif Input.is_action_pressed("heavy_attack") and parent.energy_controller_node.energy > 0:
				return states.pre_punch		
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
				return states.kick		
				
			elif Input.is_action_pressed("heavy_attack") and parent.energy_controller_node.energy > 0:
				return states.pre_punch
													
			elif !parent.is_on_floor() and parent.get_node("CoyoteTimer").is_stopped():
				if parent.velocity.y < 0:
					return states.jump 
				else:
					if !parent.is_on_floor():
						return states.fall
		states.jump:		
			if parent.is_on_floor():
				return states.idle	
			elif parent.velocity.y >= 0:					
				return states.fall
		states.fall:
			if parent.is_on_floor():
				return states.idle
			elif Input.is_action_pressed("weak_attack"):
				return states.flying_kick						
			elif parent.velocity.y < 0:
				return states.jump
		states.hurt:
			if parent.is_on_floor() and parent.get_node("HurtedTimerControl").is_stopped():
				return states.idle
			pass
		states.crouch:
			if not Input.is_action_pressed("crouch"):
				return states.idle	
			if Input.is_action_just_pressed("weak_attack"):
				return states.crouch_kick		
			if parent.velocity.y < 0:
				return states.jump 
			else:
				if !parent.is_on_floor():
					return states.fall
		states.kick:
			if !parent.is_on_floor():
				return states.fall
				
		states.crouch_kick:					
			if !parent.is_on_floor():
				return states.fall
		states.flying_kick:
			if parent.is_on_floor():
				return states.idle					
			elif parent.velocity.y < 0 and not Input.is_action_pressed("weak_attack"):
				return states.jump			
				
		states.pre_punch:
			if not Input.is_action_pressed("heavy_attack"):
				return states.punch		
			if !parent.is_on_floor():
				return states.fall						
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
		states.crouch_kick:
			parent.crouch_kick_attack_collision.monitorable = true
			parent.crouch_kick_attack_collision.monitoring = true					
			parent.assign_animation("crouch-kick")
		states.kick:
			parent.move_direction = 0
			parent.kick_attack_collision.monitorable = true
			parent.kick_attack_collision.monitoring = true			
			parent.assign_animation("kick")
		states.flying_kick:
			parent.assign_animation("flying-kick")
			parent.flying_kick_attack_collision.monitorable = true
			parent.flying_kick_attack_collision.monitoring = true					
		states.pre_punch:
			parent.charged_time = 0.1
			parent.move_direction = 0
			parent.pre_punch_particle_node.emitting = true

			parent.assign_animation("pre-punch")
		states.punch:
			parent.move_direction = 0
			parent.punch_particle_node.process_material.gravity.x = parent.player_body.scale.x * abs(parent.punch_particle_node.process_material.gravity.x)
			parent.punch_particle_node.emitting = true
			
			parent.consume_energy(1)
			parent.punch_attack_collision.monitorable = true
			parent.punch_attack_collision.monitoring = true		
			parent.assign_animation("punch")
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
		states.pre_punch:
			parent.pre_punch_particle_node.emitting = false
			parent.pre_punch_particle_node.lifetime = 0.5
		states.crouch_kick:
			yield(get_tree(),"idle_frame")
			parent.crouch_kick_attack_collision.monitorable = false
			parent.crouch_kick_attack_collision.monitoring = false			
		states.kick:
			yield(get_tree(),"idle_frame")
			parent.kick_attack_collision.monitorable = false
			parent.kick_attack_collision.monitoring = false
		states.punch:
			yield(get_tree(),"idle_frame")
			parent.punch_attack_collision.monitorable = false
			parent.punch_attack_collision.monitoring = false
		states.flying_kick:
			yield(get_tree(),"idle_frame")
			parent.flying_kick_attack_collision.monitorable = false
			parent.flying_kick_attack_collision.monitoring = false		
		states.hurt:
			parent.get_node("InvincibleTimer").start()
			parent.animation_node.play("Invincible")
			
func _on_Sprite_animation_finished():
	if parent.player_sprite_node.animation == "crouch-kick":
		set_state(states.crouch)
	if parent.player_sprite_node.animation == "punch" or parent.player_sprite_node.animation == "kick":
		set_state(states.idle)
