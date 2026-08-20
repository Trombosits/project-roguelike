extends Node2D

@export var npc_scene: PackedScene = preload("res://Scene/Character/NPC.tscn") 

# Tentukan batas area spawn (Koordinat X dan Y)
@export var spawn_min: Vector2 = Vector2(50, 50)
@export var spawn_max: Vector2 = Vector2(800, 500)
@export var total_npc: int = 5

func _ready() -> void:
	for i in range(total_npc):
		spawn_random_npc()

func spawn_random_npc() -> void:
	if npc_scene == null:
		return

	var npc_instance = npc_scene.instantiate()
	
	# Acak koordinat X dan Y dalam rentang batas
	var random_x = randf_range(spawn_min.x, spawn_max.x)
	var random_y = randf_range(spawn_min.y, spawn_max.y)
	
	npc_instance.global_position = Vector2(random_x, random_y)
	add_child(npc_instance)
