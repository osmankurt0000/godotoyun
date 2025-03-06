extends Node2D


export(Texture) var life_texture

var lifes = 0

var draw_texture_h_separation = 2

# _draw() is a function that is specially good to draw primative shapes, like circles and squares.
# It's also very good to draw repeated textures. 
func _draw():
	# for each life point we have, we want to draw it on screen.
	for i in range(lifes):
		draw_texture_rect_region(life_texture, Rect2( i * (life_texture.get_width() + draw_texture_h_separation)  ,0, life_texture.get_width(), life_texture.get_height()), Rect2(0,0,life_texture.get_width(),life_texture.get_height()))

func set_life(quantity):
	lifes = quantity
	# Update calls the _draw() method again, so whenever you wanna use it, call update.
	update()
