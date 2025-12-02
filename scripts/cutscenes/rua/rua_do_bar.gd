#rua_do_bar.gd
extends Node2D

@onready var animation_player = $AnimationPlayer
@onready var encontro_area = $encontro

# Pré-carrega sua cena de diálogo (substitua o caminho)
const DIALOGUE_SCENE = preload("res://dialogos/dialogo_rua/balloon.tscn")

# Pré-carrega o recurso de diálogo
const DIALOGUE_RESOURCE = preload("res://dialogos/dialogo_rua/rua.dialogue")

func _ready():
	if animation_player:
		animation_player.play("scene_andando")


func _on_encontro_area_entered(area: Area2D) -> void:
	# O nó pai do Area2D é o personagem AnimatedSprite2D
	var parent_name = area.get_parent().name
	
	if parent_name == "ro" or parent_name == "lila":
		
		# 1. PARAR ANIMAÇÕES DE MOVIMENTO
		
		var current_anim_pos = animation_player.current_animation_position
		
		# Para a animação da cutscene
		if animation_player.is_playing():
			animation_player.stop(false)
			
			animation_player.seek(current_anim_pos, true)

		# Para a animação de andar da personagem que colidiu
		var character_node = area.get_parent()
		_parar_animacao_e_input(character_node)
		
		# Para a animação de andar da outra personagem
		if parent_name == "ro":
			_parar_animacao_e_input($lila)
		elif parent_name == "lila":
			_parar_animacao_e_input($ro)
			
		# 2. IMPEDE QUE O GATILHO SEJA ACIONADO NOVAMENTE
		encontro_area.set_deferred("monitoring", false)

		await get_tree().create_timer(0.7).timeout

		# 3. INICIAR O DIÁLOGO
		iniciar_dialogo()
		# A execução vai para aqui, esperando o 'await' dentro de iniciar_dialogo


# Função auxiliar combinada para parar animação e input (segundo o padrão da universidade)
func _parar_animacao_e_input(body: Node2D):
	# Como 'body' é o AnimatedSprite2D, ele não tem set_physics_process ou set_process_input
	# Se você quiser bloquear o input do jogador depois (para Ro, se ela fosse controlável), 
	# você teria que fazer isso no nó que controla o input dela.
	
	var anim_sprite = body.get_node_or_null("AnimatedSprite2D") # Pode ser o próprio nó, se for 'ro'
	
	# Se o próprio nó já é o AnimatedSprite2D
	if body is AnimatedSprite2D:
		body.stop()
	elif anim_sprite:
		anim_sprite.stop()
		
	# Nota: Em uma cutscene onde o AnimationPlayer move os AnimatedSprite2D, 
	# parar o 'animation_player.stop()' já é suficiente para congelar o movimento.


func iniciar_dialogo():
	# 1. DEFINIÇÃO DAS TEXTURAS/RETRATOS
	
	# TEXTURAS DA LILA (Assumindo que você tem os assets dela)
	var lila_textures = {
		"feliz": preload("res://assets/assets alanis/personagens alanis/LILA/dialogo_lila_feliz.png"),
		"triste": preload("res://assets/assets alanis/personagens alanis/LILA/dialogo_lila_triste.png"),
		"neutro": preload("res://assets/assets alanis/personagens alanis/LILA/dialogo_lila_neutro.png")
		# Adicione mais emoções conforme necessário
	}
	
	# TEXTURAS DA RORO
	var ro_textures = {
		"feliz": preload("res://assets/assets alanis/personagens alanis/RÔ/dialogo_ro_feliz3.png"),
		"triste": preload("res://assets/assets alanis/personagens alanis/RÔ/dialogo_ro_triste3.png"),
		"neutro": preload("res://assets/assets alanis/personagens alanis/RÔ/dialogo_ro_neutro3.png")
		# Adicione mais emoções conforme necessário
	}
	
	var scene_portraits = {
		# Mapeia o NOME DO PERSONAGEM (do arquivo .dialogue) para as texturas
		"Lila": {
			"position": "right", 
			"moods": lila_textures
		},
		"Ro": {
			"position": "left",
			"moods": ro_textures
		}
	}

	# 2. Cria e Inicia o diálogo
	var dialogue_instance = DIALOGUE_SCENE.instantiate()
	add_child(dialogue_instance)
	
	# Substitua "rua" pelo nome da conversa dentro do seu arquivo .dialogue,
	# e passe o dicionário de retratos
	var dialogue_title: String = "rua"
	dialogue_instance.start(DIALOGUE_RESOURCE, dialogue_title, [{"scene_portraits": scene_portraits}])

	# A execução para aqui. Só continua quando o sinal dialogue_finished for emitido.
	await dialogue_instance.dialogue_finished

	# 3. LÓGICA DE FIM DA CUTSCENE (Seguindo o padrão da universidade)
	print("Diálogo Encerrado.")
	
	# Reativa a área de colisão após um pequeno delay 
	# (para evitar que o diálogo seja acionado imediatamente de novo)
	#encontro_area.set_deferred("monitoring", false) # Boa prática: desativar primeiro
	#await get_tree().create_timer(5.0).timeout
	#encontro_area.set_deferred("monitoring", true)
	
	if animation_player.has_animation("scene_saindo"):
		animation_player.play("scene_saindo")
		# Opcional: espera que a animação termine antes de mudar de cena
		await animation_player.animation_finished 
		get_tree().change_scene_to_file("res://cenas/cenarios/bar_interior.tscn")
	
	# Opcional: Iniciar o próximo segmento de animação da cutscene, se houver
	# animation_player.play("continua_depois_dialogo")
