extends Node2D

const DIALOGUE_SCENE = preload("res://dialogos/dialogo_apartamento/balloon.tscn")

# NÃO precisamos mais desta variável, o AnimationPlayer cuida disso
# @export var door_target_position: Vector2 = Vector2(1050, 250)


# 1. Chamado assim que a cena é carregada
func _ready() -> void:
	update_scene_state()

# 2. Esta é nossa nova função "mágica"
func update_scene_state() -> void:
	
	# --- Prepara os nós dos personagens ---
	# NOTA: Certifique-se que os nomes "lilaUm", "galUm", "karinaUm" 
	# estão escritos EXATAMENTE como na sua cena
	var invasao_lila = $GrupoInvasao.get_node_or_null("lilaUm")
	var invasao_gal = $GrupoInvasao.get_node_or_null("galUm")
	var invasao_karina = $GrupoInvasao.get_node_or_null("karinaUm")
	
	# ----- ESTADO 1: ANTES DO DIÁLOGO DO JORNAL -----
	if not GlobalState.jornal_dialogue_complete:
		$lilaUm.visible = true
		$lilaUm.get_node("CollisionShape2D").disabled = false
		$lilaUm/Area2D.monitoring = true
		$lilaUm/Area2D.get_node("CollisionShape2D").disabled = false
		
		$GrupoInvasao.visible = false
		$GrupoInvasao/Area2D.monitoring = false
		$GrupoInvasao/Area2D.get_node("CollisionShape2D").disabled = true
		
		# Garante que as colisões do grupo de invasão estão desabilitadas
		if invasao_lila: invasao_lila.get_node("CollisionShape2D").disabled = true
		if invasao_gal: invasao_gal.get_node("CollisionShape2D").disabled = true
		if invasao_karina: invasao_karina.get_node("CollisionShape2D").disabled = true

	# ----- ESTADO 2: PRONTO PARA O DIÁLOGO DA INVASÃO -----
	elif GlobalState.bar_expulsion_complete and not GlobalState.invasao_dialogue_complete:
		$lilaUm.visible = false
		$lilaUm.get_node("CollisionShape2D").disabled = true
		$lilaUm/Area2D.monitoring = false
		$lilaUm/Area2D.get_node("CollisionShape2D").disabled = true
		
		$GrupoInvasao.visible = true
		$GrupoInvasao/Area2D.monitoring = true
		$GrupoInvasao/Area2D.get_node("CollisionShape2D").disabled = false
		
		# Habilita os personagens e suas colisões
		if invasao_lila: 
			invasao_lila.visible = true
			invasao_lila.get_node("CollisionShape2D").disabled = false
		if invasao_gal: 
			invasao_gal.visible = true
			invasao_gal.get_node("CollisionShape2D").disabled = false
		if invasao_karina: 
			invasao_karina.visible = true
			invasao_karina.get_node("CollisionShape2D").disabled = false

	# ----- ESTADO 3: TUDO TERMINADO -----
	else:
		# Esconde todo mundo
		$lilaUm.visible = false
		$lilaUm.get_node("CollisionShape2D").disabled = true
		$lilaUm/Area2D.monitoring = false
		$lilaUm/Area2D.get_node("CollisionShape2D").disabled = true
		
		$GrupoInvasao.visible = false
		$GrupoInvasao/Area2D.monitoring = false
		$GrupoInvasao/Area2D.get_node("CollisionShape2D").disabled = true
		
		# CORREÇÃO DO BUG: Garante que as colisões físicas do grupo sumam
		if invasao_lila: 
			invasao_lila.visible = false
			invasao_lila.get_node("CollisionShape2D").disabled = true
		if invasao_gal: 
			invasao_gal.visible = false
			invasao_gal.get_node("CollisionShape2D").disabled = true
		if invasao_karina: 
			invasao_karina.visible = false
			invasao_karina.get_node("CollisionShape2D").disabled = true


# ===================================================================
# DIÁLOGO 1: JORNAL 
# (Sem mudanças)
# ===================================================================
func _on_lila_area_body_entered(body: Node2D) -> void:
	if body.name == "roroamarela" and not GlobalState.jornal_dialogue_complete:
		
		body.set_physics_process(false)
		body.set_process_input(false)
		var anim_sprite = body.get_node_or_null("AnimatedSprite2D")
		if anim_sprite:
			anim_sprite.stop() 
			
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

		var dialogue_resource: DialogueResource = load("res://dialogos/dialogo_apartamento/jornal.dialogue") 
		var dialogue_instance = DIALOGUE_SCENE.instantiate() 
		add_child(dialogue_instance)
		dialogue_instance.start(dialogue_resource, "start", [{"scene_portraits": scene_portraits}])
		
		await dialogue_instance.dialogue_finished
		
		GlobalState.jornal_dialogue_complete = true
		
		body.set_physics_process(true) 
		body.set_process_input(true) 
		
		update_scene_state()


# ===================================================================
# DIÁLOGO 2: INVASÃO DO BAR
# (Sem mudanças)
# ===================================================================
func _on_invasao_area_body_entered(body: Node2D) -> void:
	if body.name == "roroamarela" and GlobalState.bar_expulsion_complete and not GlobalState.invasao_dialogue_complete:
		
		body.set_physics_process(false)
		body.set_process_input(false)
		var anim_sprite = body.get_node_or_null("AnimatedSprite2D")
		if anim_sprite:
			anim_sprite.stop()
			
		# Carrega todos os retratos
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

		var dialogue_resource: DialogueResource = load("res://dialogos/dialogo_apartamento/invasao_bar.dialogue")
		var dialogue_instance = DIALOGUE_SCENE.instantiate()
		add_child(dialogue_instance)
		dialogue_instance.start(dialogue_resource, "start", [{"scene_portraits": scene_portraits_invasao}])
		
		await dialogue_instance.dialogue_finished
		
		GlobalState.invasao_dialogue_complete = true
		
		body.set_process_input(false)
		
		# Inicia e espera a animação de saída
		await _animate_group_exit()
		
		body.set_physics_process(true)
		body.set_process_input(true)
		
		update_scene_state()

# ===================================================================
# --- FUNÇÃO DE ANIMAÇÃO (USANDO ANIMATIONPLAYER) ---
# ===================================================================

func _animate_group_exit() -> void: # 'async' removido
	
	# CORREÇÃO: Precisamos pegar o AnimationPlayer de DENTRO do GrupoInvasao
	var anim_player = $GrupoInvasao.get_node_or_null("AnimationPlayer")
	
	# Checagem de segurança
	if not anim_player:
		push_warning("NÃO FOI POSSÍVEL ENCONTRAR o nó 'AnimationPlayer' dentro do 'GrupoInvasao'!")
		# Se não achou, apenas pulamos a animação para não travar o jogo
		return

	# Toca a animação "SaidaDoGrupo" (que você criou)
	anim_player.play("SaidaDoGrupo")
	
	# Espera o sinal de que a animação terminou
	await anim_player.animation_finished
#
