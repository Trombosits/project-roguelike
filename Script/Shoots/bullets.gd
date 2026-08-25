extends Area2D

var direction : Vector2 = Vector2.RIGHT
var speed : float = 150
var damage : float = 1.0 

func _ready():
	# Menghubungkan sinyal tabrakan secara otomatis saat peluru muncul
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _physics_process(delta):
	position += direction * speed * delta

func _on_screen_exited() -> void:
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(damage)
		queue_free()
