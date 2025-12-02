# bar_interior1.gd
extends Node2D

@onready var player: Player = $roropreto

# Variáveis para controle
var enemies_killed = 0
const REQUIRED_KILLS = 3

func _ready():
	# Busca todos os nós que estão no grupo "enemy" (definido no _ready do policial)
	var enemies = get_tree().get_nodes_in_group("enemy")
	
	for enemy in enemies:
		# Conecta o sinal 'on_death' do policial à função '_on_enemy_death' deste script
		if enemy.has_signal("on_death"):
			enemy.on_death.connect(_on_enemy_death)

func _on_enemy_death():
	enemies_killed += 1
	print("Inimigos mortos: ", enemies_killed)
	
	if enemies_killed >= REQUIRED_KILLS:
		change_level()

func change_level():
	print("Todos os policiais mortos. Trocando de cena...")
	# Substitua pelo caminho da sua próxima cena
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://cenas/cutscenes/bar_fora_fuga.tscn")
