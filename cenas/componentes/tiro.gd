# Script: Tiro.gd
extends Area2D

var speed: float = 600.0  # Velocidade do tiro em pixels/segundo
var direction: Vector2 = Vector2.ZERO # Direção será definida pelo jogador

func _ready():
	# Conecta o sinal de colisão deste tiro ao seu próprio script
	connect("area_entered", _on_area_entered)
	
	# Conecta o sinal de "saiu da tela"
	$VisibleOnScreenNotifier2D.connect("screen_exited", _on_screen_exited)

func _physics_process(delta: float):
	# Move o tiro na direção definida
	position += direction * speed * delta

# Função pública para o jogador nos dizer a direção
func set_direction(dir: Vector2):
	direction = dir
	rotation = dir.angle() # Opcional: faz o sprite do tiro apontar na direção

# Chamado quando o tiro bate em algo
func _on_area_entered(area: Area2D):
	# Verifica se o que batemos está no grupo "police"
	if area.is_in_group("police"):
		# Avisa a polícia que ela tomou dano
		area.take_damage(1)
		# Destrói o tiro
		queue_free()

# Chamado quando o tiro sai da tela
func _on_screen_exited():
	queue_free() # Destrói o tiro para não poluir o jogo
