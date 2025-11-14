extends Node2D

# --- CONFIGURAÇÃO ---
# Escreva o nome exato da animação aqui no Inspetor da Godot
@export var nome_da_animacao: String = "intervencao_jurandir"

# CORREÇÃO AQUI: O nó se chama AnimationPlayer, não o nome da animação
@onready var anim_player = $intervencao_jurandir

func _ready() -> void:
	print("--- MODO DE TESTE DE ANIMAÇÃO ---")
	# Verificação de segurança:
	if anim_player == null:
		printerr("ERRO CRÍTICO: Não encontrei o nó 'AnimationPlayer' na cena!")
		return

	print("Animação alvo: ", nome_da_animacao)
	print("Comandos: [ESPAÇO] = Tocar | [R] = Resetar (Parar)")
	
	if not anim_player.has_animation(nome_da_animacao):
		printerr("ERRO: A animação '" + nome_da_animacao + "' não existe dentro do AnimationPlayer!")
	else:
		print("Tudo pronto! Aperte ESPAÇO para ver a mágica.")

func _input(event: InputEvent) -> void:
	# Tecla ESPAÇO ou ENTER para tocar
	if event.is_action_pressed("ui_accept"):
		testar()
	
	# Tecla R para Resetar
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_R:
			resetar()

func testar() -> void:
	if anim_player and anim_player.has_animation(nome_da_animacao):
		print("Reproduzindo: ", nome_da_animacao)
		anim_player.stop()
		anim_player.play(nome_da_animacao)
	else:
		print("Não consigo tocar. Verifique os erros no Output.")

func resetar() -> void:
	print("Resetando...")
	if anim_player:
		anim_player.stop()
		if anim_player.has_animation("RESET"):
			anim_player.play("RESET")
