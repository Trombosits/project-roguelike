extends Node2D

@export var damage: float = 100.0
@export var fire_rate: float = 0.3        # Jeda tembakan (detik)
@export var attack_range: float = 500.0     # Panjang maksimal jangkauan laser
@export var laser_duration: float = 0.08   # Durasi kilatan garis laser di layar

# --- LEVEL SYSTEM ---
@export var level: int = 1
@export var max_level: int = 4

@onready var ray_cast: RayCast2D = $RayCast2D
@onready var line_2d: Line2D = $Line2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var can_shoot: bool = true

func _ready() -> void:
	# Atur panjang raycast lurus ke depan (sumbu X positif)
	if ray_cast:
		ray_cast.target_position = Vector2(attack_range, 0)
		ray_cast.enabled = true
		
	if line_2d:
		line_2d.visible = false
		
	update_weapon_visual()

func _process(_delta: float) -> void:
	# 1. Buat Raygun selalu menghadap ke kursor mouse
	look_at(get_global_mouse_position())
	
	# 2. Balikkan sprite secara vertikal jika mengarah ke kiri agar tidak terbalik
	if sprite:
		sprite.flip_v = (global_rotation_degrees > 90 or global_rotation_degrees < -90)
	
	# 3. Tembak otomatis ke arah mouse berdasarkan cooldown
	if can_shoot:
		shoot_laser()

func shoot_laser() -> void:
	can_shoot = false
	
	update_weapon_visual()
		
	# Paksa RayCast2D memperbarui titik tabrakan di frame ini
	ray_cast.force_raycast_update()
	var end_point: Vector2 = ray_cast.target_position
	
	# Jika RayCast menabrak musuh/objek
	if ray_cast.is_colliding():
		var collider = ray_cast.get_collider()
		end_point = to_local(ray_cast.get_collision_point())
		
		if collider and collider.has_method("take_damage"):
			collider.take_damage(damage, global_position)
			
	# Gambar visual garis laser
	draw_laser_beam(end_point)
	
	await get_tree().create_timer(fire_rate).timeout
	can_shoot = true

func update_weapon_visual() -> void:
	if sprite:
		var current_lvl = clampi(level, 1, max_level)
		sprite.play("laser" + str(current_lvl))

func upgrade_weapon() -> void:
	if level < max_level:
		level += 1
		damage += 5.0
		fire_rate = max(0.1, fire_rate - 0.05)
		update_weapon_visual()

func draw_laser_beam(target_local_pos: Vector2) -> void:
	if line_2d:
		line_2d.clear_points()
		line_2d.add_point(Vector2.ZERO)
		line_2d.add_point(target_local_pos)
		line_2d.visible = true
		
		await get_tree().create_timer(laser_duration).timeout
		line_2d.visible = false
