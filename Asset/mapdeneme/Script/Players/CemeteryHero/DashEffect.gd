extends Sprite

# Apply a quick effect based on what function should be reproduced, called by the CemeteryHero.gd script
func dash_effect():
	$alpha_tween.interpolate_property(self, "modulate", Color(1,1,1,0.6), Color(1,1,1,0), .3, Tween.TRANS_SINE, Tween.EASE_OUT)
	$alpha_tween.start()
	
func return_dash_effect():
	$alpha_tween.interpolate_property(self, "modulate", Color(0, 0.976471, 1, 0.67), Color(1,1,1,0), .5, Tween.TRANS_SINE, Tween.EASE_OUT)
	$alpha_tween.start()
# When completes the animation, queue_free the object.
func _on_alpha_tween_tween_completed(_object, _key):
	queue_free()
