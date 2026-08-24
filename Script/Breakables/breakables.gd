extends StaticBody2D

@export var health: float = 30.0

@export_group("Drop Items")
@export var drop_item_scene: PackedScene
@export var drop_item_scene2: PackedScene
@export var drop_item_scene3: PackedScene
@export var drop_item_scene4: PackedScene

@export_group("Drop Settings")
@export var drop_chance: float = 1.0 # Peluang drop (1.0 = 100%)

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var is_broken: bool = false 

func take_damage(amount: float, hit_position: Vector2 = Vector2.ZERO) -> void:
	if is_broken:
		return
		
	health -= amount
	
	if health > 0:
		anim_sprite.play("box_hit")
	else:
		break_object()

func break_object() -> void:
	is_broken = true
	
	# Matikan tabrakan fisik
	collision_shape.set_deferred("disabled", true)
	
	# Mainkan animasi hancur
	anim_sprite.play("box_open")
	await anim_sprite.animation_finished
	
	# Kumpulkan semua scene yang telah diisi di Inspector ke dalam Array
	var available_drops: Array[PackedScene] = []
	if drop_item_scene != null: available_drops.append(drop_item_scene)
	if drop_item_scene2 != null: available_drops.append(drop_item_scene2)
	if drop_item_scene3 != null: available_drops.append(drop_item_scene3)
	if drop_item_scene4 != null: available_drops.append(drop_item_scene4)
	
	# Jika ada item yang tersedia dan lolos cek peluang, spawn 1 item acak
	if not available_drops.is_empty() and randf() <= drop_chance:
		var selected_scene: PackedScene = available_drops.pick_random()
		var item = selected_scene.instantiate()
		item.global_position = global_position
		get_tree().current_scene.call_deferred("add_child", item)
		
	queue_free()
