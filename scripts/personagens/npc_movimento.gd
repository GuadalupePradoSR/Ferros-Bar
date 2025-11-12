extends CharacterBody2D

# 1. Variáveis
var speed = 50.0  # Velocidade do NPC (ajuste a gosto)
var current_direction = Vector2.ZERO # Direção atual

# 2. Pegar os nós filhos
# O @onready garante que o nó "esteja pronto" antes de o usarmos
@onready var anim_sprite = $AnimatedSprite2D
@onready var timer = $Timer

# 3. O que acontece quando o jogo começa
func _ready():
	# Conecta o sinal "timeout" do Timer à nossa função
	# Toda vez que o Timer apitar, ele vai chamar _on_timer_timeout
	timer.timeout.connect(_on_timer_timeout)
	
	# Já chama a função uma vez no início para ele não ficar parado
	_on_timer_timeout()

# 4. O que acontece a cada frame (para mover)
func _physics_process(delta):
	# Define a velocidade baseada na direção atual
	velocity = current_direction * speed
	
	# Move o personagem e o faz parar em paredes
	move_and_slide()
	
	# Atualiza a animação visual
	update_animation()

# 5. O CÉREBRO: O que fazer quando o Timer apitar
func _on_timer_timeout():
	# Esta lista guarda todas as direções possíveis
	var directions = [
		Vector2.UP,
		Vector2.DOWN,
		Vector2.LEFT,
		Vector2.RIGHT,
		Vector2.ZERO, # Vector2.ZERO faz ele ficar PARADO
		Vector2.ZERO  # Coloquei "parado" 2x para ser mais provável dele parar
	]
	
	# Escolhe aleatoriamente UMA das direções da lista
	current_direction = directions.pick_random()

# 6. A ANIMAÇÃO: O que mostrar na tela
func update_animation():
	if current_direction == Vector2.ZERO:
		anim_sprite.play("idle")
	elif current_direction == Vector2.UP:
		anim_sprite.play("costas")
	elif current_direction == Vector2.DOWN:
		anim_sprite.play("frente")
	elif current_direction == Vector2.LEFT:
		anim_sprite.play("esquerda")
	elif current_direction == Vector2.RIGHT:
		anim_sprite.play("direita")
