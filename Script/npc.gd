extends CharacterBody2D

@export var speed: float = 80.0
@export var health: float = 100.0
@export var knockback_force: float = 250.0 

# --- PENGATURAN SERANGAN NPC ---
@export var attack_damage: float = 5.0   # Damage yang diberikan ke Player
@export var attack_cooldown: float = 1.0  # Jeda antar serangan (dalam detik)


var dead: bool = false
var is_hit: bool = false
var player: Node2D = null
var can_attack: bool = true               
var player_in_hitbox: Node2D = null       

func _physics_process(delta: float) -> void:
	if dead:
		return

	if is_hit:
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
	
	# Serang player secara berkala jika berada di dalam area Hitbox
	if player_in_hitbox and can_attack:
		deal_damage_to_player()

# --- DETEKSI AREA PENGEJARAN ---
func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == player:
		player = null

# --- DETEKSI HITBOX SERANGAN ---
func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body.has_method("take_damage"):
		player_in_hitbox = body

func _on_hitbox_body_exited(body: Node2D) -> void:
	if body == player_in_hitbox:
		player_in_hitbox = null

# --- LOGIKA SERANGAN & COOLDOWN ---
func deal_damage_to_player() -> void:
	if player_in_hitbox and player_in_hitbox.has_method("take_damage"):
		can_attack = false
		player_in_hitbox.take_damage(attack_damage)
		
		# Tunggu sesuai durasi cooldown sebelum bisa menyerang kembali
		await get_tree().create_timer(attack_cooldown).timeout
		can_attack = true

func take_damage(damage: float, attacker_pos: Vector2 = Vector2.ZERO) -> void:
	if dead:
		return

	health -= damage

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
	velocity = knockback_dir * knockback_force
	$AnimatedSprite2D.play("hit")
	
	await get_tree().create_timer(0.2).timeout
	is_hit = false

func death() -> void:
	dead = true
	velocity = Vector2.ZERO
	$AnimatedSprite2D.play("death")
	$DetectionArea/CollisionShape2D.set_deferred("disabled", true)
	if has_node("Hitbox/CollisionShape2D"):
		$Hitbox/CollisionShape2D.set_deferred("disabled", true)
	await get_tree().create_timer(1.0).timeout
	queue_free()
