extends KinematicBody2D

var contact_damage = 1
var life = 1

const EMISSION_TEXTURES = {
	'idle': preload("res://Sprites/Gothicvania/Characters/Enemies/Fill/Demon/demon-idle-emission-mask.png"), 
	'attack': preload("res://Sprites/Gothicvania/Characters/Enemies/Fill/Demon/demon-attack-emission-mask.png")
		}
		
var fire_damage = 2
func _ready():
	$Body/Sprite.material.set_shader_param("emission_texture",  EMISSION_TEXTURES['idle'])

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
	$Body/FireAttack.queue_free()
	$AttackTimer.queue_free()
	$Body/Sprite.hide()
	$Body/DeathAnimation.show()
	$Body/DeathAnimation.play("death")
	yield($Body/DeathAnimation,"animation_finished")
	queue_free()


func _on_AttackTimer_timeout():
	$Body/Sprite.play("attack")
	$Body/Sprite.material.set_shader_param("emission_texture",  EMISSION_TEXTURES['attack'])
	
func _on_Sprite_animation_finished():
	if $Body/Sprite.animation == 'attack':
		$Body/Sprite.play("idle")
		$Body/Sprite.material.set_shader_param("emission_texture",  EMISSION_TEXTURES['idle'])

func _on_Sprite_frame_changed():
	if $Body/Sprite.animation == 'attack':
		if $Body/Sprite.frame == 6 and $Body/Sprite.visible:
			$Body/FireAttack.monitorable = true
			$Body/FireAttack.monitoring = true
		elif $Body/Sprite.frame == 10 and $Body/Sprite.visible:
			$Body/FireAttack.monitorable = false
			$Body/FireAttack.monitoring = false			


func _on_FireAttack_body_entered(body):
	if body.has_method("damage"):
		var damage_direction
		damage_direction = -1 if body.global_position.x < self.global_position.x else 1
		body.damage(fire_damage, damage_direction, self)

