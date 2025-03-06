extends Area2D


var direction = Vector2.LEFT
var speed = 200
var damage = 1
func _physics_process(delta):
	translate(direction * speed * delta)


func _on_Fireball_body_entered(body):
	set_physics_process(false)
	$AnimationPlayer.play("Disappear")
	if body.has_method("damage"):
		var damage_direction
		damage_direction = -1 if body.global_position.x < self.global_position.x else 1
		body.damage(damage, damage_direction, self)
	
