# Script para o nó: carropolicia.gd
extends Area2D

# --- Variáveis de Configuração ---
@export var player_to_follow: Node2D
@export var lane_x_positions: PackedFloat32Array = PackedFloat32Array([484.0, 508.0])
@export var lateral_speed: float = 5.0

# --- Novas Variáveis para o Ataque ---
@export var vertical_speed: float = 150.0   # Velocidade que ele sobe/desce no eixo Y
@export var attack_y_position: float = -590.0  # A posição Y do jogador (para onde ir)

# --- Estados da IA ---
enum State { FOLLOWING, ATTACKING, RETURNING }
var current_state = State.FOLLOWING

# --- Variáveis Internas ---
var current_lane: int
var target_x: float
var original_y: float # Para saber para onde voltar

func _ready():
	# Armazena a posição Y inicial para onde retornar
	original_y = position.y
	
	if player_to_follow == null:
		print("AVISO: 'carropolicia' não tem um 'player_to_follow' definido no Inspetor.")
		set_physics_process(false)
		return
	
	# Pega a faixa inicial do jogador e define como seu alvo
	current_lane = player_to_follow.get_current_lane()
	target_x = lane_x_positions[current_lane]
	
	# Alinha a polícia à faixa inicial imediatamente
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
		
		area.start_shake() # 'area' é o carro do jogador (carrofuga)
		
		# Imediatamente começa a retornar
		current_state = State.RETURNING





func _on_timer_timeout() -> void:
	_on_attack_timer_timeout()
