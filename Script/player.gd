extends CharacterBody2D

# Signal untuk memberi tahu UI saat darah berubah
signal health_changed(current_health, max_health)

@export var max_health: float = 100.0
var health: float = 100.0

@export var speed: float = 120.0
@export var accel: float = 30.0
@export var attack_damage: float = 25.0

@onready var animated_sprite: AnimatedSprite2D = $PlayerSprite
@onready var attack_area: Area2D = $AttackArea

enum states_Up {Up, Up_Right, Up_Left}
enum states_Down {Down, Down_Right, Down_Left}
enum states_Left {Left}
enum states_Right {Right}

var last_direction: String = "Down"
var is_attacking: bool = false

func _ready() -> void:
	health = max_health
	add_to_group("player")

func take_damage(amount: float) -> void:
	health = max(0.0, health - amount)
	health_changed.emit(health, max_health) # Kirim signal ke UI
	
	if health <= 0:
		die()

func die() -> void:
	# Logika saat anak kucing kelelahan / game over
	queue_free()

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept") and not is_attacking:
		attack()

	if is_attacking:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if input_dir != Vector2.ZERO:
		velocity = velocity.move_toward(input_dir * speed, accel * speed * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, accel * speed * delta)

	move_and_slide()
	update_animation(input_dir)

func attack() -> void:
	is_attacking = true
	var overlapping_bodies = attack_area.get_overlapping_bodies()
	for body in overlapping_bodies:
		if body != self and body.has_method("take_damage"):
			body.take_damage(attack_damage, global_position)

	await get_tree().create_timer(0.3).timeout
	is_attacking = false

func update_animation(input_dir: Vector2) -> void:
	if is_attacking:
		return

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
