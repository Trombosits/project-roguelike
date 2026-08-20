extends CharacterBody2D

@export var speed: float = 80.0
@export var health: float = 100.0
@export var knockback_force: float = 250.0 # Kekuatan pentalan

var dead: bool = false
var is_hit: bool = false
var player: Node2D = null

func _physics_process(delta: float) -> void:
	if dead:
		return

	# Jika terkena serangan, jalankan pergerakan knockback
	if is_hit:
		# Kurangi kecepatan pentalan secara bertahap hingga berhenti (friction)
		velocity = velocity.move_toward(Vector2.ZERO, 600.0 * delta)
		move_and_slide()
		return

	if player:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * speed
		$AnimatedSprite2D.play("move")
	else:
		velocity = Vector2.ZERO
		$AnimatedSprite2D.play("idle_move")

	move_and_slide()

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == player:
		player = null

# Parameter attacker_pos opsional untuk menentukan arah pentalan yang presisi
func take_damage(damage: float, attacker_pos: Vector2 = Vector2.ZERO) -> void:
	if dead:
		return

	health -= damage

	# Hitung vektor arah menjauh dari penyerang
	var knockback_dir = Vector2.ZERO
	if attacker_pos != Vector2.ZERO:
		knockback_dir = (global_position - attacker_pos).normalized()
	elif player:
		knockback_dir = (global_position - player.global_position).normalized()
	
	if health <= 0:
		death()
	else:
		play_hit_animation(knockback_dir)

func play_hit_animation(knockback_dir: Vector2) -> void:
	is_hit = true
	velocity = knockback_dir * knockback_force # Beri dorongan instan
	$AnimatedSprite2D.play("hit")
	
	await get_tree().create_timer(0.2).timeout
	is_hit = false

func death() -> void:
	dead = true
	velocity = Vector2.ZERO
	$AnimatedSprite2D.play("death")
	$DetectionArea/CollisionShape2D.set_deferred("disabled", true)
	await get_tree().create_timer(1.0).timeout
	queue_free()
