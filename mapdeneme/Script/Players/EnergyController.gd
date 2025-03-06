extends Node2D

export(Texture) var energy_texture

var energy = 6
var max_energy = 0

var draw_texture_h_separation = 2

# _draw() is a function that is specially good to draw primative shapes, like circles and squares.
# It's also very good to draw repeated textures. 
func _draw():
	# for each energy point we have, we want to draw it on screen.
	for i in range(energy):
		draw_texture_rect_region(energy_texture, Rect2( i * (energy_texture.get_width() + draw_texture_h_separation)  ,0, energy_texture.get_width(), energy_texture.get_height()), Rect2(0,0,energy_texture.get_width(),energy_texture.get_height()))
# Update use/gain of energy on screen
func gain_energy(quantity):
	energy += quantity
	if energy > max_energy:
		energy = max_energy
	# Update calls the _draw() method again, so whenever you wanna use it, call update.
	update()

func use_energy(quantity):
	if energy - quantity >= 0:
		energy -= quantity
		update()
		if $Timer.is_stopped():
			$Timer.start()
			
func _on_Timer_timeout():
	if energy < max_energy:
		gain_energy(1)
	else:
		$Timer.stop()
		
func set_properties(Energy, Max_energy, Recover_interval):
	energy = Energy
	max_energy = Max_energy
	$Timer.wait_time = Recover_interval
	$Timer.start()
	
