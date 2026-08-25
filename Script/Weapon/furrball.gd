extends Area2D

@export var damage: float = 25.0
@export var fall_speed: float = 650.0      # Kecepatan jatuh meteor
@export var explosion_radius: float = 100.0 # Radius ledakan AoE (piksel)

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

var target_position: Vector2
var is_exploding: bool = false

func setup(target_pos: Vector2) -> void:
	target_position = target_pos
	global_position = target_pos + Vector2(randf_range(-40, -60), -225)

func _ready() -> void:
	if sprite:
		sprite.play("default_furrball")
		
	body_entered.connect(_on_hit)
	area_entered.connect(_on_hit)

func _process(delta: float) -> void:
	if is_exploding:
		return
		
	global_position = global_position.move_toward(target_position, fall_speed * delta)
	
	if global_position.distance_to(target_position) < 5.0:
		explode()

func _on_hit(target: Node2D) -> void:
	if is_exploding:
		return
		
	if global_position.distance_to(target_position) <= 40.0:
		explode()
		
	if target.is_in_group("enemies") or target.has_method("take_damage"):
		explode()

func explode() -> void:
	if is_exploding:
		return
		
	is_exploding = true
	collision.set_deferred("disabled", true)
	
	apply_aoe_damage()
	
	if sprite:
		if sprite.sprite_frames.has_animation("hit_furball"):
			sprite.play("hit_furball")
		elif sprite.sprite_frames.has_animation("hit_furrball"):
			sprite.play("hit_furrball")
			
		await sprite.animation_finished
		
	queue_free()

func apply_aoe_damage() -> void:
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if not is_instance_valid(enemy) or not (enemy is Node2D):
			continue
			
		if "dead" in enemy and enemy.dead:
			continue
			
		var dist = target_position.distance_to(enemy.global_position)
		if dist <= explosion_radius:
			if enemy.has_method("take_damage"):
				enemy.take_damage(damage, target_position)
