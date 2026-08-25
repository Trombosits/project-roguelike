extends Area2D

@export var exp_value: int = 10
@export var base_speed: float = 100.0

var player: Node2D = null
var is_following: bool = false
var current_speed: float = 0.0

# Variabel baru untuk menahan tarikan magnet di detik pertama
var can_be_magnetized: bool = false 

func _ready() -> void:
	add_to_group("exp") 
	
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
		
	player = get_tree().get_first_node_in_group("player")
	current_speed = base_speed
	
	# Memberikan jeda 0.5 detik sebelum EXP bisa bereaksi terhadap magnet
	await get_tree().create_timer(0.5).timeout
	can_be_magnetized = true

func _physics_process(delta: float) -> void:
	if player == null:
		return

	# Syarat tambahan: hanya tersedot JIKA can_be_magnetized sudah bernilai true
	if not is_following and can_be_magnetized and global_position.distance_to(player.global_position) < player.magnet_radius:
		is_following = true 

	if is_following:
		var direction = (player.global_position - global_position).normalized()
		current_speed += 300.0 * delta 
		global_position += direction * current_speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("gain_exp"):
		body.gain_exp(exp_value)
		queue_free()

func force_follow() -> void:
	is_following = true
