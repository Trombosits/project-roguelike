extends Button

@onready var icon_rect: TextureRect = $MarginContainer/VBoxContainer/TextureRect
@onready var title_label: Label = $MarginContainer/VBoxContainer/TitleLabel
@onready var desc_label: Label = $MarginContainer/VBoxContainer/DescLabel

var item_data: Dictionary = {}

# Sinyal untuk mengirimkan data kartu ke level_up.gd saat diklik
signal card_clicked(data: Dictionary)

func _ready() -> void:
	pressed.connect(_on_pressed)

# Fungsi untuk mengisi data ikon, judul, dan deskripsi pada kartu
func setup_card(data: Dictionary) -> void:
	item_data = data
	title_label.text = data.get("name", "")
	desc_label.text = data.get("description", "")
	
	if data.has("icon") and data["icon"] != null:
		icon_rect.texture = data["icon"]

func _on_pressed() -> void:
	card_clicked.emit(item_data)
