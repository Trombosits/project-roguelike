extends CharacterBody2D

# Signal untuk memberi tahu UI saat darah berubah
signal health_changed(current_health, max_health)

@export var max_health: float = 100.0
@export var speed: float = 120.0
@export var accel: float = 30.0
@export var base_magnet_radius: float = 50.0

# --- BOOMERANG SETTINGS ---
@export_group("Boomerang Settings")
@export var boomerang_scene: PackedScene # Seret Boomerang.tscn ke sini di Inspector!
@export var boomerang_orbit_speed: float = 3.0
@export var boomerang_radius: float = 60.0

@onready var animated_sprite: AnimatedSprite2D = $PlayerSprite
@onready var weapon_pivot: Node2D = $WeaponPivot
@onready var exp_bar: ProgressBar = $CanvasLayer/ExpBar

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

# Stats EXP & Level
var level: int = 1
var current_exp: int = 0
var max_exp: int = 100

var last_direction: String = "Down"

func _ready() -> void:
	health = max_health
	magnet_radius = base_magnet_radius
	
	# Spawn bumerang awal
	update_boomerangs()

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
	else:
		# Update animasi EXP biasa
		exp_bar.update_exp(current_exp, max_exp, false)

func level_up() -> void:
	level += 1
	current_exp -= max_exp 
	max_exp = int(max_exp * 1.5) 
	print("Level Up! Sekarang level: ", level)
	exp_bar.update_exp(current_exp, max_exp, true)
	
	#show_level_up_menu()
	upgrade_boomerang()

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

# --- FUNGSI BOOMERANG ---
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

func _physics_process(delta: float) -> void:
	# Putar WeaponPivot agar bumerang mengelilingi pemain
	if weapon_pivot:
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
