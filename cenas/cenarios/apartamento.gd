extends Node2D

const DIALOGUE_SCENE = preload("res://dialogos/dialogo_apartamento/balloon.tscn")

# 1. Chamado assim que a cena é carregada
func _ready() -> void:
	# Apenas chama nossa função de atualização
	update_scene_state()

# 2. Esta é nossa nova função "mágica"
func update_scene_state() -> void:
	
	# ----- ESTADO 1: ANTES DO DIÁLOGO DO JORNAL -----
	if not GlobalState.jornal_dialogue_complete:
		$lilaUm.visible = true
		$lilaUm.get_node("CollisionShape2D").disabled = false 
		$lilaUm/Area2D.monitoring = true
		$lilaUm/Area2D.get_node("CollisionShape2D").disabled = false 
		
		# Esconde o Grupo da Invasão e desativa a área dele
		$GrupoInvasao.visible = false
		$GrupoInvasao/Area2D.monitoring = false
		$GrupoInvasao/Area2D.get_node("CollisionShape2D").disabled = true 

	elif GlobalState.bar_expulsion_complete and not GlobalState.invasao_dialogue_complete:
		$lilaUm.visible = false
		$lilaUm.get_node("CollisionShape2D").disabled = true # <-- DESATIVA A COLISÃO DO CORPO
		$lilaUm/Area2D.monitoring = false
		$lilaUm/Area2D.get_node("CollisionShape2D").disabled = true 
		
		$GrupoInvasao.visible = true
		$GrupoInvasao/Area2D.monitoring = true
		$GrupoInvasao/Area2D.get_node("CollisionShape2D").disabled = false 

	# ----- ESTADO 3: TUDO TERMINADO -----
	else:
		$lilaUm.visible = false
		$lilaUm.get_node("CollisionShape2D").disabled = true # <-- DESATIVA A COLISÃO DO CORPO
		$lilaUm/Area2D.monitoring = false
		$lilaUm/Area2D.get_node("CollisionShape2D").disabled = true
		
		$GrupoInvasao.visible = false
		$GrupoInvasao/Area2D.monitoring = false
		$GrupoInvasao/Area2D.get_node("CollisionShape2D").disabled = true
# ===================================================================
# DIÁLOGO 1: JORNAL (Sua função original)
# ===================================================================
func _on_lila_area_body_entered(body: Node2D) -> void:
	if body.name == "roroamarela" and not GlobalState.jornal_dialogue_complete:
		
		# 1. Trava a Roro
		body.set_physics_process(false)
		body.set_process_input(false)
		var anim_sprite = body.get_node_or_null("AnimatedSprite2D")
		if anim_sprite:
			anim_sprite.stop() 
			
		# 2. Prepara os retratos (seu código)
		var lila_textures = {
			"feliz": preload("res://assets/assets alanis/personagens alanis/LILA/dialogo_lila_feliz.png"),
			"triste": preload("res://assets/assets alanis/personagens alanis/LILA/dialogo_lila_triste.png"),
			"neutro": preload("res://assets/assets alanis/personagens alanis/LILA/dialogo_lila_neutro.png"),
			"raiva": preload("res://assets/assets alanis/personagens alanis/LILA/dialogo_lila_raiva.png"),
		}
		var ro_textures = {
			"feliz": preload("res://assets/assets alanis/personagens alanis/RÔ/dialogo_ro_feliz3.png"),
			"triste": preload("res://assets/assets alanis/personagens alanis/RÔ/dialogo_ro_triste3.png"),
			"neutro": preload("res://assets/assets alanis/personagens alanis/RÔ/dialogo_ro_neutro3.png")
		}
		var scene_portraits = {
			"Lila": {"position": "right", "moods": lila_textures},
			"Ro": {"position": "left", "moods": ro_textures}
		}

		# 3. Inicia o diálogo
		var dialogue_resource: DialogueResource = load("res://dialogos/dialogo_apartamento/jornal.dialogue") 
		var dialogue_instance = DIALOGUE_SCENE.instantiate() 
		add_child(dialogue_instance)
		dialogue_instance.start(dialogue_resource, "start", [{"scene_portraits": scene_portraits}])
		
		await dialogue_instance.dialogue_finished
		
		GlobalState.jornal_dialogue_complete = true
		
		# 5. Reativa a Roro
		body.set_physics_process(true) 
		body.set_process_input(true) 
		
		# 6. ATUALIZA A CENA!
		# Isso vai esconder a Lila e mostrar o Grupo Invasão (se a expulsão já tiver ocorrido)
		update_scene_state()


# ===================================================================
# DIÁLOGO 2: INVASÃO DO BAR (Nova função)
# ===================================================================
func _on_invasao_area_body_entered(body: Node2D) -> void:
	if body.name == "roroamarela" and GlobalState.bar_expulsion_complete and not GlobalState.invasao_dialogue_complete:
		
		# 1. Trava a Roro
		body.set_physics_process(false)
		body.set_process_input(false)
		var anim_sprite = body.get_node_or_null("AnimatedSprite2D")
		if anim_sprite:
			anim_sprite.stop()
			
		# 2. Defina os portraits para os NOVOS personagens
		# (Lembre-se de criar e adicionar os de Karina e Gal!)
		var lila_textures = {
			"feliz": preload("res://assets/assets alanis/personagens alanis/LILA/dialogo_lila_feliz.png"),
			"triste": preload("res://assets/assets alanis/personagens alanis/LILA/dialogo_lila_triste.png"),
			"neutro": preload("res://assets/assets alanis/personagens alanis/LILA/dialogo_lila_neutro.png"),
			"raiva": preload("res://assets/assets alanis/personagens alanis/LILA/dialogo_lila_raiva.png"),
		}
		var ro_textures = {
			"feliz": preload("res://assets/assets alanis/personagens alanis/RÔ/dialogo_ro_feliz3.png"),
			"triste": preload("res://assets/assets alanis/personagens alanis/RÔ/dialogo_ro_triste3.png"),
			"neutro": preload("res://assets/assets alanis/personagens alanis/RÔ/dialogo_ro_neutro3.png")
		}
		var karina_textures = {
			"feliz": preload("res://assets/assets alanis/personagens alanis/KARINA/dialogo_karina_feliz.png"),
			"triste": preload("res://assets/assets alanis/personagens alanis/KARINA/dialogo_karina_triste.png"),
			"neutro": preload("res://assets/assets alanis/personagens alanis/KARINA/dialogo_karina_neutro.png"),
			"raiva": preload("res://assets/assets alanis/personagens alanis/KARINA/dialogo_karina_raiva.png"),
		}
		var gal_textures = {
			"feliz": preload("res://assets/assets alanis/personagens alanis/GAL/dialogo_gau_feliz.png"),
			"triste": preload("res://assets/assets alanis/personagens alanis/GAL/dialogo_gau_triste.png"),
			"neutro": preload("res://assets/assets alanis/personagens alanis/GAL/dialogo_gau_neutro.png"),
			"raiva": preload("res://assets/assets alanis/personagens alanis/GAL/dialogo_gau_raiva.png"),
		}
		
		var scene_portraits_invasao = {
			"Lila": {"position": "right", "moods": lila_textures},
			"Ro": {"position": "left", "moods": ro_textures},
			"Karina": {"position": "left", "moods": karina_textures},
			"Gal": {"position": "right", "moods": gal_textures},
		}

		# 3. Carrega o NOVO diálogo
		var dialogue_resource: DialogueResource = load("res://dialogos/dialogo_apartamento/invasao_bar.dialogue")
		var dialogue_instance = DIALOGUE_SCENE.instantiate()
		add_child(dialogue_instance)
		dialogue_instance.start(dialogue_resource, "start", [{"scene_portraits": scene_portraits_invasao}])
		
		await dialogue_instance.dialogue_finished
		
		# 4. ATUALIZA O ESTADO GLOBAL
		GlobalState.invasao_dialogue_complete = true
		
		# 5. Reativa a Roro
		body.set_physics_process(true)
		body.set_process_input(true)
		
		# 6. ATUALIZA A CENA!
		# Isso vai esconder o Grupo Invasão permanentemente
		update_scene_state()
