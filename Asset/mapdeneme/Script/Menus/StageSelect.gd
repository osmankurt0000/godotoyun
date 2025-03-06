extends Control

var miniature_shader = preload("res://Shaders/BlackAndWhite.shader")
# We declare some long paths into variables to make it looks clear.
onready var LevelButtons = [$VBoxContainer/HBoxContainer/Church, $VBoxContainer/HBoxContainer/GothicHorror, $VBoxContainer/HBoxContainer/OldDarkCastle, $VBoxContainer/HBoxContainer2/Swamp, $VBoxContainer/HBoxContainer2/Cemetery]
# Called when the node enters the scene tree for the first time.
func _ready():
	# We grab the focus of the first button, to enable navigation from joystick.
	LevelButtons[0].grab_focus() 
	# Connect the signals to the buttons, the [node] pass which button has triggered the function.
	for node in LevelButtons:
		node.connect("mouse_entered", self, "on_mouse_entered",[node])
	pass # Replace with function body.


func _process(_delta):
	# Remember grab_focus? get_focus_owner shows who has the focus.
	if get_focus_owner() != null:
		$StageSelectCursor.show()
		var focus_owner = get_focus_owner()	
		$StageSelectCursor.global_position = focus_owner.rect_global_position
		# We don't want black and white shader on the focused button, so when a button has the focus, we remove from it but keeps on the other buttons
		for button in LevelButtons:
			if button == focus_owner:
				button.material.shader = null
			else:
				button.material.shader = miniature_shader
	else:
		$StageSelectCursor.hide()

func on_mouse_entered(button):
	button.grab_focus()
