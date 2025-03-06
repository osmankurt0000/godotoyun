extends Node2D

class_name Level

var level_limit_top = 0
var level_limit_bottom = 0
var level_limit_left = 0
var level_limit_right = 0

var player = null
var got_level_checkpoint = false

func _ready():
	# If we changed the level, we reset the checkpoint to avoid undesired behaviors.
	if GlobalValues.current_level_name != self.name and GlobalValues.level_checkpoint_achieved == true:
		GlobalValues.level_checkpoint_achieved = false
	
	# We update some global variables.	
	GlobalValues.current_level = self
	GlobalValues.current_level_name = self.name
	# We do some verifications, good when creating new levels to get sure that we aren't forgeting anything.
	if self.has_node("EndLevel"):
		# ONESHOT is something like, call just one time, them don't call it anymore.
		var _connect_end_level_signal = $EndLevel.connect("body_entered", self, "_on_player_finished_level", [], CONNECT_ONESHOT)
	else:
		print('Error: Missing EndLevel node on scene: ' + self.name)
	
	if !self.has_node("Tilemaps/EndLevelExtraPath"):
		print('Error: Missing Tilemaps/EndLevelExtraPath node, this may results in undesired situations at the end of the level, verify!')

	if self.has_node("Checkpoint"):
		var _connect_checkpoint = $Checkpoint.connect("body_entered", self, "_on_checkpoint_body_entered", [], CONNECT_ONESHOT)		
		if GlobalValues.level_checkpoint_achieved:
			instance_player($Checkpoint.global_position)
		else:
			instance_player()
			
	else:
		print('Error: Missing Checkpoint node, you really want that?')

	_set_player_camera_limits()	
	
# We got the main tilemap to represent the limits of the camera movement.
func _set_player_camera_limits():
	var map_size = $Tilemaps/Ground.get_used_rect()
	var cell_size = $Tilemaps/Ground.cell_size
	player.get_node("Camera2D").limit_left = map_size.position.x * cell_size.x	
	player.get_node("Camera2D").limit_top = map_size.position.y * cell_size.y
	player.get_node("Camera2D").limit_right = map_size.end.x * cell_size.x 
	player.get_node("Camera2D").limit_bottom = map_size.end.y * cell_size.y
	
	level_limit_top  = player.get_node("Camera2D").limit_top
	level_limit_bottom = player.get_node("Camera2D").limit_bottom
	level_limit_left = player.get_node("Camera2D").limit_left
	level_limit_right = player.get_node("Camera2D").limit_right

func instance_player(instance_position = null):
	if GlobalValues.selected_player != null:
		var load_player = load("res://Scenes/PlayableCharacters/" + str(GlobalValues.selected_player) + ".tscn")
		player = load_player.instance()
		
		if get_node("SpawnPosition") == null:
			print('Error: SpawnPosition node missing on scene: ' + self.name)
		else:
			add_child(player)
			if instance_position:
				player.global_position = instance_position
			else:
				player.global_position = get_node("SpawnPosition").global_position
		
	else:
		# Since we pass a string to determine what player we picked on character_selection, this helps when there is no one, so we assign a default.
		print("Error: None character selected, loaded Monk instead")
		GlobalValues.selected_player = 'Monk'
		var load_player = load("res://Scenes/PlayableCharacters/" + str(GlobalValues.selected_player) + ".tscn")
		player = load_player.instance()
		
		if get_node("SpawnPosition") == null:
			print('Error: SpawnPosition node missing on scene: ' + self.name)
		else:
			add_child(player)
			player.global_position = get_node("SpawnPosition").global_position

func _on_player_finished_level(body):
	body.end_level()

func _on_checkpoint_body_entered(_body):
	GlobalValues.level_checkpoint_achieved = true
	pass
