extends CharacterBody2D

@export var speed: float = 80.0
@export var health: float = 100.0
@export var knockback_force: float = 250.0 

# --- PENGATURAN SERANGAN NPC ---
@export var attack_damage: float = 5.0
@export var attack_cooldown: float = 1.0 
@export var attack_range: float = 150.0  # Jarak minimum untuk menyerang

var dead: bool = false
var is_hit: bool = false
var player: Node2D = null
var can_attack: bool = true                

func _ready() -> void:
	# 1. Cari Player secara permanen di awal game
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	if dead:
		return

	if is_hit:
		velocity = velocity.move_toward(Vector2.ZERO, 600.0 * delta)
		move_and_slide()
		return

	if player:
		# 2. Hitung jarak antara NPC dan Player
		var distance_to_player = global_position.distance_to(player.global_position)
		
		# Jika Player masih jauh, terus kejar
		if distance_to_player > attack_range:
			var direction = (player.global_position - global_position).normalized()
			velocity = direction * speed
			$AnimatedSprite2D.play("move")
		
		# Jika Player sudah masuk jarak serang (attack_range)
		else:
			velocity = Vector2.ZERO # Berhenti bergerak saat menyerang
			$AnimatedSprite2D.play("idle_move")
			
			if can_attack:
				deal_damage_to_player()
	else:
		velocity = Vector2.ZERO
		$AnimatedSprite2D.play("idle_move")

	move_and_slide()

# --- LOGIKA SERANGAN & COOLDOWN ---
func deal_damage_to_player() -> void:
	if player and player.has_method("take_damage"):
		can_attack = false
		
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
	
	# Karena DetectionArea dan Hitbox sudah tidak dipakai, Anda bisa menghapus node-node tersebut 
	# di Scene Editor dan menghapus baris set_deferred ini agar tidak error.
	if has_node("DetectionArea/CollisionShape2D"):
		$DetectionArea/CollisionShape2D.set_deferred("disabled", true)
	if has_node("Hitbox/CollisionShape2D"):
		$Hitbox/CollisionShape2D.set_deferred("disabled", true)
		
	await get_tree().create_timer(1.0).timeout
	queue_free()
