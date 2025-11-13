extends Node2D

# --- CONFIGURAÇÃO ---
# Escreva o nome exato da animação aqui no Inspetor da Godot
@export var nome_da_animacao: String = "chegada_compradoras"

@onready var anim_player = $AnimationPlayer

func _ready() -> void:
	print("--- MODO DE TESTE DE ANIMAÇÃO ---")
	print("Animação alvo: ", nome_da_animacao)
	print("Comandos: [ESPAÇO] = Tocar | [R] = Resetar (Parar)")
	
	# Verifica se a animação existe para evitar erros bobos
	if not anim_player.has_animation(nome_da_animacao):
		printerr("ERRO: A animação '" + nome_da_animacao + "' não existe no AnimationPlayer!")

func _input(event: InputEvent) -> void:
	# Tecla ESPAÇO ou ENTER para testar
	if event.is_action_pressed("ui_accept"):
		testar()
	
	# Tecla R para Resetar (útil se a animação move os bonecos e você quer voltar)
	if event.is_key_pressed(KEY_R):
		resetar()

func testar() -> void:
	if anim_player.has_animation(nome_da_animacao):
		print("Reproduzindo: ", nome_da_animacao)
		# O stop garante que ela comece do zero mesmo se já estiver rodando
		anim_player.stop()
		anim_player.play(nome_da_animacao)
	else:
		print("Animação não encontrada! Verifique o nome no Inspetor.")

func resetar() -> void:
	print("Resetando para estado inicial...")
	anim_player.stop()
	# Se você tiver uma animação RESET, é bom chamá-la
	if anim_player.has_animation("RESET"):
		anim_player.play("RESET")
