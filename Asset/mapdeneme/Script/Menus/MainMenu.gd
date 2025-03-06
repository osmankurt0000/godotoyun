extends Control

# We grab the focus of the first button, to enable navigation from joystick.
func _ready():
	$Bg/VBoxContainer/Play.grab_focus()
	pass # Replace with function body.

# set_locale changes the game language, based in a csv file located at res://Localization/localization.csv
# If you desire to deepen on it, check: https://docs.godotengine.org/en/3.2/getting_started/workflow/assets/importing_translations.html
func _on_Usa_pressed():
	TranslationServer.set_locale('en')

func _on_Brazil_pressed():
	TranslationServer.set_locale('pt_br')

# get_tree().quit() just close the game.
func _on_Exit_pressed():
	get_tree().quit()


func _on_Credits_pressed():
	pass # Replace with function body.

# We go into character selection scene
func _on_Play_pressed():
	yield(get_tree(), "idle_frame")
	var _change_scene = get_tree().change_scene("res://Scenes/Menu/CharacterSelection.tscn")
