extends CharacterBody2D

# Değişkenler
@export var speed : float = 100.0  # Düşmanın normal hızı
@export var attack_speed : float = 150.0  # Düşmanın saldırı hızı
@export var patrol_range : float = 1000.0  # Düşmanın devriye aralığı
@export var attack_range : float = 200.0  # Saldırı menzili
@export var attack_damage : int = 10  # Saldırı hasarı

var direction = 1  # Düşmanın yönü (1: sağ, -1: sol)
var initial_position : Vector2  # Düşmanın başlangıç pozisyonu
var player_in_range = false  # Oyuncunun saldırı alanında olup olmadığını kontrol eder
var player : Node2D = null  # Oyuncu referansı

# Area2D kullanımı için alanı tanımla
@onready var detection_area : Area2D = $Area2D
@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D  # Animasyon kontrolcüsü

func _ready():
	initial_position = position  # Düşmanın ilk pozisyonunu kaydet
	detection_area.body_entered.connect(_on_area_body_entered)
	detection_area.body_exited.connect(_on_area_body_exited)

func _physics_process(delta):
	if player_in_range and player != null:
		# Eğer oyuncu menzildeyse, saldırıyı kontrol et
		if position.distance_to(player.position) <= attack_range:
			# Eğer oyuncu saldırı menzilindeyse, saldırıya geç
			move_towards_player(delta)
		else:
			# Eğer oyuncu saldırı menzilinde değilse, ona doğru yaklaş
			move_closer_to_player(delta)
	else:
		# Eğer oyuncu menzilde değilse, devriye gez
		patrol(delta)

func patrol(delta):
	# Düşman devriye yapar (sağa sola gider)
	var next_position = position.x + direction * speed * delta
	
	# Devriye aralığına ulaştığında yön değiştir
	if abs(next_position - initial_position.x) >= patrol_range:
		direction *= -1

	# Karakterin yönüne göre animasyonu çevir
	if direction > 0:
		animated_sprite.flip_h = false  # Sağa giderken sağa bak
	else:
		animated_sprite.flip_h = true  # Sola giderken sola bak

	# Düşmanı hareket ettir
	velocity = Vector2(direction * speed, 0)
	move_and_slide()

	# Eğer düşman hareket ediyorsa koşma animasyonu oynamalı
	if !animated_sprite.is_playing() or animated_sprite.animation != "run":
		animated_sprite.play("run")

func move_closer_to_player(delta):
	# Oyuncuya doğru yaklaş
	var direction_to_player = (player.position - position).normalized()
	velocity = direction_to_player * speed
	move_and_slide()

	# Karakterin oyuncuya göre yönünü ayarla
	if direction_to_player.x > 0:
		animated_sprite.flip_h = false  # Oyuncu sağdaysa sağa bak
	else:
		animated_sprite.flip_h = true  # Oyuncu soldaysa sola bak

	# Koşma animasyonu oynamalı
	if !animated_sprite.is_playing() or animated_sprite.animation != "run":
		animated_sprite.play("run")

func move_towards_player(delta):
	# Oyuncuya saldırı yap
	var direction_to_player = (player.position - position).normalized()
	velocity = direction_to_player * attack_speed
	move_and_slide()

	# Karakterin oyuncuya göre yönünü ayarla
	if direction_to_player.x > 0:
		animated_sprite.flip_h = false  # Oyuncu sağdaysa sağa bak
	else:
		animated_sprite.flip_h = true  # Oyuncu soldaysa sola bak

	# Saldırı animasyonu oynamalı
	if !animated_sprite.is_playing() or animated_sprite.animation != "attack":
		animated_sprite.play("attack")

	# Oyuncuya çarpıp çarpmadığını kontrol et
	if position.distance_to(player.position) <= attack_range:
		attack_player()

func attack_player():
	if player != null:
		# Oyuncuya hasar ver
		print("Player is hit!")  # Bu çıktıyı kontrol et
		player.take_damage(attack_damage)  # Bu fonksiyon oyuncu scriptinde tanımlı olmalı

# Alan içine oyuncu girdiğinde tetiklenen fonksiyon
func _on_area_body_entered(body: Node):
	if body.name == "osman":
		player_in_range = true
		player = body as Node2D
		# Alan içerisine girdiğinde, hemen saldırıyı kontrol et
		if position.distance_to(player.position) <= attack_range:
			move_towards_player(0)  # Hemen saldırıya başla

# Alan dışına oyuncu çıktığında tetiklenen fonksiyon
func _on_area_body_exited(body: Node):
	if body.name == "osman":
		player_in_range = false
		player = null
		# Düşman devriye yaparken koşma animasyonuna geri döner
		animated_sprite.play("run")

	# Düşman alan dışına çıktığında yönünü kontrol et
	# Devriye işlemi sırasında yön değişimini kontrol et
	if direction > 0:
		animated_sprite.flip_h = false
	else:
		animated_sprite.flip_h = true
