extends Node2D

const DIALOGUE_SCENE = preload("res://dialogos/dialogo_universidade/balloon.tscn")

func _on_porta_entrada_body_entered(body: Node2D) -> void:
	if body.name == "roropreto":
		body.set_physics_process(false) # impede movimento durante o teleporte
		await get_tree().create_timer(0.2).timeout
		body.global_position = Vector2(811, 388) # posição dentro da sala
		body.set_physics_process(true) 


func _on_porta_saida_body_entered(body: Node2D) -> void:
	if body.name == "roropreto":
		body.set_physics_process(false)
		await get_tree().create_timer(0.2).timeout
		body.global_position = Vector2(813, 528) # posição fora da sala
		body.set_physics_process(true) 


func _on_raquel_area_body_entered(body: Node2D) -> void:
	if body.name == "roropreto":
		# 1. Desativa a movimentação da Roro
		body.set_physics_process(false)
		body.set_process_input(false) # Boa prática: desativar input também
		var anim_sprite = body.get_node_or_null("AnimatedSprite2D")
		
		if anim_sprite:
			# Para a animação atual de caminhada
			anim_sprite.stop() 
			
			# Opcional: Para garantir que o frame pare no "idle"
			# Você pode forçar o AnimatedSprite2D para um frame estático aqui
			# Ex: anim_sprite.set_frame_and_progress(0)


		# TEXTURAS DA RAQUEL
		var raquel_textures = {
			"feliz": preload("res://assets/assets alanis/personagens alanis/RAQUEL/dialogo_raquel_feliz.png"),
			"triste": preload("res://assets/assets alanis/personagens alanis/RAQUEL/dialogo_raquel_triste.png"),
			"raiva": preload("res://assets/assets alanis/personagens alanis/RAQUEL/dialogo_raquel_raiva.png"),
			"neutro": preload("res://assets/assets alanis/personagens alanis/RAQUEL/dialogo_raquel_neutro.png")
		}
		
		# TEXTURAS DA RORO (Assumindo uma estrutura de Roro, ou usando o nome do personagem)
		# Supondo que você tem uma Roro e ela usa as emoções de 'Ro'
		var ro_textures = {
			"feliz": preload("res://assets/assets alanis/personagens alanis/RÔ/dialogo_ro_feliz3.png"),
			"triste": preload("res://assets/assets alanis/personagens alanis/RÔ/dialogo_ro_triste3.png"),
			"neutro": preload("res://assets/assets alanis/personagens alanis/RÔ/dialogo_ro_neutro3.png")
		}
		
		var scene_portraits = {
			# Mapeia o NOME DO PERSONAGEM (do arquivo .dialogue) para as texturas carregadas
			"Raquel": {
				"position": "right", 
				"moods": raquel_textures
			},
			"Ro": {
				"position": "left",
				"moods": ro_textures
			}
		}

		# 2. Inicia o diálogo
		var dialogue_resource: DialogueResource = load("res://dialogos/dialogo_universidade/tcc.dialogue")
		var dialogue_title: String = "tcc"
		
		# 3. Cria uma nova instância da cena do balão
		var dialogue_instance = DIALOGUE_SCENE.instantiate()
		add_child(dialogue_instance) # Adiciona à cena (geralmente sob a raiz)
		
		# 3. Passar o dicionário de retratos completo no extra_game_states
		# Nota: Coloque scene_portraits dentro de uma chave para fácil acesso no balão.
		dialogue_instance.start(dialogue_resource, dialogue_title, [{"scene_portraits": scene_portraits}])
		
		# A execução para aqui. Só continua quando o sinal dialogue_finished for emitido.
		await dialogue_instance.dialogue_finished
		
		# Assim que o diálogo acabar, trocamos de cena
		get_tree().change_scene_to_file("res://cenas/cutscenes/rua_do_bar.tscn") 
		
		# 5. Reativa a movimentação da Roro
		#body.set_physics_process(true)
		#body.set_process_input(true)
		
		# 6. Reativa a área de colisão da Dona Marta após um pequeno delay 
		# para evitar que o diálogo seja acionado imediatamente de novo
		#$raquelvermelho/Area2D.set_deferred("monitoring", false)
		#await get_tree().create_timer(4.0).timeout
		#$raquelvermelho/Area2D.set_deferred("monitoring", true)


func _on_porta_entrada_fora_body_entered(body: Node2D) -> void:
	if body.name == "roropreto":
		body.set_physics_process(false) # impede movimento durante o teleporte
		await get_tree().create_timer(0.2).timeout
		body.global_position = Vector2(242, 66) # posição dentro da sala
		body.set_physics_process(true)


func _on_porta_saida_fora_body_entered(body: Node2D) -> void:
	if body.name == "roropreto":
		body.set_physics_process(false) # impede movimento durante o teleporte
		await get_tree().create_timer(0.2).timeout
		body.global_position = Vector2(242, 234) # posição dentro da sala
		body.set_physics_process(true)
