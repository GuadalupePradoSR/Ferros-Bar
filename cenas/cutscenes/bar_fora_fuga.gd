extends Node2D

# Pega a referência do AnimationPlayer que está na cena
@onready var animation_player = $AnimationPlayer

func _ready():
	# Conecta o sinal que avisa quando a animação termina
	animation_player.animation_finished.connect(_on_animation_finished)
	
	# DICA: Se o AnimationPlayer não estiver marcado como "Autoplay" (o ícone de A),
	# descomente a linha abaixo e coloque o nome da sua animação:
	animation_player.play("andar")

func _on_animation_finished(anim_name: String):
	if anim_name == "andar":
	# Quando a animação acabar, muda para a próxima cena
	# Substitua o caminho abaixo pela cena que você quer carregar
		get_tree().change_scene_to_file("res://cenas/cenarios/corrida.tscn")
