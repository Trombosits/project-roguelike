extends Node2D

@onready var raycast = $RayCast2D
@onready var timer = $Timer
@export var ammo : PackedScene

var player

func _ready():
	player = get_tree().get_first_node_in_group("player")
	raycast.add_exception(get_parent())
	
	# Menghubungkan sinyal timer secara manual melalui kode
	if not timer.timeout.is_connected(_on_timer_timeout):
		timer.timeout.connect(_on_timer_timeout)
	
func _physics_process(_delta): # DIPERBAIKI: Typo _physics_process
	if player: # Cek jika player ada agar tidak crash
		_aim()
		_check_player_collision()

func _aim():
	raycast.target_position = to_local(player.global_position)
	
func _check_player_collision():
	if raycast.get_collider() == player and timer.is_stopped(): # DIPERBAIKI: Typo is_stopped()
		timer.start()
	elif raycast.get_collider() != player and not timer.is_stopped():
		timer.stop()


func _on_timer_timeout():
	_shoot()
	
func _shoot():
	if ammo == null:
		return
		
	var bullet = ammo.instantiate()
	
	# DIPERBAIKI: Gunakan global_position saat menambahkan ke root scene
	bullet.global_position = global_position 
	
	# DIPERBAIKI: Typo direction
	bullet.direction = (raycast.target_position).normalized() 
	
	get_tree().current_scene.add_child(bullet)
