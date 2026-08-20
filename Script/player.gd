extends CharacterBody2D

@export var speed: float = 120.0
@export var accel: float = 30.0
@export var attack_damage: float = 25.0

@onready var animated_sprite: AnimatedSprite2D = $PlayerSprite
@onready var attack_area: Area2D = $AttackArea

var last_direction: String = "Down"
var is_attacking: bool = false

func _physics_process(delta: float) -> void:
	# Menyerang saat menekan Spasi (ui_accept)
	if Input.is_action_just_pressed("ui_accept") and not is_attacking:
		attack()

	# Jika sedang menyerang, hentikan pergerakan karakter
	if is_attacking:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if input_dir != Vector2.ZERO:
		velocity = velocity.move_toward(input_dir * speed, accel * speed * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, accel * speed * delta)

	move_and_slide()
	update_animation(input_dir)

func attack() -> void:
	is_attacking = true

	# Cari semua body yang berada di dalam AttackArea saat tombol ditekan
	var overlapping_bodies = attack_area.get_overlapping_bodies()
	for body in overlapping_bodies:
		if body != self and body.has_method("take_damage"):
			body.take_damage(attack_damage, global_position)

	# Jeda waktu serang/durasi animasi (misal 0.3 detik)
	await get_tree().create_timer(0.3).timeout
	is_attacking = false

func update_animation(input_dir: Vector2) -> void:
	if is_attacking:
		return

	if input_dir == Vector2.ZERO:
		animated_sprite.play("idle_" + last_direction)
		return

	if abs(input_dir.x) > abs(input_dir.y):
		if input_dir.x > 0:
			last_direction = "Right"
		else:
			last_direction = "Left"
	else:
		if input_dir.y > 0:
			last_direction = "Down"
		else:
			last_direction = "Up"
			
	animated_sprite.play(last_direction)
