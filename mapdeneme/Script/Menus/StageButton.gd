extends TextureButton

# This shows a screenshoot of the selected level in the background.
export (Texture) var stage_big_image
# We store the level that represents this button in this variable to change to it when selected.
export (PackedScene) var packed_level
# We got the nodes in variables to easy our task in navigating into it.
onready var BgNode = get_owner().get_node("Bg")
onready var BgTransitionNode = get_owner().get_node("BgTransition")
onready var TweenNode = get_owner().get_node("Tween")
onready var LevelNameNode = get_owner().get_node("VBoxContainer/LevelName")
# We connect this button automatically, so it's just drag and drop this script at the button.
func _ready():
	var _connect_focus = connect("focus_entered", self, "_on_button_focus_entered")
	var _connect_pressed = connect("pressed", self, "_on_button_pressed")

# We do some animations when we changes the focus button.	
func _on_button_focus_entered():
	TweenNode.stop_all()
	BgTransitionNode.texture = stage_big_image
	TweenNode.interpolate_property(
		BgNode,
		"modulate",
		BgNode.modulate,
		Color(1,1,1,0.4),
		0.2,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN )
	TweenNode.start()
	yield(TweenNode,"tween_completed")		
	BgNode.texture = stage_big_image
	LevelNameNode.text = self.name
	BgNode.modulate = Color(1,1,1,1)

# Change the scene to the level stored in this button.
func _on_button_pressed():
	yield(get_tree(), "idle_frame")
	var _change_scene = get_tree().change_scene(packed_level.get_path())

