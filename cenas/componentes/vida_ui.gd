# Script: HealthUI.gd (Versão com 3 Texturas Separadas)
extends Control

# --- 1. Carregue suas 3 imagens de coração aqui ---
# Mude os caminhos para onde você salvou suas imagens!
const EMPTY_HEART_TEX = preload("res://cenas/componentes/vazio.png")
const HALF_HEART_TEX = preload("res://cenas/componentes/metade.png")
const FULL_HEART_TEX = preload("res://cenas/componentes/cheio.png")


# Referências para os nossos 3 corações
@onready var hearts = [
	$HBoxContainer/heart_one,
	$HBoxContainer/heart_two,
	$HBoxContainer/heart_three
]

func _ready():
	# Define a vida inicial (6 HP) quando o jogo começa
	update_health(6)

# Esta é a função principal! Ela será chamada pelo jogador
func update_health(current_health: int):
	
	# Cria uma cópia temporária da vida para subtrairmos
	var hp_remaining = current_health
	
	# Passa por cada um dos 3 corações
	for heart_node in hearts:
		
		# A lógica da vida é a MESMA de antes
		if hp_remaining >= 2:
	
			heart_node.texture = FULL_HEART_TEX # Define a textura
			hp_remaining -= 2
			
		elif hp_remaining == 1:
	
			heart_node.texture = HALF_HEART_TEX
			hp_remaining -= 1
			
		else:
	
			heart_node.texture = EMPTY_HEART_TEX
