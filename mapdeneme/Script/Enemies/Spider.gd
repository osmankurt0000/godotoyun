extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var contact_damage = 1
export var life = 5

var move_direction = -1
onready var move_speed = 5 * GlobalValues.CELL_SIZE
onready var hurt_knockback = Vector2(4 * GlobalValues.CELL_SIZE, -5 * GlobalValues.CELL_SIZE)

onready var animation_player = $AnimationPlayer
onready var animated_sprite = $Body/Sprite
var velocity = Vector2()
var snap_vector = Vector2.ZERO

func apply_gravity(delta):
	velocity.y += GlobalValues.gravity * delta

func apply_movement(_delta):
	var stop_on_slope = true if get_floor_velocity().x == 0 else false	
	velocity = move_and_slide_with_snap(velocity, snap_vector, Vector2.UP, stop_on_slope,4 , 1)
	snap_vector = Vector2(0,24) if is_on_floor() else Vector2(0,0)
	
	if $StateMachine.state == $StateMachine.states.run and is_on_floor():
		if self.is_on_wall() or not $Body/FloorRaycast.is_colliding():
			move_direction *= -1		

			
	$Body.scale.x = - move_direction
	
func apply_horizontal_movement(_delta):
	velocity.x = move_speed * move_direction

	
func damage(quantity, damage_dealer):
	life -= quantity
	if life <= 0:
		$StateMachine.set_state($StateMachine.states.death)
	else:
		var knockback_direction = -1 if self.global_position < damage_dealer.global_position else 1
		hurt_knockback.x = knockback_direction * abs(hurt_knockback.x)
				
		$StateMachine.set_state($StateMachine.states.hurt)
	
func apply_hurt_knockback():
	snap_vector = Vector2()
	velocity = hurt_knockback	

func _on_CollideWithPlayer_body_entered(body):
	var damage_direction = -1 if body.global_position.x < self.global_position.x else 1
	body.damage(contact_damage, damage_direction, self)

func die():
	$CollisionShape2D.queue_free()
	$CollideWithPlayer/CollisionShape2D.queue_free()
	$Body/Sprite.hide()
	$Body/DeathAnimation.show()
	$Body/DeathAnimation.play("death")
	yield($Body/DeathAnimation,"animation_finished")
	queue_free()

