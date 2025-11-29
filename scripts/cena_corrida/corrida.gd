# Script para o nó principal 'corrida' (corrida.gd)
extends Node2D

# --- Carrega a cena do carro de polícia ---
const PoliceScene = preload("res://cenas/componentes/carropolicia.tscn")
# Esta é a velocidade que o cenário vai mover (a "velocidade do carro")
@export var velocidade_cenario: float = 80.0

# Esta é a altura exata do seu cenário (pista/grama) em pixels.
# É a distância que o cenário precisa andar antes de repetir.
@export var altura_cenario: float = 1726.0

# --- Variáveis do Gerenciador ---
var police_cars_remaining: int = 3 # O número total de carros
@onready var player_node = $carrofuga # Referência ao jogador

@onready var cenario1 = $cenariomovel
@onready var cenario2 = $cenariomovel2

func _ready():
	# Garante que o cenário 2 começa exatamente acima do cenário 1
	# (Assumindo que Y=0 é o topo e Y positivo é para baixo)
	cenario2.position.y = cenario1.position.y - altura_cenario
	
	# Começa o jogo spawnando o PRIMEIRO carro
	spawn_new_police_car()

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

# Esta função é chamada para criar um novo carro
func spawn_new_police_car():
	# 1. Verifica se acabaram os carros
	if police_cars_remaining <= 0:
		print("Todos os carros foram destruídos! Mudando de cena...")
		
		# (Opcional) Pequena pausa de 1 segundo para o jogador respirar antes de mudar
		await get_tree().create_timer(1.0).timeout
		
		# Mude "res://cenas/shopping.tscn" para o caminho da sua próxima cena
		get_tree().change_scene_to_file("res://cenas/videos/video_feliz_apartamento.tscn")
		return 

	# 2. Subtrai um da contagem
	police_cars_remaining -= 1
	print("Spawnando carro de polícia! Restam na reserva: ", police_cars_remaining)

	# 3. Cria a instância do carro
	var new_car = PoliceScene.instantiate()

	# 4. Configura as variáveis do carro
	new_car.player_to_follow = player_node 

	# 5. Conecta o sinal de "morte" do carro
	new_car.tree_exited.connect(_on_police_car_destroyed)

	# 6. Adiciona o carro na cena
	add_child(new_car)

# Esta função é chamada automaticamente quando o carro anterior é destruído
func _on_police_car_destroyed():
	print("Carro de polícia destruído! Chamando o próximo...")
	
	# Chama o próximo carro
	spawn_new_police_car()


func again_on_button_pressed() -> void:
	# PRIMEIRO, despausa o jogo
	get_tree().paused = false
	
	# DEPOIS, recarrega a cena inteira
	get_tree().reload_current_scene()

# Esta função será conectada ao sinal de morte do jogador
func _on_player_died():
	# Mostra a tela de "Game Over"
	$GameOverUI.show()
	# Opcional: Pausa o jogo
	get_tree().paused = true
