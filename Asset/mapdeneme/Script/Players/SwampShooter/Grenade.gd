extends RigidBody2D

export (PackedScene) var explosion_scene

var throw_force = Vector2(110,-40)

var min_torque = 3.0
var max_torque = 150.0

var time_to_explode = 2.5
var damage

func _ready():
	# Randomize the number generator seed.
	randomize()
	$ExplosionTimer.wait_time = time_to_explode
	$ExplosionTimer.start()
	# applied_torque will add some rotation to the node, give a better idea of throwing
	applied_torque = rand_range(min_torque * sign(throw_force.x), max_torque * sign(throw_force.x))
	apply_impulse(Vector2(), throw_force)

func _on_Area2D_body_entered(body):
	if body.has_method("damage"):
		_explode()


func _on_ExplosionTimer_timeout():
	_explode()

func _explode():
	yield(get_tree(),"idle_frame")
	var explosion = explosion_scene.instance()
	explosion.damage = damage
	get_parent().add_child(explosion)
	explosion.global_position = self.global_position
	queue_free()
	
# We add torque but don't want it to affect bounce, so we put to 0 again.	
func _on_StopTorque_timeout():
	applied_torque = 0
