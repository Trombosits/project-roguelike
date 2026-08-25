extends Node2D

@export var enemy_scenes: Array[PackedScene] = []
@export var pool_size: int = 1000
@export var init_batch_size: int = 500 # Jumlah node yang diinstantiate per frame

var pool: Array[Node2D] = []
var is_pool_ready: bool = false

func _ready() -> void:
	if enemy_scenes.is_empty():
		print("Peringatan: enemy_scenes di ObjectPool masih kosong!")
		return

	# Generate pool secara bertahap (Async)
	await init_pool_async()

func init_pool_async() -> void:
	for i in range(pool_size):
		var random_scene: PackedScene = enemy_scenes.pick_random()
		var enemy = random_scene.instantiate()
		enemy.process_mode = Node.PROCESS_MODE_DISABLED 
		enemy.hide()
		add_child(enemy)
		pool.append(enemy)
		
		# Lepas frame setiap kali mencapai batas batch
		if i % init_batch_size == 0:
			await get_tree().process_frame
			
	is_pool_ready = true

func spawn_enemy(spawn_position: Vector2) -> bool:
	for enemy in pool:
		if enemy.process_mode == Node.PROCESS_MODE_DISABLED:
			enemy.global_position = spawn_position
			
			if enemy.has_method("reset_stats"):
				enemy.reset_stats()
				
			enemy.process_mode = Node.PROCESS_MODE_INHERIT 
			enemy.show()
			return true
			
	return false
	
func get_active_enemy_count() -> int:
	var count: int = 0
	for enemy in pool:
		if enemy.process_mode != Node.PROCESS_MODE_DISABLED:
			count += 1
	return count
