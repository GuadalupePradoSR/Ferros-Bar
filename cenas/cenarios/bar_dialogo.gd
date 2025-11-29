extends Node2D

# --- RECURSOS DE DIÁLOGO ---
const DIALOGUE_SCENE = preload("res://dialogos/dialogo_bar/balloon.tscn")
const BAR_DIALOGUE_RESOURCE = preload("res://dialogos/dialogo_bar/venda_jornal.dialogue")

# --- TEXTURAS ---
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

# --- REFERÊNCIAS PARA OS 3 ANIMATION PLAYERS ---
@onready var anim_venda = $AnimationPlayer 
@onready var anim_homofobicos = $AnimationPlayer2
@onready var anim_jurandir = $AnimationPlayer3
@onready var anim_saida = $saida_bar

func _ready() -> void:
	# 1. Configura os retratos (CORRIGIDO: Agora preenche o dicionário)
	_setup_portraits()
	
	# 2. Espera um pouquinho
	await get_tree().create_timer(0.5).timeout
	
	# 3. Toca a primeira animação no Player 1
	print("Tocando animação: chegada_compradoras")
	if anim_venda.has_animation("chegada_compradoras"):
		anim_venda.play("chegada_compradoras")
		await anim_venda.animation_finished
	else:
		print("ERRO: Animação 'chegada_compradoras' não encontrada no AnimationPlayer 1")
	
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

	# --- CORREÇÃO DO PROBLEMA 1: PREENCHENDO O DICIONÁRIO FINAL ---
	scene_portraits_bar = {
		"Lila": {"position": "left", "moods": lila_moods},
		"Ro": {"position": "left", "moods": ro_moods},
		"Karina": {"position": "left", "moods": karina_moods},
		"Gal": {"position": "left", "moods": gal_moods},
		"Jurandir": {"position": "right", "moods": jurandir_moods},
		"Fabio": {"position": "right", "moods": fabio_moods},
		"Rodrigo": {"position": "right", "moods": rodrigo_moods},
		"Raquel": {"position": "right", "moods": raquel_moods},
		"Marta": {"position": "right", "moods": marta_moods}
	}

func start_bar_dialogue(title: String) -> void:
	var dialogue_instance = DIALOGUE_SCENE.instantiate()
	add_child(dialogue_instance)
	dialogue_instance.start(BAR_DIALOGUE_RESOURCE, title, [{"scene_portraits": scene_portraits_bar}])
	
	await dialogue_instance.dialogue_finished
	_on_dialogue_finished()

func _on_dialogue_finished() -> void:
	match current_state:
		
		BarState.VENDENDO:
			print("--- Fim da Venda ---")
			current_state = BarState.CONFLITO
			
			print("Tocando animação: aproximacao_homofobicos")
			if anim_homofobicos.has_animation("aproximacao_homofobicos"):
				anim_homofobicos.play("aproximacao_homofobicos")
				await anim_homofobicos.animation_finished
			else:
				print("ERRO: Animação 'aproximacao_homofobicos' não encontrada no AnimationPlayer 2")
			
			start_bar_dialogue("inicio_conflito")
			
		BarState.CONFLITO:
			print("--- Fim da Briga ---")
			current_state = BarState.EXPULSAO
			
			print("Tocando animação: intervencao_jurandir")
			if anim_jurandir.has_animation("intervencao_jurandir"):
				anim_jurandir.play("intervencao_jurandir")
				await anim_jurandir.animation_finished
			else:
				print("ERRO: Animação 'intervencao_jurandir' não encontrada no AnimationPlayer 3")
			
			start_bar_dialogue("expulsao_jurandir")
			
		BarState.EXPULSAO:
			print("--- Expulsas ---")
			current_state = BarState.FINALIZADO
			GlobalState.bar_expulsion_complete = true
			
			# --- CORREÇÃO AQUI ---
			# Agora usamos a variável 'anim_saida' para procurar a animação 'saida_bar'
			print("Tocando animação: saida_bar")
			if anim_saida.has_animation("saida_bar"):
				anim_saida.play("saida_bar")
				await anim_saida.animation_finished
			else:
				print("ERRO: Animação 'saida_bar' não encontrada DENTRO do nó 'saida_bar'!")
			
			# TROCA DE CENA (Descomentado)
			print("Trocando de cena para o Apartamento...")
			# Certifique-se que o caminho está correto!
			get_tree().change_scene_to_file("res://cenas/cenarios/apartamento.tscn")
