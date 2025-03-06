extends Control

# We preload the stage_selection scene to change to it
export (PackedScene) var stage_selection

# We declare some long paths into variables to make it looks clear.
onready var characters = [$HBoxContainer/VBoxContainer/Monk, $HBoxContainer/VBoxContainer/SwampShooter, $HBoxContainer/VBoxContainer/CemeteryHero]

onready var show_character_name_node = $HBoxContainer/VBoxContainer2/CharacterName
onready var show_character_animation_node = $HBoxContainer/VBoxContainer2/CharacterSprite/AnimatedSprite

onready var health_points_node = $HBoxContainer/VBoxContainer3/GridContainer/HealthContainer/Points
onready var speed_points_node = $HBoxContainer/VBoxContainer3/GridContainer/SpeedContainer/Points
onready var damage_points_node = $HBoxContainer/VBoxContainer3/GridContainer/DamageContainer/Points

# Preloads shader for future use
var glow_shader = preload("res://Shaders/GlowShader.shader")

func _ready():
	# We reset two variables to run from some undesired behaviors
	GlobalValues.current_level = null
	GlobalValues.current_level_name = ''
	# We grab the focus of the first button, to enable navigation from joystick.
	characters[0].grab_focus()
	
	# Connect the signals to the buttons, the [character] pass which button has triggered the function.
	for character in $HBoxContainer/VBoxContainer.get_children():
		character.connect("pressed", self, "on_character_button_pressed",[character])
		character.connect("mouse_entered", self, "on_mouse_entered",[character])

		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# Remember grab_focus? get_focus_owner shows who has the focus.
	if get_focus_owner() != null:
		$CharacterSelection.show()
		var focus_owner = get_focus_owner()
		$CharacterSelection.global_position = focus_owner.rect_global_position
		show_character_name_node.text = get_focus_owner().name
		# We check if one of the characters buttons has the focus, if it does, we check if it is monk.
		# Monk need a special check because on game he has some glow in it, so we want him to have it here too.
		for index in characters:
			if index == focus_owner:
				show_character_animation_node.play(get_focus_owner().name)
				if get_focus_owner().name == 'Monk':
					# We set the shader to the animation node that displays the character's idle animation and assisgn the correspondent glow color to it, as in the game.
					show_character_animation_node.material.shader = glow_shader	
					show_character_animation_node.material.set_shader_param("glow_color",  Color(1, 0.74902, 0, 0.286275))
				
				else:
					show_character_animation_node.material.shader = null		
				# We upload the points on screen based in what character is highlighted 
				_put_points(get_focus_owner().name)
	else:
		$CharacterSelection.hide()

func _put_points(character_name):
	# We declare the variables and define these values depending on what character is highlighted 
	var health_points = 0
	var speed_points = 0
	var damage_points = 0
	
	match character_name:
		"Monk":
			health_points = 4
			speed_points = 1
			damage_points = 3				
		"SwampShooter":
			health_points = 2
			speed_points = 1
			damage_points = 4
		"CemeteryHero":
			health_points = 2
			speed_points = 4
			damage_points = 2
		_:
			#Just for prevent errors, _ in a match function is something like 'else'.
			return
	# We reset the visibility of the points to then assign the correct values.
	for children in health_points_node.get_child_count():
		health_points_node.get_child(children).visible = false

	for children in speed_points_node.get_child_count():
		speed_points_node.get_child(children).visible = false
					
	for children in damage_points_node.get_child_count():
		damage_points_node.get_child(children).visible = false
									
	for i in health_points:
		health_points_node.get_child(i).visible = true

	for i in speed_points:
		speed_points_node.get_child(i).visible = true

	for i in damage_points:
		damage_points_node.get_child(i).visible = true			

# We store the selected player and then go to stage selection scene.
func on_character_button_pressed(character):
	yield(get_tree(), "idle_frame")
	GlobalValues.selected_player = character.name
	var _change_scene = get_tree().change_scene(stage_selection.get_path())

func on_mouse_entered(button):
	button.grab_focus()
