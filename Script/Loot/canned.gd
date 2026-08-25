extends Area2D

@export_range(0.0, 1.0) var heal_percentage: float = 0.20

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		# 1. Hitung 20% dari darah maksimal player
		var heal_amount: float = body.max_health * heal_percentage
		
		# 2. Tambahkan darah tanpa melebihi max_health
		body.health = min(body.max_health, body.health + heal_amount)
		
		# 3. Perbarui tampilan UI darah
		body.health_changed.emit(body.health, body.max_health)
		
		# 4. Hapus item dari game
		queue_free()
