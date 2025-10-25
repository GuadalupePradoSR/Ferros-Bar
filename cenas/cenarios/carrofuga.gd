extends Node2D

# --- Variáveis de Movimento ---
@export var forward_speed: float = 100.0
@export var lateral_speed: float = 8.0
@export var lane_x_positions: PackedFloat32Array = PackedFloat32Array([483.0, 508.0])
@export var start_lane: int = 1

# --- Novas Variáveis para o Shake (Tremor) ---
@export var shake_strength: float = 2.0     # O quanto ele vai balançar (em pixels)
@export var shake_decay_rate: float = 3.0   # Quão rápido ele para de tremer
@export var shake_frequency: float = 20.0   # Quão rápido (velocidade) ele balança
var shake_intensity: float = 0.0            # Força atual do tremor (controlado por script)
var shake_time: float = 0.0                 # Timer interno para a onda senoidal

# --- Variáveis Internas ---
var current_lane: int
var target_x: float

func _ready():
	# inicializa a faixa atual e define target_x
	current_lane = clamp(start_lane, 0, lane_x_positions.size() - 1)
	target_x = lane_x_positions[current_lane]
	# opcional: alinhar à posição da faixa imediatamente
	position.x = target_x

func set_start_lane(value: int) -> void:
	start_lane = value
	if Engine.is_editor_hint() == false and is_inside_tree():
		current_lane = clamp(start_lane, 0, lane_x_positions.size() - 1)
		target_x = lane_x_positions[current_lane]
		position.x = target_x

func _physics_process(delta: float) -> void:
	# 1) ler inputs de troca de faixa
	_read_lane_input()

	# 2) move suavemente em X em direção à faixa alvo
	var new_x = lerp(position.x, target_x, clamp(lateral_speed * delta, 0.0, 1.0))
	
	# --- 3. LÓGICA DO SHAKE ---
	if shake_intensity > 0:
		# Atualiza o tempo do shake
		shake_time += delta
		
		# Diminui a intensidade ao longo do tempo
		shake_intensity = lerp(shake_intensity, 0.0, shake_decay_rate * delta)
		
		# Calcula o offset com uma onda senoidal (balança de -1 a 1)
		var shake_offset = sin(shake_time * shake_frequency) * shake_intensity
		
		# Aplica o offset (tremor) na posição X final
		new_x += shake_offset
		
		# Reseta o tremor se a intensidade for muito baixa
		if shake_intensity < 0.1:
			shake_intensity = 0.0
			shake_time = 0.0
	
	# --- 4. APLICA A POSIÇÃO FINAL ---
	position.x = new_x

func _read_lane_input() -> void:
	if Input.is_action_just_pressed("move_left"):
		_try_move_left()
	elif Input.is_action_just_pressed("move_right"):
		_try_move_right()

func _try_move_left() -> void:
	if current_lane > 0:
		current_lane -= 1
		target_x = lane_x_positions[current_lane]

func _try_move_right() -> void:
	if current_lane < lane_x_positions.size() - 1:
		current_lane += 1
		target_x = lane_x_positions[current_lane]

func get_current_lane() -> int:
	return current_lane

# --- NOVA FUNÇÃO DE FEEDBACK DE DANO ---

# Esta função deve ser chamada pelo script da polícia
func start_shake():
	# Define a intensidade inicial da vibração
	shake_intensity = shake_strength
	# Reseta o tempo da onda para começar o balanço do zero
	shake_time = 0.0
