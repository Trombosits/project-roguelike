extends Node2D

@onready var raycast = $RayCast2D
@onready var timer = $Timer
@export var ammo : PackedScene

@export var min_shoot_delay: float = 3.0
@export var max_shoot_delay: float = 4.0

var player

func _ready():
	player = get_tree().get_first_node_in_group("player")
	raycast.add_exception(get_parent())
	
	# PENTING: Paksa Timer menjadi One Shot agar tidak mengulang otomatis dengan angka yang sama
	timer.one_shot = true 
	
	if not timer.timeout.is_connected(_on_timer_timeout):
		timer.timeout.connect(_on_timer_timeout)
	
func _physics_process(_delta): 
	if player: 
		_aim()
		_check_player_collision()

func _aim():
	raycast.target_position = to_local(player.global_position)
	
func _check_player_collision():
	if raycast.get_collider() == player:
		# Jika Timer sedang tidak berjalan, mulai Timer dengan durasi acak baru
		if timer.is_stopped(): 
			timer.start(randf_range(min_shoot_delay, max_shoot_delay))
	else:
		# Jika Player bersembunyi/keluar dari pandangan, hentikan hitungan
		if not timer.is_stopped():
			timer.stop()

func _on_timer_timeout():
	_shoot()
	# Karena timer.one_shot = true, Timer otomatis berhenti di sini.
	# Di frame berikutnya, _check_player_collision akan mendeteksi timer berhenti 
	# dan memulainya lagi dengan angka acak yang baru!
	
func _shoot():
	if ammo == null:
		return
		
	var bullet = ammo.instantiate()
	bullet.global_position = global_position 
	bullet.direction = (raycast.target_position).normalized() 
	
	get_tree().current_scene.add_child(bullet)
