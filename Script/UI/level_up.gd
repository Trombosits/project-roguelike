extends Control

# Daftar seluruh upgrade (Senjata & Pasif) yang tersedia di game
@export var available_upgrades: Array[Dictionary] = [
	# --- SENJATA ---
	{
		"id": "furrball",
		"type": "weapon",
		"name": "FurrBall",
		"description": "Menjatuhkan bola meteor dari langit.",
		"scene": preload("res://Scene/Weapon/furrball.tscn"),
		"icon": preload("res://icon.svg")
	},
	{
		"id": "boomerang",
		"type": "weapon",
		"name": "Boomerang",
		"description": "Menyerang memutar dan kembali ke pemain.",
		"scene": preload("res://Scene/Weapon/Boomerang.tscn"),
		"icon": preload("res://icon.svg")
	},
	{
		"id": "raygun",
		"type": "weapon",
		"name": "Raygun",
		"description": "Menyerang menggunakan senjata laser.",
		"scene": preload("res://Scene/Weapon/raygun.tscn"),
		"icon": preload("res://icon.svg")
	},

	# --- PASIF / POWER-UPS ---
	{
		"id": "speed_boost",
		"type": "passive",
		"name": "Swift Shoes",
		"description": "Meningkatkan kecepatan gerak sebesar +25%.",
		"icon": preload("res://icon.svg"),
		# Efek langsung dieksekusi ke node Player
		"effect": func(player): 
			player.speed += 50.0
			},{
		"id": "max_hp_boost",
		"type": "passive",
		"name": "Heart Container",
		"description": "Menambah Max HP sebesar +20 dan memulihkan HP.",
		"icon": preload("res://icon.svg"),
		"effect": func(player): 
			player.max_health += 20.0
			player.health = clamp(player.health + 20.0, 0, player.max_health)
			player.health_changed.emit(player.health, player.max_health)
			},
	{
		"id": "damage_boost",
		"type": "passive",
		"name": "Might Potion",
		"description": "Meningkatkan seluruh damage serangan sebesar +15%.",
		"icon": preload("res://icon.svg"),
		"effect": func(player): 
			if "damage_multiplier" in player:
				player.damage_multiplier *= 1.15
			}
]

@onready var cards: Array[Node] = [
	$HBoxContainer/Card1,
	$HBoxContainer/Card2,
	$HBoxContainer/Card3
]

func _ready() -> void:
	hide()
	for card in cards:
		card.card_clicked.connect(_on_card_selected)

func open_level_up_screen() -> void:
	get_tree().paused = true
	show()
	
	var player = get_tree().get_first_node_in_group("player")
	var valid_pool: Array[Dictionary] = []
	
	# Filter upgrade: Hanya masukkan yang belum Max Level
	for upgrade in available_upgrades:
		if upgrade["type"] == "weapon":
			if player and player.has_method("can_upgrade_weapon"):
				if player.can_upgrade_weapon(upgrade["id"]):
					valid_pool.append(upgrade)
			else:
				valid_pool.append(upgrade)
		else:
			# Pasif / Power-ups selalu dimasukkan ke pool
			valid_pool.append(upgrade)
	
	# Acak hanya dari daftar yang valid (belum max level)
	valid_pool.shuffle()
	
	# Pasang data acak ke 3 kartu
	for i in range(cards.size()):
		if i < valid_pool.size():
			cards[i].setup_card(valid_pool[i])
			cards[i].show()
		else:
			# Sembunyikan slot kartu jika opsi yang tersisa kurang dari 3
			cards[i].hide()

func _on_card_selected(upgrade_data: Dictionary) -> void:
	var player = get_tree().get_first_node_in_group("player")

	if player:
		if upgrade_data["type"] == "weapon":
			if player.has_method("add_or_upgrade_weapon"):
				# Gunakan "id" (bukan "name") agar string selalu konsisten huruf kecilnya
				player.add_or_upgrade_weapon(upgrade_data["id"]) 

		elif upgrade_data["type"] == "passive":
			if upgrade_data.has("effect") and upgrade_data["effect"] is Callable:
				upgrade_data["effect"].call(player)

	get_tree().paused = false
	hide()
