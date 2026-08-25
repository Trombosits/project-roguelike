extends Node2D

# Sinyal pemberitahuan bahwa seluruh NPC & Breakables selesai di-spawn
signal spawning_completed

# --- SPAWNER CONFIGURATION ---
@export_group("NPC Spawner")
@export var spawn_min: Vector2 = Vector2(50, 50)
@export var spawn_max: Vector2 = Vector2(800, 500)
@export var total_npc: int = 1000 
@export var spawn_per_frame: int = 200 # Jumlah NPC yang di-spawn per frame

# --- BREAKABLES CONFIGURATION ---
@export_group("Breakables Spawner")
@export var breakable_scene: PackedScene
@export var total_breakables: int = 15

# --- PENYEBARAN ---
@export var min_distance: float = 100.0 
var spawned_positions: Array[Vector2] = [] 

# --- NODE REFERENCES ---
@onready var player: CharacterBody2D = $Player2D
@onready var health_sprite: Sprite2D = $CanvasLayer/HealthBarSprite
@onready var health_label: Label = $CanvasLayer/HealthLabel
@onready var object_pool: Node2D = $ObjectPool

# --- UI FPS & MONSTER COUNT REFERENCES ---
@onready var fps_label: Label = $CanvasLayer/FpsLabel
@onready var npc_count_label: Label = $CanvasLayer/NpcCount

var total_frames: int = 11

func _ready() -> void:
	if player:
		player.health_changed.connect(_on_player_health_changed)
		update_health_ui(player.health, player.max_health)

	spawned_positions.clear()
	
	# Tunggu hingga spawn bertahap NPC selesai seluruhnya
	await spawn_all_npcs_gradually()
	
	for i in range(total_breakables):
		spawn_random_breakable()
		
	# Pancarkan sinyal bahwa arena permainan siap ditampilkan
	spawning_completed.emit()

func spawn_all_npcs_gradually() -> void:
	# Tunggu sampai Object Pool siap (jika pool menggunakan async)
	if object_pool and "is_pool_ready" in object_pool:
		while not object_pool.is_pool_ready:
			await get_tree().process_frame

	var batch_counter: int = 0
	
	for i in range(total_npc):
		spawn_random_npc()
		batch_counter += 1
		
		# Jika sudah mencapai kuota per frame, serahkan kontrol ke frame berikutnya
		if batch_counter >= spawn_per_frame:
			batch_counter = 0
			await get_tree().process_frame

# --- UPDATE FPS & MONSTER COUNT ---
func _process(_delta: float) -> void:
	update_fps_ui()
	update_npc_count_ui()

func update_fps_ui() -> void:
	if fps_label:
		fps_label.text = "FPS: " + str(Engine.get_frames_per_second())

func update_npc_count_ui() -> void:
	if npc_count_label and object_pool:
		if object_pool.has_method("get_active_enemy_count"):
			var active_monsters: int = object_pool.get_active_enemy_count()
			npc_count_label.text = "Monsters: " + str(active_monsters)

func _on_player_health_changed(current_health: float, max_health: float) -> void:
	update_health_ui(current_health, max_health)

func update_health_ui(current_health: float, max_health: float) -> void:
	if health_sprite:
		var health_ratio: float = clamp(current_health / max_health, 0.0, 1.0)
		var frame_index: int = int((1.0 - health_ratio) * (total_frames - 1))
		health_sprite.frame = frame_index

	if health_label:
		health_label.text = str(int(current_health))

# --- FUNGSI SPAWN ---
func spawn_random_npc() -> void:
	if object_pool == null:
		return

	var valid_position: bool = false
	var random_pos: Vector2 = Vector2.ZERO
	var attempts: int = 0
	var max_attempts: int = 15 
	
	# Optimasi: Batasi array jarak ke 50 posisi terakhir agar pencarian tidak semakin lambat
	var recent_positions = spawned_positions.slice(-50)
	
	while not valid_position and attempts < max_attempts:
		random_pos = Vector2(
			randf_range(spawn_min.x, spawn_max.x), 
			randf_range(spawn_min.y, spawn_max.y)
		)
		
		valid_position = true
		for pos in recent_positions:
			if random_pos.distance_squared_to(pos) < min_distance * min_distance:
				valid_position = false 
				break
				
		attempts += 1
	
	spawned_positions.append(random_pos)
	object_pool.spawn_enemy(random_pos)

func spawn_random_breakable() -> void:
	if breakable_scene == null:
		return
		
	var breakable_instance = breakable_scene.instantiate()
	var valid_position: bool = false
	var random_pos: Vector2 = Vector2.ZERO
	var attempts: int = 0
	var max_attempts: int = 15
	
	while not valid_position and attempts < max_attempts:
		random_pos = Vector2(
			randf_range(spawn_min.x, spawn_max.x), 
			randf_range(spawn_min.y, spawn_max.y)
		)
		
		valid_position = true
		for pos in spawned_positions:
			if random_pos.distance_squared_to(pos) < min_distance * min_distance:
				valid_position = false 
				break
				
		attempts += 1
	
	spawned_positions.append(random_pos)
	breakable_instance.global_position = random_pos
	add_child(breakable_instance)
