extends Node2D

@export var rotation_speed: float = 3.0 # Kecepatan putaran (semakin besar semakin cepat)

func _physics_process(delta: float) -> void:
	# Putar poros ini terus-menerus setiap frame
	rotation += rotation_speed * delta
