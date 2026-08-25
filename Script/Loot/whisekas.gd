extends Area2D

@export var max_health_bonus: float = 20.0

func _ready() -> void:
	# Menghubungkan sinyal tabrakan secara otomatis lewat kode
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		
		body.max_health += max_health_bonus
		body.health += max_health_bonus 
		body.health_changed.emit(body.health, body.max_health)
		
		queue_free()
