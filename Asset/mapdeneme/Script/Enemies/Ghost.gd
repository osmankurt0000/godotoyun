extends KinematicBody2D


var contact_damage = 1

var life = 1
onready var speed = 3 * GlobalValues.CELL_SIZE
onready var disappearance_timer = $DisappearenceTimer

var max_circle_radius = 125
var min_circle_radius = 25
	
var disappearance_time = 4.0

func _ready():
	$DisappearenceTimer.wait_time = disappearance_time	
	
func assign_animation(animation_name):
	$Body/Sprite.play(animation_name)


func _on_CollideWithPlayer_body_entered(body):
	var damage_direction = -1 if body.global_position.x < self.global_position.x else 1
	body.damage(contact_damage, damage_direction, self)
	
	
func damage(quantity, _damage_dealer):
	life -= quantity
	if life <= 0:
		$StateMachine.set_state($StateMachine.states.death)
	
func die():
	$CollisionShape2D.queue_free()
	$CollideWithPlayer/CollisionShape2D.queue_free()
	$Body/Sprite.hide()
	$Body/DeathAnimation.show()
	$Body/DeathAnimation.play("death")
	yield($Body/DeathAnimation,"animation_finished")
	queue_free()
	
func get_random_circle_point():
	randomize()
	var angle = randf() * 2 * PI
	var direction = Vector2(cos(angle ), sin(angle ))
	var target_position = self.global_position + direction * rand_range(min_circle_radius ,max_circle_radius)

	if GlobalValues.current_level != null:
		if target_position.y < GlobalValues.current_level.level_limit_top:
			target_position.y = GlobalValues.current_level.level_limit_top 
			
		elif target_position.y > GlobalValues.current_level.level_limit_bottom:
			target_position.y = GlobalValues.current_level.level_limit_bottom


		if target_position.x < GlobalValues.current_level.level_limit_left:
			target_position.x = GlobalValues.current_level.level_limit_left 
			
		elif target_position.x > GlobalValues.current_level.level_limit_right:
			target_position.x = GlobalValues.current_level.level_limit_right

	$Body/Sprite.flip_h = true if target_position > global_position else false
	return target_position

func move_to(_delta, target):
	var target_direction = (target - global_position).normalized()
	var _movement = move_and_slide(target_direction * speed)
	if global_position.distance_to(target) < 10:
		return true

	return false

func disappear():
	$CollideWithPlayer/CollisionShape2D.disabled = true
	$CollisionShape2D.disabled = true

func appear():
	$CollideWithPlayer/CollisionShape2D.disabled = false
	$CollisionShape2D.disabled = false
			
func _on_Sprite_animation_finished():
	if $Body/Sprite.animation == 'spook' and !$StateMachine.state == $StateMachine.states.death:
		$StateMachine.set_state($StateMachine.states.disappear)

	if $Body/Sprite.animation == 'appear' and !$StateMachine.state == $StateMachine.states.death:
		$StateMachine.set_state($StateMachine.states.idle)


func connect_visibility_on_ready():
	var visibility_notifier = VisibilityNotifier2D.new()
	add_child(visibility_notifier)
	visibility_notifier.connect("screen_entered", self, "_on_VisibilityNotifier2D_screen_entered")

func _on_VisibilityNotifier2D_screen_entered():
	$StateMachine.set_state($StateMachine.states.idle)
