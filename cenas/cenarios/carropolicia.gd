# Script para o nó: carropolicia.gd
extends Area2D

# --- Variáveis de Configuração ---
@export var player_to_follow: Node2D
@export var lane_x_positions: PackedFloat32Array = PackedFloat32Array([484.0, 508.0])
@export var lateral_speed: float = 5.0
var health: int = 10
@export var follow_y_position: float = 534.0 # Coloque o Y que o carro fica

# --- Novas Variáveis para o Ataque ---
@export var vertical_speed: float = 150.0   # Velocidade que ele sobe/desce no eixo Y
@export var attack_y_position: float = -590.0  # A posição Y do jogador (para onde ir)

# --- Estados da IA ---
enum State { ENTERING, FOLLOWING, ATTACKING, RETURNING } # <-- ADICIONE ENTERING
var current_state = State.ENTERING # <-- MUDE O ESTADO INICIAL

# --- Variáveis Internas ---
var current_lane: int
var target_x: float
var original_y: float # Para saber para onde voltar

func _ready():
	# Define a posição inicial ACIMA da tela
	position.y = 800.0 
	
	# Armazena a posição Y para onde ele deve ir
	original_y = follow_y_position 
	
	if player_to_follow == null:
		print("AVISO: 'carropolicia' não tem um 'player_to_follow' definido no Inspetor.")
		set_physics_process(false)
		return
	
	# Pega a faixa inicial do jogador e define como seu alvo
	current_lane = player_to_follow.get_current_lane()
	target_x = lane_x_positions[current_lane]
	
	# Alinha o X do carro imediatamente para ele não "voar" dos lados
	position.x = target_x

func _physics_process(delta: float):
	# --- 1. Movimento X (Sempre acontece) ---
	# Verifica constantemente qual é a faixa alvo do jogador
	var player_lane = player_to_follow.get_current_lane()

	# Se o jogador mudou de faixa, atualiza o alvo da polícia
	if player_lane != current_lane:
		current_lane = player_lane
		target_x = lane_x_positions[current_lane]

	# Move-se suavemente em direção a esse X alvo
	var new_x = lerp(position.x, target_x, clamp(lateral_speed * delta, 0.0, 1.0))
	position.x = new_x

	# --- 2. Movimento Y (Baseado no estado) ---
	match current_state:
		State.ENTERING:
			# Move-se para baixo até a posição de seguir
			position.y = move_toward(position.y, original_y, vertical_speed * delta * 2.0) # (Multipliquei por 2 para ele entrar rápido)
			
			# Quando chegar, muda o estado para "seguindo"
			if is_equal_approx(position.y, original_y):
				current_state = State.FOLLOWING
			
		State.FOLLOWING:
			# Se está seguindo, apenas fica na sua posição Y original
			# (Usamos move_toward para garantir que ele volte se for empurrado)
			position.y = move_toward(position.y, original_y, vertical_speed * delta)

		State.ATTACKING:
			# Se está atacando, move-se para baixo em direção ao jogador
			position.y = move_toward(position.y, attack_y_position, vertical_speed * delta)
			
			# Se ele chegar na posição Y (e não bateu), ele volta
			if is_equal_approx(position.y, attack_y_position):
				current_state = State.RETURNING

		State.RETURNING:
			# Se está voltando, move-se para cima para a posição original
			position.y = move_toward(position.y, original_y, vertical_speed * delta)
			
			# Quando chegar na origem, volta a seguir o jogador
			if is_equal_approx(position.y, original_y):
				current_state = State.FOLLOWING

# --- 3. Conectando os Sinais (Triggers) ---

# Esta função será conectada ao sinal "timeout" do Timer
func _on_attack_timer_timeout():
	# Só começa um novo ataque se não estiver no meio de um
	if current_state == State.FOLLOWING:
		current_state = State.ATTACKING

# Esta função será conectada ao sinal "area_entered" do próprio 'carropolicia'
func _on_area_entered(area: Area2D):
	# Verifica se estamos ATACANDO e se a área que batemos é do "player"
	if current_state == State.ATTACKING and area.is_in_group("player"):
		print("BATEU NO JOGADOR!")
		# (Aqui você pode adicionar a lógica de 'Game Over' ou 'Perder Vida')
		
		# --- ATUALIZE AQUI ---
		area.start_shake()   # Chama o tremor (você já tinha isso)
		area.take_damage(1)  # CHAMA A NOVA FUNÇÃO DE DANO NO JOGADOR
		
		# Imediatamente começa a retornar
		current_state = State.RETURNING

func _on_timer_timeout() -> void:
	_on_attack_timer_timeout()
	

# --- Novas Funções (Adicione no final do script) ---

# Chamado quando o jogador clica na polícia
func _on_input_event(_viewport, event, _shape_idx):
	# Verifica se foi um clique do mouse esquerdo, pressionado
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		
		# Pede ao jogador (que já temos a referência!) para atirar em nós
		if player_to_follow:
			# O "self" significa que estamos passando a nós mesmos (a polícia) como alvo
			player_to_follow.shoot_at(self)

# Chamado pelo script do Tiro (Tiro.gd)
func take_damage(amount: int):
	health -= amount
	print("Vida da polícia: ", health)
	
	# Verifica se a vida acabou
	if health <= 0:
		explode()

func explode():
	# Desliga a IA e as colisões
	set_physics_process(false)
	$CollisionShape2D.set_deferred("disabled", true) # Desliga a colisão
	
	# Esconde o sprite do carro
	$Sprite2D.hide() # (Se o seu sprite da polícia tiver outro nome, mude aqui)
	
	# Mostra e toca a explosão
	$explosao.show()
	$explosao.play("boom") # Certifique-se que o nome da animação é "default" ou o que você usou
	
	# O sinal 'animation_finished' conectado a '_on_Explosao_animation_finished'
	# vai cuidar de deletar o nó depois que a animação terminar.

func _on_explosao_animation_finished() -> void:
	queue_free() # Remove o carro da polícia da cena
