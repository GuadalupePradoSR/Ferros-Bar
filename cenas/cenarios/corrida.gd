# Script para o nó principal 'corrida' (corrida.gd)
extends Node2D

# Esta é a velocidade que o cenário vai mover (a "velocidade do carro")
@export var velocidade_cenario: float = 100.0

# Esta é a altura exata do seu cenário (pista/grama) em pixels.
# É a distância que o cenário precisa andar antes de repetir.
@export var altura_cenario: float = 1726.0 # <-- MUDE PARA A ALTURA DA SUA PISTA

@onready var cenario1 = $cenariomovel
@onready var cenario2 = $cenariomovel2

func _ready():
	# Garante que o cenário 2 começa exatamente acima do cenário 1
	# (Assumindo que Y=0 é o topo e Y positivo é para baixo)
	cenario2.position.y = cenario1.position.y - altura_cenario

func _process(delta: float):
	# 1. Move os dois cenários para baixo
	cenario1.position.y += velocidade_cenario * delta
	cenario2.position.y += velocidade_cenario * delta

	# 2. Verifica se o cenário 1 saiu da tela
	# Se a posição Y dele (o topo) passou do limite da altura,
	# significa que ele está totalmente fora da vista por baixo.
	if cenario1.position.y >= altura_cenario:
		# Reposiciona o cenário 1 exatamente acima do cenário 2
		cenario1.position.y = cenario2.position.y - altura_cenario

	# 3. Verifica se o cenário 2 saiu da tela
	if cenario2.position.y >= altura_cenario:
		# Reposiciona o cenário 2 exatamente acima do cenário 1
		cenario2.position.y = cenario1.position.y - altura_cenario
