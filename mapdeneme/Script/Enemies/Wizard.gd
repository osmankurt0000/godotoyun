extends KinematicBody2D

export (PackedScene) var fireball_scene

var contact_damage = 1
var life = 1

func _on_CollideWithPlayer_body_entered(body):
	var damage_direction = -1 if body.global_position.x < self.global_position.x else 1
	body.damage(contact_damage, damage_direction, self)

func damage(quantity, _damage_dealer):
	life -= quantity
	if life <= 0:
		die()
	
func die():
	set_physics_process(false)
	$CollisionShape2D.queue_free()
	$CollideWithPlayer/CollisionShape2D.queue_free()
	$AttackTimer.queue_free()
	$Body/Sprite.hide()
	$Body/DeathAnimation.show()
	$Body/DeathAnimation.play("death")
	yield($Body/DeathAnimation,"animation_finished")
	queue_free()


func _on_AttackTimer_timeout():
	$Body/Sprite.play("attack")

func _on_Sprite_animation_finished():
	if $Body/Sprite.animation == 'attack':
		$Body/Sprite.play("idle")


func _on_Sprite_frame_changed():
	if $Body/Sprite.animation == 'attack':
		if $Body/Sprite.frame == 7 and $Body/Sprite.visible:
			var attack = fireball_scene.instance()
			attack.global_position = $Body/HandFireballPos.global_position
			get_parent().add_child(attack)
