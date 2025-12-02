extends Area2D

func _ready():
	# Garante que o sinal seja conectado
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	# Confere se quem tocou é o Player
	if body.is_in_group("player"):

		# Acha a HUD na cena atual
		var hud = get_tree().current_scene.get_node("HUD")
		if hud:
			hud.add_star()  # soma +1 estrela na HUD

		# Desaparece ao ser pega
		queue_free()
