extends CharacterBody2D

# Signal untuk memberi tahu UI saat darah berubah
signal health_changed(current_health, max_health)

# --- SENJATA AWAL ---
enum StartingWeapon { BOOMERANG, RAYGUN, FURRBALL }
@export var starting_weapon: StartingWeapon = StartingWeapon.BOOMERANG

@export var max_health: float = 100.0
@export var speed: float = 180.0
@export var accel: float = 30.0
@export var base_magnet_radius: float = 50.0

# --- BOOMERANG SETTINGS ---
@export_group("Boomerang Settings")
@export var boomerang_scene: PackedScene # Seret Boomerang.tscn ke sini di Inspector!
@export var boomerang_orbit_speed: float = 3.0
@export var boomerang_radius: float = 60.0

# --- FURRBALL SETTINGS ---
@export_group("FurrBall Settings")
@export var furrball_scene: PackedScene   # Seret furrball.tscn di Inspector!
@export var furrball_spawn_rate: float = 0.5 # Jeda hujan meteor (detik)
@export var spawn_radius: float = 200.0

# --- RAYGUN SETTINGS ---
@export_group("Raygun Settings")
@export var raygun_scene: PackedScene # Seret raygun.tscn ke sini di Inspector!

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
var boomerang_level: int = 1
var max_boomerang_level: int = 4

# Stats Raygun
var raygun_level: int = 1
var max_raygun_level: int = 4

# Stats Furrball
var furrball_level: int = 1
var max_furrball_level: int = 4
var furrball_timer: float = 0.0

# Stats EXP & Level
var level: int = 1
var current_exp: int = 0
var max_exp: int = 100

var active_weapon_type: String = ""
var raygun_instance: Node2D = null
var last_direction: String = "Down"

func _ready() -> void:
	health = max_health
	magnet_radius = base_magnet_radius
	
	# Pasang senjata awal berdasarkan pilihan di Inspector
	if starting_weapon == StartingWeapon.BOOMERANG:
		equip_boomerang()
	elif starting_weapon == StartingWeapon.RAYGUN:
		equip_raygun()
	elif starting_weapon == StartingWeapon.FURRBALL:
		equip_furrball()

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
	
	# Upgrade senjata yang sedang aktif dipakai
	if active_weapon_type == "Boomerang":
		upgrade_boomerang()
	elif active_weapon_type == "Raygun":
		upgrade_raygun()
	elif active_weapon_type == "FurrBall":
		upgrade_furrball()

func upgrade_magnet() -> void:
	if magnet_level < max_magnet_level:
		magnet_level += 1
		
		if magnet_level == 1:
			magnet_radius = 150.0
		elif magnet_level == 2:
			magnet_radius = 225.0
		elif magnet_level == 3:
			magnet_radius = 300.0
		elif magnet_level == 4:
			magnet_radius = 400.0
		elif magnet_level == 5:
			magnet_radius = 600.0 
			
		print("Magnet Level Up! Level: ", magnet_level, " | Radius: ", magnet_radius)
	else:
		print("Magnet sudah level maksimal!")

# --- LOGIKA PASANG & HAPUS SENJATA ---
func clear_weapons() -> void:
	for child in weapon_pivot.get_children():
		child.queue_free()
		
	if raygun_instance and is_instance_valid(raygun_instance):
		raygun_instance.queue_free()
		raygun_instance = null

func equip_boomerang() -> void:
	active_weapon_type = "Boomerang"
	clear_weapons()
	update_boomerangs()

func equip_raygun() -> void:
	active_weapon_type = "Raygun"
	clear_weapons()
	if raygun_scene == null:
		print("Peringatan: raygun_scene belum diisi di Inspector!")
		return
		
	raygun_instance = raygun_scene.instantiate()
	add_child(raygun_instance)

func equip_furrball() -> void:
	active_weapon_type = "FurrBall"
	clear_weapons()

# --- LOGIKA UPGRADE SENJATA ---
func update_boomerangs() -> void:
	if boomerang_scene == null:
		print("Peringatan: boomerang_scene belum diisi di Inspector!")
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
		print("Boomerang Level Up! Level: ", boomerang_level)
		update_boomerangs()
	else:
		print("Boomerang sudah level maksimal!")

func upgrade_raygun() -> void:
	if raygun_instance and raygun_instance.has_method("upgrade_weapon"):
		if raygun_level < max_raygun_level:
			raygun_level += 1
			raygun_instance.upgrade_weapon()
			print("Raygun Level Up! Level: ", raygun_level)
		else:
			print("Raygun sudah level maksimal!")

func upgrade_furrball() -> void:
	if furrball_level < max_furrball_level:
		furrball_level += 1
		# Mempercepat tempo spawn setiap naik level
		furrball_spawn_rate = max(0.1, furrball_spawn_rate - 0.1)
		print("FurrBall Level Up! Level: ", furrball_level, " | Spawn Rate: ", furrball_spawn_rate)
	else:
		print("FurrBall sudah level maksimal!")

func spawn_random_furrball() -> void:
	if furrball_scene == null:
		print("Peringatan: furrball_scene belum diisi di Inspector!")
		return
		
	var random_offset = Vector2(
		randf_range(-spawn_radius, spawn_radius),
		randf_range(-spawn_radius, spawn_radius)
	)
	var target_pos = global_position + random_offset
	
	var fb = furrball_scene.instantiate()
	get_tree().current_scene.add_child(fb)
	
	if fb.has_method("setup"):
		fb.setup(target_pos)

func _process(delta: float) -> void:
	if active_weapon_type == "FurrBall":
		furrball_timer += delta
		if furrball_timer >= furrball_spawn_rate:
			furrball_timer = 0.0
			spawn_random_furrball()

func _physics_process(delta: float) -> void:
	if active_weapon_type == "Boomerang" and weapon_pivot:
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
