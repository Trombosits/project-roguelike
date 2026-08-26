extends CharacterBody2D

# Signal untuk memberi tahu UI saat darah berubah
signal health_changed(current_health, max_health)

@export var max_health: float = 100.0
@export var speed: float = 180.0
@export var accel: float = 30.0
@export var base_magnet_radius: float = 50.0

# --- BOOMERANG SETTINGS ---
@export_group("Boomerang Settings")
@export var boomerang_scene: PackedScene
@export var boomerang_orbit_speed: float = 3.0
@export var boomerang_radius: float = 60.0

# --- FURRBALL SETTINGS ---
@export_group("FurrBall Settings")
@export var furrball_scene: PackedScene
@export var furrball_spawn_rate: float = 0.5
@export var spawn_radius: float = 200.0

# --- RAYGUN SETTINGS ---
@export_group("Raygun Settings")
@export var raygun_scene: PackedScene

@onready var animated_sprite: AnimatedSprite2D = $PlayerSprite
@onready var weapon_pivot: Node2D = $WeaponPivot

enum states_Up {Up, Up_Right, Up_Left}
enum states_Down {Down, Down_Right, Down_Left}
enum states_Left {Left}
enum states_Right {Right}

var health: float = 100.0

# Stats Magnet
var magnet_level: int = 0
var max_magnet_level: int = 5
var magnet_radius: float = 50.0

# Stats Boomerang
var boomerang_level: int = 0
var max_boomerang_level: int = 4

# Stats Raygun
var raygun_level: int = 0
var max_raygun_level: int = 4

# Stats Furrball
var furrball_level: int = 0
var max_furrball_level: int = 4
var furrball_timer: float = 0.0

# Stats EXP & Level
var level: int = 1
var current_exp: int = 0
var max_exp: int = 100

var active_weapon_type: String = "" # Kosong di awal permainan
var raygun_instance: Node2D = null
var last_direction: String = "Down"

func _ready() -> void:
	add_to_group("player")
	health = max_health
	magnet_radius = base_magnet_radius
	
	# Panggil UI Pilihan Kartu di awal permainan
	call_deferred("trigger_level_up_screen")

func trigger_level_up_screen() -> void:
	# Cari node LevelUp UI di dalam scene dan buka layar pilihan kartu
	var level_up_ui = get_tree().current_scene.find_child("LevelUp*", true, false)
	if level_up_ui and level_up_ui.has_method("open_level_up_screen"):
		level_up_ui.open_level_up_screen()

# --- FUNGSI PENANGAN KARTU UI ---
func add_or_upgrade_weapon(weapon_type: String) -> void:
	var w = weapon_type.to_lower() # Memastikan string tidak bermasalah dengan huruf besar/kecil
	
	if w == "boomerang":
		if boomerang_level == 0:
			boomerang_level = 1
			update_boomerangs()
		else:
			upgrade_boomerang()

	elif w == "raygun":
		if raygun_level == 0:
			raygun_level = 1
			equip_raygun()
		else:
			upgrade_raygun()

	elif w == "furrball":
		if furrball_level == 0:
			furrball_level = 1
		else:
			upgrade_furrball()

func take_damage(amount: float) -> void:
	health = max(0.0, health - amount)    
	DamageText.display_number(amount, global_position - Vector2(0, 20)) 
	health_changed.emit(health, max_health) 
	
	if health <= 0:
		die()

func die() -> void:
	get_tree().call_deferred("change_scene_to_file", "res://Scene/Menu/gameOver.tscn")
	queue_free()

func gain_exp(amount: int) -> void:
	current_exp += amount
	if current_exp >= max_exp:
		level_up()

func level_up() -> void:
	level += 1
	current_exp -= max_exp 
	max_exp = int(max_exp * 1.5) 
	
	# Buka layar UI kartu saat naik level
	trigger_level_up_screen()

func upgrade_magnet() -> void:
	if magnet_level < max_magnet_level:
		magnet_level += 1
		if magnet_level == 1: magnet_radius = 150.0
		elif magnet_level == 2: magnet_radius = 225.0
		elif magnet_level == 3: magnet_radius = 300.0
		elif magnet_level == 4: magnet_radius = 400.0
		elif magnet_level == 5: magnet_radius = 600.0 

func can_upgrade_weapon(weapon_type: String) -> bool:
	var w = weapon_type.to_lower()
	
	if w == "boomerang":
		return boomerang_level < max_boomerang_level
	elif w == "raygun":
		return raygun_level < max_raygun_level
	elif w == "furrball":
		return furrball_level < max_furrball_level
	elif w == "magnet":
		return magnet_level < max_magnet_level
		
	return true

func equip_boomerang() -> void:
	active_weapon_type = "Boomerang"
	update_boomerangs()

func equip_raygun() -> void:
	active_weapon_type = "Raygun"
	if raygun_scene == null:
		return
		
	raygun_instance = raygun_scene.instantiate()
	add_child(raygun_instance)

func equip_furrball() -> void:
	active_weapon_type = "FurrBall"

# --- LOGIKA UPGRADE SENJATA ---
func update_boomerangs() -> void:
	if boomerang_scene == null:
		return
		
	for child in weapon_pivot.get_children():
		child.queue_free()
		
	for i in range(boomerang_level):
		var boom = boomerang_scene.instantiate()
		var angle = (TAU / boomerang_level) * i
		boom.position = Vector2(cos(angle), sin(angle)) * boomerang_radius
		weapon_pivot.call_deferred("add_child", boom)

func upgrade_boomerang() -> void:
	if boomerang_level < max_boomerang_level:
		boomerang_level += 1
		update_boomerangs()

func upgrade_raygun() -> void:
	if raygun_instance and raygun_instance.has_method("upgrade_weapon"):
		if raygun_level < max_raygun_level:
			raygun_level += 1
			raygun_instance.upgrade_weapon()

func upgrade_furrball() -> void:
	if furrball_level < max_furrball_level:
		furrball_level += 1
		# Opsional: Boleh tetap menurunkan cooldown interval serangan jika ingin lebih cepat lagi
		furrball_spawn_rate = max(0.5, furrball_spawn_rate - 0.05)

func spawn_random_furrball() -> void:
	if furrball_scene == null:
		return
		
	# Loop sebanyak level FurrBall yang dimiliki player
	for i in range(furrball_level):
		var random_offset = Vector2(
			randf_range(-spawn_radius, spawn_radius),
			randf_range(-spawn_radius, spawn_radius)
		)
		var target_pos = global_position + random_offset
		
		var fb = furrball_scene.instantiate()
		get_tree().current_scene.add_child(fb)
		
		if fb.has_method("setup"):
			fb.setup(target_pos)
			
		# Beri sedikit jeda (0.1 detik) antar meteor agar jatuhnya beruntun dan tidak bersamaan
		await get_tree().create_timer(0.1).timeout

func _process(delta: float) -> void:
	# FurrBall akan terus menyerang selama levelnya minimal 1
	if furrball_level > 0:
		furrball_timer += delta
		if furrball_timer >= furrball_spawn_rate:
			furrball_timer = 0.0
			spawn_random_furrball()

func _physics_process(delta: float) -> void:
	# Boomerang akan terus berputar selama levelnya minimal 1
	if boomerang_level > 0 and weapon_pivot:
		weapon_pivot.rotation += boomerang_orbit_speed * delta

	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if input_dir != Vector2.ZERO:
		velocity = velocity.move_toward(input_dir * speed, accel * speed * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, accel * speed * delta)

	move_and_slide()
	update_animation(input_dir)

func update_animation(input_dir: Vector2) -> void:
	if input_dir == Vector2.ZERO:
		if last_direction in states_Down:
			animated_sprite.play("Idle_Down")
		elif last_direction in states_Up:
			animated_sprite.play("Idle_Up")
		elif last_direction in states_Right:
			animated_sprite.play("Idle_Right")
		elif last_direction in states_Left:
			animated_sprite.play("Idle_Left")
		return

	if input_dir.x > 0 and input_dir.y > 0:
		last_direction = "Down_Right"
	elif input_dir.x < 0 and input_dir.y > 0:
		last_direction = "Down_Left"
	elif input_dir.x > 0 and input_dir.y < 0:
		last_direction = "Up_Right"
	elif input_dir.x < 0 and input_dir.y < 0:
		last_direction = "Up_Left"
	elif input_dir.x > 0:
		last_direction = "Right"
	elif input_dir.x < 0:
		last_direction = "Left"
	elif input_dir.y > 0:
		last_direction = "Down"
	elif input_dir.y < 0:
		last_direction = "Up"
		
	animated_sprite.play(last_direction)
