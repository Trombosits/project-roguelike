extends ProgressBar # Ubah ke ProgressBar jika menggunakan node ProgressBar biasa

var exp_tween: Tween

func update_exp(current_exp: float, max_exp: float, is_level_up: bool = false) -> void:
	# Matikan tween sebelumnya jika pemain mengambil EXP terus-menerus
	if exp_tween and exp_tween.is_running():
		exp_tween.kill()
		
	exp_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	if is_level_up:
		# 1. Isi bar hingga penuh (max_value lama)
		exp_tween.tween_property(self, "value", max_value, 0.2)
		
		# 2. Reset bar ke 0 & perbarui max_value ke target level baru
		exp_tween.tween_callback(func(): 
			max_value = max_exp
			value = 0
		)
		
		# 3. Isi bar dari 0 ke sisa EXP di level baru
		exp_tween.tween_property(self, "value", current_exp, 0.3)
	else:
		max_value = max_exp
		# Animasi pengisian EXP biasa
		exp_tween.tween_property(self, "value", current_exp, 0.25)
