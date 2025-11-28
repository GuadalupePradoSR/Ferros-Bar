extends Node2D

const DIALOGUE_SCENE = preload("res://dialogos/dialogo_bar/balloon.tscn")
const INVASAO_DIALOGUE_RESOURCE = preload("res://dialogos/dialogo_bar/briga_bar.dialogue")

# --- TEXTURAS ---
# (Seus preloads continuam aqui igualzinho...)
var tex_ro_neutro = preload("res://assets/assets alanis/personagens alanis/RÔ/dialogo_ro_neutro2.png")
var tex_ro_triste = preload("res://assets/assets alanis/personagens alanis/RÔ/dialogo_ro_triste2.png")
var tex_ro_raiva = preload("res://assets/assets alanis/personagens alanis/RÔ/dialogo_ro_raiva2.png")
var tex_lila_neutro = preload("res://assets/assets alanis/personagens alanis/LILA/dialogo_lila_neutro2.png")
var tex_lila_triste = preload("res://assets/assets alanis/personagens alanis/LILA/dialogo_lila_triste2.png")
var tex_lila_raiva = preload("res://assets/assets alanis/personagens alanis/LILA/dialogo_lila_raiva2.png")
var tex_karina_neutro = preload("res://assets/assets alanis/personagens alanis/KARINA/dialogo_karina_neutro2.png")
var tex_karina_triste = preload("res://assets/assets alanis/personagens alanis/KARINA/dialogo_karina_triste2.png")
var tex_karina_raiva = preload("res://assets/assets alanis/personagens alanis/KARINA/dialogo_karina_raiva2.png")
var tex_gal_neutro = preload("res://assets/assets alanis/personagens alanis/GAL/dialogo_gau_neutro2.png")
var tex_gal_triste = preload("res://assets/assets alanis/personagens alanis/GAL/dialogo_gau_triste2.png")
var tex_gal_raiva = preload("res://assets/assets alanis/personagens alanis/GAL/dialogo_gau_raiva2.png")
var tex_jurandir_neutro = preload("res://assets/assets alanis/personagens alanis/JURANDIR/dialogo_jurandir_neutro2.png")
var tex_jurandir_raiva = preload("res://assets/assets alanis/personagens alanis/JURANDIR/dialogo_jurandir_raiva2.png")
var tex_jurandir_feliz = preload("res://assets/assets alanis/personagens alanis/JURANDIR/dialogo_jurandir_feliz2.png")
var tex_fabio_neutro = preload("res://assets/assets alanis/personagens alanis/FÁBIO/dialogo_fabio_neutro.png")
var tex_fabio_raiva = preload("res://assets/assets alanis/personagens alanis/FÁBIO/dialogo_fabio_raiva.png")
var tex_rodrigo_neutro = preload("res://assets/assets alanis/personagens alanis/RODRIGO/dialogo_rodrigo_neutro.png")
var tex_rodrigo_raiva = preload("res://assets/assets alanis/personagens alanis/RODRIGO/dialogo_rodrigo_raiva.png")
var tex_policial = preload("res://assets/assets alanis/personagens alanis/JURANDIR/dialogo_jurandir_feliz2.png") # Placeholder

# Estados da cena
enum InvasaoState { ENTRADA_TRIUNFAL, CHEGADA_POLICIA, BRIGA_GENERALIZADA }
var current_state = InvasaoState.ENTRADA_TRIUNFAL

var scene_portraits_invasao: Dictionary = {}

@onready var anim_player = $AnimationPlayer
@onready var camera = $Camera2D

func _ready() -> void:
	_setup_portraits()
	
	# --- CÂMERA ---
	# Como as meninas já estão lá, a câmera tem que começar FOCADA nelas/nos meninos.
	# Ajuste esse Vector2 para o meio da confusão.
	# camera.position = Vector2(500, 300) 
	
	print("Carregando cena...")
	await get_tree().create_timer(1.0).timeout
	
	# 1. Toca a animação dos homens indo pra cima ("briga")
	# MUDANÇA AQUI: Agora procuramos por "briga"
	print("Tocando animação: briga")
	if anim_player.has_animation("briga"):
		anim_player.play("briga")
		# O script vai esperar os homens chegarem perto
		await anim_player.animation_finished
	else:
		print("ERRO: Faltando animação 'briga'")
	
	# 2. Começa o diálogo
	start_dialogue("retomada_posicao")

func _setup_portraits() -> void:
	# ... (Seu código de setup de moods continua aqui igualzinho) ...
	var lila_moods = {"neutro": tex_lila_neutro, "triste": tex_lila_triste, "raiva": tex_lila_raiva}
	var ro_moods = {"neutro": tex_ro_neutro, "triste": tex_ro_triste, "raiva": tex_ro_raiva}
	var karina_moods = {"neutro": tex_karina_neutro, "triste": tex_karina_triste, "raiva": tex_karina_raiva}
	var gal_moods = {"neutro": tex_gal_neutro, "triste": tex_gal_triste, "raiva": tex_gal_raiva}
	var jurandir_moods = {"neutro": tex_jurandir_neutro, "raiva": tex_jurandir_raiva, "feliz": tex_jurandir_feliz}
	var fabio_moods = {"neutro": tex_fabio_neutro, "raiva": tex_fabio_raiva}
	var rodrigo_moods = {"neutro": tex_rodrigo_neutro, "raiva": tex_rodrigo_raiva}
	var policial_moods = {"neutro": tex_policial, "raiva": tex_policial}

	scene_portraits_invasao = {
		"Lila": {"position": "left", "moods": lila_moods},
		"Ro": {"position": "left", "moods": ro_moods},
		"Karina": {"position": "left", "moods": karina_moods},
		"Gal": {"position": "left", "moods": gal_moods},
		"Jurandir": {"position": "right", "moods": jurandir_moods},
		"Fabio": {"position": "right", "moods": fabio_moods},
		"Rodrigo": {"position": "right", "moods": rodrigo_moods},
		"Policial": {"position": "right", "moods": policial_moods}
	}

func start_dialogue(title: String) -> void:
	var dialogue_instance = DIALOGUE_SCENE.instantiate()
	add_child(dialogue_instance)
	dialogue_instance.start(INVASAO_DIALOGUE_RESOURCE, title, [{"scene_portraits": scene_portraits_invasao}])
	await dialogue_instance.dialogue_finished
	_on_dialogue_finished()

func _on_dialogue_finished() -> void:
	match current_state:
		InvasaoState.ENTRADA_TRIUNFAL:
			print("Discussão acabou. Esperando polícia...")
			current_state = InvasaoState.CHEGADA_POLICIA
			
			# --- AQUI ESTÁ O QUE VOCÊ PEDIU ---
			
			# 1. Pausa dramática (silêncio antes da sirene)
			await get_tree().create_timer(1.5).timeout
			
			# 2. Toca a animação da polícia chegando
			if anim_player.has_animation("entrada_policia"):
				print("Tocando: entrada_policia")
				anim_player.play("entrada_policia")
				# O script PAUSA aqui de novo até o policial terminar de andar
				await anim_player.animation_finished
			else:
				print("ERRO: Faltando animação 'entrada_policia'")
			
			# 3. Só agora começa o diálogo do policial
			start_dialogue("chegada_policia")
			
		InvasaoState.CHEGADA_POLICIA:
			print("Fim do papo. HORA DA BRIGA!")
			current_state = InvasaoState.BRIGA_GENERALIZADA
			
			# Aqui você pode iniciar a mecânica de luta ou tocar animação de briga
			# GlobalState.iniciar_briga = true
