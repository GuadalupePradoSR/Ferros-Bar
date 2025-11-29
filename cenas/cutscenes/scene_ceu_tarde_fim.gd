extends Node2D

@onready var animation_player = $AnimationPlayer

func _ready():
	if animation_player:
		# 1. Conecta o sinal 'animation_finished' à função que criamos abaixo
		animation_player.animation_finished.connect(_on_animation_finished)
		
		# 2. Toca a animação
		animation_player.play("roxo")

# 3. Esta função é chamada quando qualquer animação termina
func _on_animation_finished(anim_name: String):
	# Verifica se a animação que acabou é a "rosa"
	if anim_name == "roxo":
		await get_tree().create_timer(2.0).timeout
		# 4. Troca para a nova cena (substitua pelo caminho do seu arquivo)
		get_tree().quit()
