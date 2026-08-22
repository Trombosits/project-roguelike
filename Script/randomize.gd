extends Node2D

# --- SPAWNER CONFIGURATION ---
@export_group("NPC Spawner")
@export var npc_scene: PackedScene = preload("res://Scene/Character/NPC.tscn")
@export var npc2_scene: PackedScene = preload("res://Scene/Character/NPC2.tscn")
@export var npc3_scene: PackedScene = preload("res://Scene/Character/NPC3.tscn")
@export var npc4_scene: PackedScene = preload("res://Scene/Character/NPC4.tscn")
@export var spawn_min: Vector2 = Vector2(50, 50)
@export var spawn_max: Vector2 = Vector2(800, 500)
@export var total_npc: int = 35

# --- NODE REFERENCES ---
@onready var player: CharacterBody2D = $Player2D
@onready var health_sprite: Sprite2D = $CanvasLayer/HealthBarSprite
@onready var health_label: Label = $CanvasLayer/HealthLabel

# Total frame pada spritesheet (0 sampai 10)
var total_frames: int = 11

func _ready() -> void:
	# 1. Inisialisasi UI HealthBar & Label
	if player:
		player.health_changed.connect(_on_player_health_changed)
		update_health_ui(player.health, player.max_health)

	# 2. Spawn NPC secara acak
	for i in range(total_npc):
		spawn_random_npc()

# Callback signal saat darah player berubah
func _on_player_health_changed(current_health: float, max_health: float) -> void:
	update_health_ui(current_health, max_health)

func update_health_ui(current_health: float, max_health: float) -> void:
	# Update frame sprite telapak kaki
	if health_sprite:
		var health_ratio: float = clamp(current_health / max_health, 0.0, 1.0)
		var frame_index: int = int((1.0 - health_ratio) * (total_frames - 1))
		health_sprite.frame = frame_index

	# Update teks pada HealthLabel
	if health_label:
		health_label.text = str(int(current_health))

func spawn_random_npc() -> void:
	if npc_scene == null or npc2_scene == null or npc3_scene == null or npc4_scene == null:
		return

	var available_npcs = [npc_scene, npc2_scene, npc3_scene, npc4_scene]	
	var selected_scene: PackedScene = available_npcs.pick_random()

	var npc_instance = selected_scene.instantiate()
	
	var random_x = randf_range(spawn_min.x, spawn_max.x)
	var random_y = randf_range(spawn_min.y, spawn_max.y)
	
	npc_instance.global_position = Vector2(random_x, random_y)
	add_child(npc_instance)
