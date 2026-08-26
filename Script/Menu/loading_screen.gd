extends CanvasLayer

@export var main_scene_path: String = "res://Scene/main.tscn"

func _ready() -> void:
	# 1. Load resource scene utama
	var main_packed = load(main_scene_path)
	var main_instance = main_packed.instantiate()
	
	# 2. Hubungkan sinyal spawning_completed sebelum dimuat ke tree
	if main_instance.has_signal("spawning_completed"):
		main_instance.spawning_completed.connect(func(): _on_main_ready(main_instance))
	else:
		# Jika tidak memakai sinyal spawn, langsung panggil _on_main_ready
		_on_main_ready(main_instance)
	
	# 3. Masukkan ke scene tree
	get_tree().root.add_child(main_instance)

func _on_main_ready(main_instance: Node) -> void:
	# Tetapkan scene utama baru
	get_tree().current_scene = main_instance
	
	# 4. Cari node LevelUp di main.tscn dan buka kartu senjata awal
	var level_up_ui = main_instance.find_child("LevelUp*", true, false)
	if level_up_ui and level_up_ui.has_method("open_level_up_screen"):
		level_up_ui.open_level_up_screen()
	
	# Hapus layar loading
	queue_free()
