extends CharacterBody2D

@export var SPEED = 300.0
@export var CROUCH_SPEED = 150.0  # Eğilirken yürüme hızı
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var is_attacking = false
var is_defending = false  # Savunma durumu ekliyoruz
var health = 100  # Karakterin başlangıç sağlığı
var max_health = 100  # Karakterin maksimum sağlığı
var is_dead = false  # Ölüm durumu ekliyoruz
var is_crouching = false  # Eğilme durumu

# Zıplama ve yer çekimi değişkenleri
var gravity = 1000  # Yer çekimi
var jump_force = -350  # Zıplama kuvveti (negatif yukarı doğru)

func _physics_process(delta: float) -> void:
	if is_dead:
		return  # Ölüm animasyonu oynarken hareket etmeyeceğiz
	
	# E tuşuna basıldığında savunma modu
	if Input.is_action_just_pressed("defense") and not is_attacking:
		animated_sprite_2d.play("defense")  # Savunma animasyonunu başlat
		is_defending = true
		return
	
	# Savunma animasyonu bitince savunmayı durdur
	if is_defending and animated_sprite_2d.animation == "defense" and animated_sprite_2d.frame == animated_sprite_2d.sprite_frames.get_frame_count("defense") - 1:
		is_defending = false

	# Savunmadayken başka işlemleri durdur
	if is_defending:
		return

	# Saldırı kontrolü
	if Input.is_action_just_pressed("attack"):
		animated_sprite_2d.play("attack")
		is_attacking = true
		return
	
	# Saldırı animasyonu bittiğinde saldırıyı durdur
	if is_attacking and animated_sprite_2d.animation == "attack" and animated_sprite_2d.frame == animated_sprite_2d.sprite_frames.get_frame_count("attack") - 1:
		is_attacking = false
		
	if is_attacking:
		return

	# Eğilme işlemi
	is_crouching = Input.is_action_pressed("crouch")
	
	# Zıplama işlemi
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_force  # Zıplama kuvvetini uygula
	
	# Yer çekimi
	if not is_on_floor():
		velocity.y += gravity * delta

	# Hareket ve yön kontrolü
	var direction := Input.get_vector("left", "right", "up", "down")
	
	# Eğilirken yürüyebilme
	if is_crouching:
		# Eğilme animasyonu
		if direction.x != 0:
			animated_sprite_2d.play("crouch_walk")  # Eğilerek yürüme animasyonu
		else:
			animated_sprite_2d.play("crouch")  # Eğilme animasyonu
		# Eğilirken yavaş hareket et
		velocity.x = direction.x * CROUCH_SPEED
	else:
		# Normal hareket ve animasyonlar
		if direction == Vector2.ZERO:
			animated_sprite_2d.play("osman")  # Karakter hareket etmiyorsa 'osman' animasyonunu oynat
		else:
			# X ve Y yönlerine göre bedeni döndürme
			if direction.x < 0:
				animated_sprite_2d.flip_h = true  # Sola hareket ediyorsa karakteri ters çevir
			else:
				animated_sprite_2d.flip_h = false  # Sağa hareket ediyorsa karakteri normale çevir

			if direction.y < 0:
				animated_sprite_2d.play("jump_up")  # Zıplama yukarı yönünde ise yukarı zıplama animasyonu
			elif direction.y > 0:
				animated_sprite_2d.play("jump_down")  # Zıplama aşağı yönünde ise aşağı zıplama animasyonu
			else:
				animated_sprite_2d.play("run")  # Koşma animasyonu
		# Normal hızda hareket et
		velocity.x = direction.x * SPEED
	
	# Karakteri hareket ettir
	move_and_slide()

# Sağlık azaldığında ölüm animasyonu oynatılır
func take_damage(damage_amount: int) -> void:
	if is_dead:
		return  # Eğer zaten ölü ise, hasar almaz

	health -= damage_amount
	if health <= 0:
		die()  # Sağlık sıfıra düştü, ölümü tetikle
	
func die() -> void:
	is_dead = true  # Ölüm durumunu aktifleştir
	animated_sprite_2d.play("dead")  # Ölüm animasyonunu başlat

	# Ölüm animasyonu bittiğinde karakteri durdurabiliriz
	# Bu kısmı animasyonun bitimine göre kontrol edebiliriz
	if animated_sprite_2d.animation == "dead" and animated_sprite_2d.frame == animated_sprite_2d.sprite_frames.get_frame_count("dead") - 1:
		queue_free()  # Ölüm animasyonu bittiğinde karakteri sahneden kaldır

# Canı yenilemek için bir fonksiyon
func heal(amount: int) -> void:
	if is_dead:
		return  # Eğer ölü ise iyileşme yapma
	
	health += amount
	if health > max_health:
		health = max_health  # Sağlık maksimum değeri aşmasın
