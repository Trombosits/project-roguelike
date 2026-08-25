extends CanvasLayer # Ubah menjadi extends Control jika node CatnipUi berwarna hijau

var remaining_time: float = 0.0
var is_active: bool = false

# Mengambil referensi dari anak node Label
@onready var catnip_label: Label = $CatnipLabel

func _ready() -> void:
	# Sembunyikan keseluruhan UI (teks & gambar) di awal permainan
	hide()

func start_timer(duration: float) -> void:
	remaining_time = duration
	is_active = true
	# Munculkan keseluruhan UI
	show()

func _process(delta: float) -> void:
	if is_active:
		remaining_time -= delta
		# Update teks pada node anak (CatnipLabel)
		catnip_label.text = str(ceil(remaining_time)) + "s"
		
		if remaining_time <= 0:
			is_active = false
			hide()
