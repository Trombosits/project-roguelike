extends Area2D

@export var speed_boost: float = 1.25
@export var damage_boost: float = 1.25
@export var buff_duration: float = 30.0

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		# 1. Matikan kolisi & sembunyikan item
		collision_shape.set_deferred("disabled", true)
		hide()

		# 2. Panggil UI untuk jalankan countdown 30 detik
		var ui_label = get_tree().get_first_node_in_group("catnip_ui")
		if ui_label and ui_label.has_method("start_timer"):
			ui_label.start_timer(buff_duration)

		# 3. Beri buff ke pemain
		if "speed" in body: body.speed *= speed_boost
		if "attack_damage" in body: body.attack_damage *= damage_boost

		# 4. Tunggu durasi buff selesai
		await get_tree().create_timer(buff_duration).timeout

		# 5. Kembalikan stat pemain ke semula
		if is_instance_valid(body):
			if "speed" in body: body.speed /= speed_boost
			if "attack_damage" in body: body.attack_damage /= damage_boost

		queue_free()
