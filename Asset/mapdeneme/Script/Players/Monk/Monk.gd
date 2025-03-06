extends BaseCharacterScript

# We preload all the emission textures to have the glow shader works.
const EMISSION_TEXTURES = {
	"idle": 	preload("res://Sprites/Gothicvania/Characters/Player/Monk/idle-emission.png"),
	"crouch": 	preload("res://Sprites/Gothicvania/Characters/Player/Monk/crouch-emission.png"),
	"crouch-kick": preload("res://Sprites/Gothicvania/Characters/Player/Monk/crouch-kick-emission.png"),
	"fall": 	preload("res://Sprites/Gothicvania/Characters/Player/Monk/fall-emission.png"),
	"flying-kick": preload("res://Sprites/Gothicvania/Characters/Player/Monk/flying-kick-emission.png"),
	"hurt": 	preload("res://Sprites/Gothicvania/Characters/Player/Monk/hurt-emission.png"),
	"jump": 	preload("res://Sprites/Gothicvania/Characters/Player/Monk/jump-emission.png"),
	"kick": 	preload("res://Sprites/Gothicvania/Characters/Player/Monk/kick-emission.png"),
	"walk": 	preload("res://Sprites/Gothicvania/Characters/Player/Monk/walk-emission.png"),
	"punch":	preload("res://Sprites/Gothicvania/Characters/Player/Monk/punch-emission.png"),
	"pre-punch":	preload("res://Sprites/Gothicvania/Characters/Player/Monk/punch-emission.png")
}
# We store some paths in variables to easy acess
onready var pre_punch_particle_node = $Body/PrePunchParticle
onready var punch_particle_node = $Body/PunchParticle
onready var kick_attack_collision = $Body/KickAttackCollision
onready var crouch_kick_attack_collision = $Body/CrouchKickAttackCollision
onready var punch_attack_collision = $Body/PunchAttackCollision
onready var flying_kick_attack_collision = $Body/FlyingKickAttackCollision

# We define how many units we want to move when we Jump
onready var max_jump_height = 3.25 * GlobalValues.CELL_SIZE
onready var min_jump_height = 1.25 * GlobalValues.CELL_SIZE

# We define how many units we want to move back when we hit an enemy at air
onready var flying_kick_bump = Vector2(6 * GlobalValues.CELL_SIZE, -7 * GlobalValues.CELL_SIZE)

# Control extra damage and charge limits to punch attack.
var charged_time = 0.1	
var charged_attack_multiplier = 4
var max_charge_time = 3

# Damages

var flying_kick_damage = 5	
var kick_damage = 3
var crouch_kick_damage = 3
var punch_damage = 5	
	
func _ready():
	# We define some generic variables that BaseCharacterScript class has and may vary on inherited ones.
	life = 9
	energy = 4
	max_energy = 6
	recover_energy_timer = 5
	hurt_knockback = Vector2(5 * GlobalValues.CELL_SIZE, -8 * GlobalValues.CELL_SIZE)	
	move_speed =  5.5 * GlobalValues.CELL_SIZE	
	# We got our jump_velocity based on the global settings, like gravity and etc.
	var jump_velocity = GlobalValues.get_jump_velocity(max_jump_height, min_jump_height)
	max_jump_velocity = jump_velocity[0]
	min_jump_velocity = jump_velocity[1]
	# Update life and energy HUDs.
	_set_life(life)
	energy_controller_node.set_properties(energy, max_energy, recover_energy_timer)	


# We get the move direction and set the sprite scale to that direction
func handle_movement_input(_delta):
	move_direction = - int(Input.is_action_pressed("move_left")) + int(Input.is_action_pressed("move_right"))
	if move_direction != 0 and !$StateMachine.state == $StateMachine.states.flying_kick:
		player_body.scale.x = move_direction	

# Get the time that we holded the button
func charged_attack(delta):
	if charged_time < 2:
		pre_punch_particle_node.lifetime = charged_time
	if charged_time <= max_charge_time:
		charged_time += delta

# Assign an animation to play, it's important in this case that both the animation name and emission texture have the same name.
func assign_animation(animation_name):
	_adjust_animation_collision_shape(animation_name)
	player_sprite_node.play(animation_name)
	player_sprite_node.material.set_shader_param("emission_texture",  EMISSION_TEXTURES[animation_name])

# We adjust the collision shape to match the current animation
func _adjust_animation_collision_shape(animation_name):
	match animation_name:
		"idle", "walk", "pre-punch","punch", "kick", "fall", "jump", "flying-kick":
			collision_shape.shape.radius = 7
			collision_shape.shape.height = 28
			collision_shape.position = Vector2(-1,-21)			
		"crouch", "crouch-kick":
			collision_shape.shape.radius = 10
			collision_shape.shape.height = 10
			collision_shape.position = Vector2(-1,-15)

# Check when we hit an enemy and then apply damage
func _on_KickAttackCollision_body_entered(body):
	if body.has_method("damage"):
		body.damage(kick_damage, self)

func _on_CrouchKickAttackCollision2_body_entered(body):
	if body.has_method("damage"):
		body.damage(crouch_kick_damage, self)

func _on_PunchAttackCollision_body_entered(body):
	if body.has_method("damage"):
		var damage = punch_damage + int(charged_time * charged_attack_multiplier)
		body.damage(damage, self)

func _on_FlyingKickAttackCollision_body_entered(body):
	if velocity.y > 0:
		var damage_direction = -1 if self.global_position.x <= body.global_position.x else 1
		flying_kick_bump.x = damage_direction * abs(flying_kick_bump.x)
		velocity = flying_kick_bump
	if body.has_method("damage"):
		body.damage(flying_kick_damage, self)
	
