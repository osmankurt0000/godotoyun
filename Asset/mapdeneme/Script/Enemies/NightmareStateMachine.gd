extends StateMachine


onready var temporary_idle_time = parent.idle_time
onready var temporary_run_time = parent.run_time
func _ready(): 
	add_state("run")
	add_state("idle")
	add_state("hurt")
	add_state("death")
	yield(get_tree(),"idle_frame")
	call_deferred("set_state", states.run)	
	pass # Replace with function body.

# Contains the current state logic
func _state_logic(delta):
			
	if ![states.death].has(state):
		if GlobalValues.current_level != null:
			parent.global_position.x = clamp(parent.global_position.x ,GlobalValues.current_level.level_limit_left	, GlobalValues.current_level.level_limit_right)
			if parent.global_position.y - parent.animated_sprite.frames.get_frame(parent.animated_sprite.animation, parent.animated_sprite.frame).get_height() > GlobalValues.current_level.level_limit_bottom:
				set_state(states.death)
		parent.apply_gravity(delta)
		parent.apply_movement(delta)
	
	if [states.idle].has(state):
		parent.velocity.x = 0
		charge_run_attack(delta)
	elif [states.run].has(state):
		run_duration(delta)
		parent.apply_horizontal_movement(delta)


# Make appropriate transitions between states.
func _get_transitions(_delta):
	match state:
		states.hurt:
			if parent.is_on_floor():
				return states.run


# Function for entering a new state.
func _enter_state(_new_state, _old_state):
	match state:
		states.run:
			parent.adjust_emission_texture("run")
			parent.animated_sprite.play("run")
			temporary_idle_time = parent.idle_time
		states.idle:		
			parent.animated_sprite.play("idle")
			parent.adjust_emission_texture("idle")
			temporary_run_time = parent.run_time
		states.hurt:
			parent.apply_hurt_knockback()
			parent.animation_player.play("hurt")
		states.death:
			parent.die()
	pass

# State exit function.
func _exit_state(_old_state, _new_state):
	pass

func charge_run_attack(delta):
	temporary_idle_time -= delta
	if temporary_idle_time <= 0:
		set_state(states.run)

func run_duration(delta):
	temporary_run_time -= delta
	if temporary_run_time <= 0:
		set_state(states.idle)	
