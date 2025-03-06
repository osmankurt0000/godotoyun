extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var damage
var live = true
var direction = Vector2(1,0)
var speed = 18 * GlobalValues.CELL_SIZE
func _physics_process(delta):
	if live:
		translate(direction * speed * delta )

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

# That was detecting some one_way shapes so we wanted to avoid it, like bridges.
# Knowing that TileMaps are treated like physicsBodies but doesn't are to easy to access it's properties when collided
# We needed to achieve the cell that is colliding and achieve it shape data.
func _on_SwampShooterProjectile_body_shape_entered(_body_id, body, body_shape, _area_shape):
	if body is TileMap:
		var tileset = body.tile_set
		var cell = body.get_used_cells()[body_shape]
		var tile = body.get_cellv(cell)
		for shape_data in tileset.tile_get_shapes(tile):
			if shape_data['one_way'] == true:
				return
				
	if body.has_method("damage"):
		live = false
		body.damage(damage, self)
	queue_free()
