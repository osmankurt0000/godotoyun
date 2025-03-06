extends Area2D

var damage

func _ready():
	$AnimatedSprite.playing = true

func _on_GrenadeExplosion_body_entered(body):
	if body.has_method("damage"):
		body.damage(damage, self)
		
func _on_AnimatedSprite_animation_finished():
	queue_free()
