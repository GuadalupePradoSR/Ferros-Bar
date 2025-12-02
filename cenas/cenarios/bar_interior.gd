# bar_interior1.gd

extends Node2D

@onready var player: Player = $roropreto

var total_enemies = 0
var dead_enemies = 0

# Caminho da próxima cena (AJUSTE PARA O SEU ARQUIVO REAL)
const NEXT_SCENE_PATH = "res://cenas/cutscenes/bar_fora_fuga.tscn"

func _ready():
	# 1. Esperamos um frame para garantir que os inimigos rodaram o _ready deles
	# e já se adicionaram ao grupo "enemy"
	await get_tree().process_frame
	
	# 2. Buscamos todos os inimigos na cena
	var enemies = get_tree().get_nodes_in_group("enemy")
	total_enemies = enemies.size()
	
	print("Total de inimigos detectados: ", total_enemies)

	# 3. Conectamos o sinal de morte de cada um deles
	for enemy in enemies:
		# Conecta o sinal 'on_death' do policial à função '_on_enemy_died' deste script
		if not enemy.on_death.is_connected(_on_enemy_died):
			enemy.on_death.connect(_on_enemy_died)

func _on_enemy_died():
	dead_enemies += 1
	print("Inimigo morreu. Mortos: ", dead_enemies, "/", total_enemies)
	
	if dead_enemies >= total_enemies:
		print("Todos morreram! Mudando de cena...")
		call_deferred("change_scene")

func change_scene():
	# Troca para a próxima cena
	get_tree().change_scene_to_file(NEXT_SCENE_PATH)
