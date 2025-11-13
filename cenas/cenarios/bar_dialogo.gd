extends Node2D

const DIALOGUE_SCENE = preload("res://dialogos/dialogo_bar/balloon.tscn")
const BAR_DIALOGUE_RESOURCE = preload("res://dialogos/dialogo_bar/venda_jornal.dialogue")

var tex_ro_neutro = preload("res://assets/assets alanis/personagens alanis/RÔ/dialogo_ro_neutro2.png")
var tex_ro_feliz = preload("res://assets/assets alanis/personagens alanis/RÔ/dialogo_ro_feliz2.png")
var tex_ro_triste = preload("res://assets/assets alanis/personagens alanis/RÔ/dialogo_ro_triste2.png")
var tex_ro_raiva = preload("res://assets/assets alanis/personagens alanis/RÔ/dialogo_ro_raiva2.png")

var tex_lila_neutro = preload("res://assets/assets alanis/personagens alanis/LILA/dialogo_lila_neutro2.png")
var tex_lila_feliz = preload("res://assets/assets alanis/personagens alanis/LILA/dialogo_lila_feliz2.png")
var tex_lila_triste = preload("res://assets/assets alanis/personagens alanis/LILA/dialogo_lila_triste2.png")
var tex_lila_raiva = preload("res://assets/assets alanis/personagens alanis/LILA/dialogo_lila_raiva2.png")

var tex_karina_neutro = preload("res://assets/assets alanis/personagens alanis/KARINA/dialogo_karina_neutro2.png")
var tex_karina_feliz = preload("res://assets/assets alanis/personagens alanis/KARINA/dialogo_karina_feliz2.png")
var tex_karina_triste = preload("res://assets/assets alanis/personagens alanis/KARINA/dialogo_karina_triste2.png")
var tex_karina_raiva = preload("res://assets/assets alanis/personagens alanis/KARINA/dialogo_karina_raiva2.png")

var tex_gal_neutro = preload("res://assets/assets alanis/personagens alanis/GAL/dialogo_gau_neutro2.png")
var tex_gal_feliz = preload("res://assets/assets alanis/personagens alanis/GAL/dialogo_gau_feliz2.png")
var tex_gal_triste = preload("res://assets/assets alanis/personagens alanis/GAL/dialogo_gau_triste2.png")
var tex_gal_raiva = preload("res://assets/assets alanis/personagens alanis/GAL/dialogo_gau_raiva2.png")

var tex_jurandir_neutro = preload("res://assets/assets alanis/personagens alanis/JURANDIR/dialogo_jurandir_neutro2.png")
var tex_jurandir_raiva = preload("res://assets/assets alanis/personagens alanis/JURANDIR/dialogo_jurandir_raiva2.png")

var tex_fabio_neutro = preload("res://assets/assets alanis/personagens alanis/FÁBIO/dialogo_fabio_neutro.png")
var tex_fabio_raiva = preload("res://assets/assets alanis/personagens alanis/FÁBIO/dialogo_fabio_raiva.png")

var tex_rodrigo_neutro = preload("res://assets/assets alanis/personagens alanis/RODRIGO/dialogo_rodrigo_neutro.png")
var tex_rodrigo_raiva = preload("res://assets/assets alanis/personagens alanis/RODRIGO/dialogo_rodrigo_raiva.png")

var tex_raquel_neutro = preload("res://assets/assets alanis/personagens alanis/RAQUEL/dialogo_raquel_neutro.png")
var tex_raquel_feliz = preload("res://assets/assets alanis/personagens alanis/RAQUEL/dialogo_raquel_feliz.png")

var tex_marta_neutro = preload("res://assets/assets alanis/personagens alanis/DONA MARTA/dialogo_marta_neutro.png")
var tex_marta_feliz = preload("res://assets/assets alanis/personagens alanis/DONA MARTA/dialogo_marta_feliz.png")

# Estados da cena do bar
enum BarState { VENDENDO, CONFLITO, EXPULSAO, FINALIZADO }
var current_state = BarState.VENDENDO

var scene_portraits_bar: Dictionary = {}

# Referência para o AnimationPlayer (Certifique-se que ele existe na cena)
@onready var anim_player = $chegada_compradoras

func _ready() -> void:
	_setup_portraits()
	
	# --- PASSO 1: CENA INICIA ---
	# Antes do primeiro diálogo, as compradoras precisam chegar.
	# Crie uma animação chamada "chegada_compradoras" onde Raquel e Marta andam até a mesa.
	if anim_player.has_animation("chegada_compradoras"):
		anim_player.play("chegada_compradoras")
		await anim_player.animation_finished
	else:
		print("ALERTA: Crie a animação 'chegada_compradoras' no AnimationPlayer")
	
	# Só depois da animação terminar, o diálogo começa
	start_bar_dialogue("venda_jornal")


func _setup_portraits() -> void:
	var lila_moods = {"neutro": tex_lila_neutro, "feliz": tex_lila_feliz, "triste": tex_lila_triste, "raiva": tex_lila_raiva}
	var ro_moods = {"neutro": tex_ro_neutro, "feliz": tex_ro_feliz, "triste": tex_ro_triste} 
	var karina_moods = {"neutro": tex_karina_neutro, "feliz": tex_karina_feliz, "triste": tex_karina_triste, "raiva": tex_karina_raiva}
	var gal_moods = {"neutro": tex_gal_neutro, "feliz": tex_gal_feliz, "triste": tex_gal_triste, "raiva": tex_gal_raiva}
	var jurandir_moods = {"neutro": tex_jurandir_neutro, "raiva": tex_jurandir_raiva}
	var fabio_moods = {"neutro": tex_fabio_neutro, "raiva": tex_fabio_raiva}
	var rodrigo_moods = {"neutro": tex_rodrigo_neutro, "raiva": tex_rodrigo_raiva}
	var raquel_moods = {"neutro": tex_raquel_neutro, "feliz": tex_raquel_feliz}
	var marta_moods = {"neutro": tex_marta_neutro, "feliz": tex_marta_feliz}

	scene_portraits_bar = {
		"Lila": {"position": "left", "moods": lila_moods},
		"Ro": {"position": "left", "moods": ro_moods},
		"Karina": {"position": "left", "moods": karina_moods},
		"Gal": {"position": "left", "moods": gal_moods},
		"Jurandir": {"position": "right", "moods": jurandir_moods},
		"Fabio": {"position": "right", "moods": fabio_moods},
		"Rodrigo": {"position": "right", "moods": rodrigo_moods},
		"Raquel": {"position": "right", "moods": raquel_moods}, # Raquel na direita falando com elas
		"Marta": {"position": "right", "moods": marta_moods},
	}

func start_bar_dialogue(title: String) -> void:
	var dialogue_instance = DIALOGUE_SCENE.instantiate()
	add_child(dialogue_instance)
	dialogue_instance.start(BAR_DIALOGUE_RESOURCE, title, [{"scene_portraits": scene_portraits_bar}])
	await dialogue_instance.dialogue_finished
	_on_dialogue_finished()

# --- A LÓGICA CINEMATOGRÁFICA ---
func _on_dialogue_finished() -> void:
	match current_state:
		
		BarState.VENDENDO:
			# O diálogo da venda acabou.
			# Agora mudamos o estado para CONFLITO.
			current_state = BarState.CONFLITO
			
			# Toca a animação dos homens chegando e cercandos a mesa.
			# DICA: Nessa animação, faça a Raquel e a Marta irem embora antes deles chegarem.
			if anim_player.has_animation("aproximacao_homofobicos"):
				anim_player.play("aproximacao_homofobicos")
				await anim_player.animation_finished
			
			# Inicia o diálogo da briga
			start_bar_dialogue("inicio_conflito")
			
		BarState.CONFLITO:
			# O bate-boca com Fábio e Rodrigo acabou.
			# Agora é a hora do Jurandir.
			current_state = BarState.EXPULSAO
			
			# Toca a animação do Jurandir saindo do balcão e vindo impor moral.
			if anim_player.has_animation("intervencao_jurandir"):
				anim_player.play("intervencao_jurandir")
				await anim_player.animation_finished
			
			# Inicia o diálogo final da expulsão
			start_bar_dialogue("expulsao_jurandir")
			
		BarState.EXPULSAO:
			# Jurandir expulsou todo mundo.
			current_state = BarState.FINALIZADO
			
			# Atualiza o estado global
			GlobalState.bar_expulsion_complete = true 
			
			# Toca a animação triste delas saindo do bar.
			if anim_player.has_animation("saida_bar"):
				anim_player.play("saida_bar")
				await anim_player.animation_finished
			
			# Muda de cena
			# get_tree().change_scene_to_file("res://cenas/apartamento.tscn")
