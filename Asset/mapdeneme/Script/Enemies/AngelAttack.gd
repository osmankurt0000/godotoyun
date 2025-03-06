extends Area2D

var damage = 1

func _ready():
	$angelatk.play("attack")
	$AnimationPlayer.play("Attack")
	yield($AnimationPlayer,"animation_finished")
	queue_free()

# Trigger when collides with player, call the damage function at the player and pass the damage direction for knockback be applied
func _on_AngelAttack_body_entered(body):
	var damage_direction
	damage_direction = -1 if body.global_position.x < self.global_position.x else 1
	body.damage(damage, damage_direction, self)

