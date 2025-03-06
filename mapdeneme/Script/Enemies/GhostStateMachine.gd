extends StateMachine


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var target_position = Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
	add_state("chase")
	add_state("spook")
	add_state("idle")
	add_state("disappear")
	add_state("appear")
	add_state("death")
	add_state("wait")
	yield(get_tree(),"idle_frame")
	call_deferred("set_state", states.wait)	
	parent.connect_visibility_on_ready()
	pass # Replace with function body.


# Contains the current state logic
func _state_logic(delta):
	if GlobalValues.current_level != null:
		parent.global_position.y = clamp(parent.global_position.y ,GlobalValues.current_level.level_limit_top	, GlobalValues.current_level.level_limit_bottom)
		parent.global_position.x = clamp(parent.global_position.x ,GlobalValues.current_level.level_limit_left	, GlobalValues.current_level.level_limit_right)
		
	if [states.idle].has(state):	
		var moved_to_target = parent.move_to(delta, target_position)
		if moved_to_target:
			set_state(states.spook) 
	pass

# Make appropriate transitions between states.
func _get_transitions(_delta):
	pass

# Function for entering a new state.
func _enter_state(_new_state, _old_state):
	match state:
		states.wait:
			parent.assign_animation("idle")
		states.idle:
			parent.assign_animation("idle")
			target_position = parent.get_random_circle_point()
		states.spook:
			parent.assign_animation("spook")
		states.appear:
			parent.assign_animation("appear")
			parent.appear()
			target_position = parent.get_random_circle_point()			
			parent.global_position = target_position
		states.disappear:
			parent.assign_animation("disappear")
			parent.disappear()
			parent.disappearance_timer.start()
		states.death:
			parent.die()
	pass

# State exit function.
func _exit_state(_old_state, _new_state):
	pass


func _on_DisappearenceTimer_timeout():
	target_position = parent.get_random_circle_point()
	set_state(states.appear) 
