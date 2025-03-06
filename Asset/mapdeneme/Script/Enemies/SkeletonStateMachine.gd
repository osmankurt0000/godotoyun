extends StateMachine

func _ready():
	add_state("wait")
	add_state("rise")
	add_state("walk")
	add_state("hurt")
	add_state("death")
	yield(get_tree(),"idle_frame")
	call_deferred("set_state", states.wait)	
	pass # Replace with function body.

# Contains the current state logic
func _state_logic(delta):
			
	if ![states.death, states.wait, states.rise].has(state):
		if GlobalValues.current_level != null:
			if parent.global_position.y - parent.animated_sprite.frames.get_frame(parent.animated_sprite.animation, parent.animated_sprite.frame).get_height() > GlobalValues.current_level.level_limit_bottom:
				set_state(states.death)
		parent.apply_gravity(delta)
		parent.apply_movement(delta)
	
	if [states.walk].has(state):
		parent.apply_horizontal_movement(delta)
		
	pass

# Make appropriate transitions between states.
func _get_transitions(_delta):
	match state:
		states.hurt:
			if parent.is_on_floor():
				return states.walk
	pass

# Function for entering a new state.
func _enter_state(_new_state, _old_state):
	match state:
		states.wait:
			parent.collide_with_player.disabled = true
			parent.collision_shape.disabled = true		
			parent.animated_sprite.hide()	
		states.rise:
			parent.animated_sprite.play("rise")
		states.walk:
			parent.animated_sprite.play("walk")
			
		states.hurt:
			parent.apply_hurt_knockback()
			parent.animation_player.play("hurt")
		states.death:
			parent.die()
	pass

# State exit function.
func _exit_state(_old_state, _new_state):
	pass

