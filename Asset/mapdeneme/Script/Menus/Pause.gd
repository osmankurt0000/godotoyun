extends Control

func _ready():
	self.hide()
	# Connect the signals to the buttons, the [button] pass which button has triggered the function.
	for button in $HBoxContainer/VBoxContainer.get_children():
		button.connect("focus_entered", self, "_on_button_focus_entered", [button])
		button.connect("mouse_entered", self, "_on_button_mouse_entered", [button])
		button.connect("focus_exited", self, "_on_button_focus_exited", [button])

func _input(event):
	# FloodTimer is just to control and prevent multiple presses, was happening when I was hitting my joystick start button, so this prevents it to fire multiple times.
	if Input.is_action_just_pressed("pause") and $FloodTimer.is_stopped():
		$FloodTimer.start()
		# This function set pause on/off.
		change_pause_status()
		# if this node is visible, or in other words, the game is paused, grab_focus of the first button.
		if self.visible:
			$HBoxContainer/VBoxContainer/Resume.grab_focus()
			
# This switch between the instructions on screen, if you're manipulating a joypad, then show instructions related to joypad.	
	if event is InputEventJoypadMotion or event is InputEventJoypadButton:
		$HBoxContainer/JoypadController.visible = true
		$HBoxContainer/KeyBoardController.visible = false
	else:
		$HBoxContainer/JoypadController.visible = false
		$HBoxContainer/KeyBoardController.visible = true		
				
func _on_Resume_pressed():
	change_pause_status()

func _on_Restart_pressed():	
	get_tree().paused = false
	GlobalValues.current_level_name = ''
	GlobalValues.current_level = null
	var _restart_level = get_tree().reload_current_scene()

func _on_Exit_pressed():
	yield(get_tree(), "idle_frame")
	get_tree().paused = false
	var _change_scene = get_tree().change_scene("res://Scenes/Menu/MainMenu.tscn")

# We do some animations when a button get focus, giving a better feedback to the player.
func _on_button_focus_entered(button):
	$Tween.interpolate_property(
		button, 
		"rect_scale", 
		button.rect_scale, 
		Vector2(1.5,1.5), 
		.3, 
		Tween.TRANS_SINE, 
		Tween.EASE_OUT)
	$Tween.start()

func _on_button_mouse_entered(button):
	button.grab_focus()

# We do some animations when a button exit focus, giving a better feedback to the player.
func _on_button_focus_exited(button):
	$Tween.interpolate_property(
		button, 
		"rect_scale", 
		button.rect_scale, 
		Vector2(1.0,1.0), 
		.3, 
		Tween.TRANS_SINE, 
		Tween.EASE_OUT)
	$Tween.start()

func change_pause_status():
	# When we pause, we pause everything, so it's important to not pause this node. To do it, go to Inspector > Pause > Mode:Process 
	get_tree().paused = !get_tree().paused
	self.visible = get_tree().paused	
