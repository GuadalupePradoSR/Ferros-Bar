extends Node2D

# velocidade de avanço (unidades por segundo) - ajusta conforme escala do seu jogo
@export var forward_speed: float = 100.0

# velocidade de deslocamento horizontal (quanto mais alto, mais rápido o "snap" entre faixas)
@export var lateral_speed: float = 8.0

# lista de posições X das faixas (coordenadas locais ou globais dependendo do uso)
# exemplo: duas faixas: esquerda, direita
@export var lane_x_positions: PackedFloat32Array = PackedFloat32Array([483.0, 508.0])

# índice da faixa inicial (0 = esquerda, 1 = meio, etc)
@export var start_lane: int = 1


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
	# se _ready já rodou, atualiza
	if Engine.is_editor_hint() == false and is_inside_tree():
		current_lane = clamp(start_lane, 0, lane_x_positions.size() - 1)
		target_x = lane_x_positions[current_lane]
		position.x = target_x

func _physics_process(delta: float) -> void:
	# 1) avanço constante no eixo Y (ajuste o sinal dependendo da orientação)
	# aqui assumimos que Y crescente é para baixo -> se quiser mover pra cima, use -forward_speed
	#position.y -= forward_speed * delta

	# 2) ler inputs de troca de faixa (dispara apenas quando pressionado)
	_read_lane_input()

	# 3) move suavemente em X em direção à faixa alvo
	# usamos move_toward para comportamento determinístico
	var new_x = lerp(position.x, target_x, clamp(lateral_speed * delta, 0.0, 1.0))
	position.x = new_x

# Lê o input e atualiza o índice da faixa alvo
func _read_lane_input() -> void:
	# use Input.is_action_just_pressed para evitar repetição demasiada ao segurar
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

# Funções utilitárias (opcionais) para setar faixas por código:
func go_to_lane(index: int) -> void:
	current_lane = clamp(index, 0, lane_x_positions.size() - 1)
	target_x = lane_x_positions[current_lane]

func get_current_lane() -> int:
	return current_lane
