extends Area2D

@export var damage: float = 15.0

func _ready() -> void:
	# 1. Mainkan animasi berputar
	$AnimatedSprite2D.play("spin")
	
	# 2. Hubungkan sinyal tabrakan
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage") and not body.is_in_group("player"):
		body.take_damage(damage)
