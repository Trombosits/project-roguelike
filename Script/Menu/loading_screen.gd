extends CanvasLayer

@export var main_scene_path: String = "res://Scene/main.tscn"

func _ready() -> void:
	# 1. Load resource scene utama
	var main_packed = load(main_scene_path)
	var main_instance = main_packed.instantiate()
	
	# 2. Hubungkan sinyal spawning_completed sebelum dimuat ke tree
	if main_instance.has_signal("spawning_completed"):
		main_instance.spawning_completed.connect(func(): _on_main_ready(main_instance))
	
	# 3. Masukkan ke scene tree
	get_tree().root.add_child(main_instance)

func _on_main_ready(main_instance: Node) -> void:
	# Tetapkan scene utama baru dan hapus layar loading
	get_tree().current_scene = main_instance
	queue_free()
