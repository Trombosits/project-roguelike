extends CharacterBody2D

@export var speed: float = 80.0
@export var max_health: float = 100.0
@export var knockback_force: float = 250.0 

# --- PENGATURAN SERANGAN NPC ---
@export var attack_damage: float = 5.0
@export var attack_cooldown: float = 1.0 
@export var attack_range: float = 150.0  # Jarak minimum untuk menyerang

@export var exp_gem_scene: PackedScene               

var health: float = 100.0
var dead: bool = false
var is_hit: bool = false
var player: Node2D = null
var can_attack: bool = true

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	health = max_health

# --- FUNGSI RESET UNTUK OBJECT POOLING ---
func reset_stats() -> void:
	health = max_health
	dead = false
	is_hit = false
	can_attack = true
	velocity = Vector2.ZERO
	
	if player == null:
		player = get_tree().get_first_node_in_group("player")
		
	if has_node("DetectionArea/CollisionShape2D"):
		$DetectionArea/CollisionShape2D.set_deferred("disabled", false)
	if has_node("Hitbox/CollisionShape2D"):
		$Hitbox/CollisionShape2D.set_deferred("disabled", false)
	if has_node("CollisionShape2D"):
		$CollisionShape2D.set_deferred("disabled", false)
		
	$AnimatedSprite2D.play("move")
	
	# MATIKAN physics_process secara bawaan saat baru direzet/spawn di luar layar
	set_physics_process(false)

func _physics_process(delta: float) -> void:
	if dead:
		return

	if is_hit:
		velocity = velocity.move_toward(Vector2.ZERO, 600.0 * delta)
		move_and_slide()
		return

	if player:
		var distance_to_player = global_position.distance_to(player.global_position)
		
		if distance_to_player > attack_range:
			var direction = (player.global_position - global_position).normalized()
			velocity = direction * speed
			$AnimatedSprite2D.play("move")
		else:
			velocity = Vector2.ZERO
			$AnimatedSprite2D.play("idle_move")
			
			if can_attack:
				deal_damage_to_player()
	else:
		velocity = Vector2.ZERO
		$AnimatedSprite2D.play("idle_move")

	move_and_slide()

# --- LOGIKA SERANGAN & COOLDOWN ---
func deal_damage_to_player() -> void:
	if player and player.has_method("take_damage") and can_attack:
		can_attack = false
		player.take_damage(attack_damage) # Perbaikan: Tambahkan pengurangan darah player
		
		await get_tree().create_timer(attack_cooldown).timeout
		can_attack = true

func take_damage(damage: float, attacker_pos: Vector2 = Vector2.ZERO) -> void:
	if dead:
		return

	health -= damage
	DamageText.display_number(damage, global_position - Vector2(0, 20)) 
	
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
	
	# Matikan semua kolisi agar tidak menyerang/tertembak saat animasi mati
	if has_node("DetectionArea/CollisionShape2D"):
		$DetectionArea/CollisionShape2D.set_deferred("disabled", true)
	if has_node("Hitbox/CollisionShape2D"):
		$Hitbox/CollisionShape2D.set_deferred("disabled", true)
	if has_node("CollisionShape2D"):
		$CollisionShape2D.set_deferred("disabled", true)

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	# Aktifkan kembali pergerakan saat monster masuk ke dalam layar
	if not dead:
		set_physics_process(true)

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	# Matikan pergerakan saat monster berada di luar layar
	set_physics_process(false)

	if exp_gem_scene != null:
		var drop_count = randi_range(1, 4)
		for i in range(drop_count):
			var gem = exp_gem_scene.instantiate()
			var random_offset = Vector2(randf_range(-15, 15), randf_range(-15, 15))
			gem.global_position = global_position + random_offset
			get_tree().current_scene.call_deferred("add_child", gem)
		
	await get_tree().create_timer(1.0).timeout
	
	# Perbaikan Object Pooling: Sembunyikan & nonaktifkan, BUKAN queue_free()
	hide()
	set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
