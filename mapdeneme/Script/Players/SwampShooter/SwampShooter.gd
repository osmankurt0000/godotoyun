extends BaseCharacterScript

export (PackedScene) var shoot_projectile
export (PackedScene) var grenade_scene

# We define how many units we want to move when we Jump
onready var max_jump_height = 3.55  * GlobalValues.CELL_SIZE
onready var min_jump_height = 1.45 * GlobalValues.CELL_SIZE

# Damages

var shoot_damage = 4
var grenade_explosion_damage = 12
	
func _ready():
	# We define some generic variables that BaseCharacterScript class has and may vary on inherited ones.
	life = 5
	energy = 2
	max_energy = 2
	recover_energy_timer = 5
	
	# We define how many units we want to move when we do movement.
	move_speed =  5 * GlobalValues.CELL_SIZE
	hurt_knockback = Vector2(5 * GlobalValues.CELL_SIZE, -8 * GlobalValues.CELL_SIZE)

	# We got our jump_velocity based on the global settings, like gravity and etc.
	var jump_velocity = GlobalValues.get_jump_velocity(max_jump_height, min_jump_height)
	max_jump_velocity = jump_velocity[0]
	min_jump_velocity = jump_velocity[1]
	# Update life and energy on HUD.
	_set_life(life)
	energy_controller_node.set_properties(energy, max_energy, recover_energy_timer)	


			
# We get the move direction and set the sprite scale to that direction
func handle_movement_input(_delta):
	move_direction = - int(Input.is_action_pressed("move_left")) + int(Input.is_action_pressed("move_right"))
	if move_direction != 0:
		player_body.scale.x = move_direction	

# Assign an animation to play, it's important in this case that both the animation name and emission texture have the same name.
func assign_animation(animation_name):
	_adjust_animation_collision_shape(animation_name)
	player_sprite_node.play(animation_name)
	
# We adjust the collision shape to match the current animation
func _adjust_animation_collision_shape(animation_name):
	match animation_name:
		"idle", "run", "attack", "fall", "jump":
			collision_shape.shape.radius = 8
			collision_shape.shape.height = 30
			collision_shape.position = Vector2(-2,-23)			
		"crouch", "crouch-attack":
			collision_shape.shape.radius = 8
			collision_shape.shape.height = 16
			collision_shape.position = Vector2(-2,-16)

func _on_Sprite_frame_changed():
	if player_sprite_node.animation == 'shoot' and player_sprite_node.frame == 1:
		_shoot($Body/ShootPosUp)
	elif player_sprite_node.animation == 'crouch-shoot' and player_sprite_node.frame == 1:
		_shoot($Body/ShootPosCrouch)
	
func _shoot(pos):
	#We trace raycast to prevents shooting inside a wall.
	if pos == $Body/ShootPosUp and $Body/CheckGunWallCollision.is_colliding():
		# That was detecting some one_way shapes so we wanted to avoid it.
		# Knowing that TileMaps are treated like physicsBodies but doesn't are to easy to access it's properties when collided
		# We needed to achieve the cell that is colliding and achieve it shape data.
		if $Body/CheckGunWallCollision.get_collider() is TileMap:
			var tileset = $Body/CheckGunWallCollision.get_collider().tile_set
			var cell = $Body/CheckGunWallCollision.get_collider().get_used_cells()[$Body/CheckGunWallCollision.get_collider_shape()]
			var tile = $Body/CheckGunWallCollision.get_collider().get_cellv(cell)
			for shape_data in tileset.tile_get_shapes(tile):
				if shape_data['one_way'] == true:
					pass
				else:
					return
		else:
			return
	elif pos == $Body/ShootPosCrouch and $Body/CheckGunWallCollisionCrouch.is_colliding():
		if $Body/CheckGunWallCollisionCrouch.get_collider() is TileMap:
			var tileset = $Body/CheckGunWallCollisionCrouch.get_collider().tile_set
			var cell = $Body/CheckGunWallCollisionCrouch.get_collider().get_used_cells()[$Body/CheckGunWallCollision.get_collider_shape()]
			var tile = $Body/CheckGunWallCollisionCrouch.get_collider().get_cellv(cell)
			for shape_data in tileset.tile_get_shapes(tile):
				if shape_data['one_way'] == true:
					pass
				else:
					return
		else:
			return
		
	var shoot = shoot_projectile.instance()
	shoot.damage = shoot_damage
	shoot.scale.x = player_body.scale.x
	shoot.direction.x = shoot.scale.x
	get_parent().add_child(shoot)
	shoot.global_position = pos.global_position
	
func throw_grenade():
	consume_energy(1)
	var grenade = grenade_scene.instance()
	grenade.throw_force.x *= player_body.scale.x
	grenade.damage = grenade_explosion_damage
	get_parent().add_child(grenade)
	grenade.global_position = $Body/GrenadePos.global_position
