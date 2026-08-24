extends Node2D

@export var enemy_scenes: Array[PackedScene] = []
@export var pool_size: int = 500

var pool: Array[Node2D] = []

func _ready() -> void:
	if enemy_scenes.is_empty():
		print("Peringatan: enemy_scenes di ObjectPool masih kosong!")
		return

	for i in range(pool_size):
		var random_scene: PackedScene = enemy_scenes.pick_random()
		var enemy = random_scene.instantiate()
		enemy.process_mode = Node.PROCESS_MODE_DISABLED 
		enemy.hide()
		add_child(enemy)
		pool.append(enemy)

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
