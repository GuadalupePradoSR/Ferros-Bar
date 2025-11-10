# carrofuga.gd

extends Node2D

signal health_changed(new_health)
signal player_died # Um sinal que avisará a cena principal que morremos
var player_health: int = 6
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

const BulletScene = preload("res://cenas/componentes/tiro.tscn")

# --- Variáveis Internas ---
var current_lane: int
var target_x: float

func _ready():
	# Espera até que a árvore de cena inteira esteja pronta
	await get_tree().process_frame
	
	# inicializa a faixa atual e define target_x
	current_lane = clamp(start_lane, 0, lane_x_positions.size() - 1)
	target_x = lane_x_positions[current_lane]
	# opcional: alinhar à posição da faixa imediatamente
	position.x = target_x
	
	health_changed.emit(player_health)

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
	
	
# Esta função é chamada pela polícia quando o jogador clica nela
func shoot_at(target: Node2D):
	# Cria uma nova instância da cena do tiro
	var bullet = BulletScene.instantiate()
	
	# Calcula a direção do jogador até o alvo (a polícia)
	var direction = (target.global_position - global_position).normalized()
	
	# Adiciona o tiro na cena principal (não como filho do carro)
	get_parent().add_child(bullet)
	
	# Define a posição inicial e a direção do tiro
	bullet.global_position = global_position # Começa na posição do jogador
	bullet.set_direction(direction) # Diz ao tiro para onde ir


# Esta função será chamada pela polícia
func take_damage(amount: int):
	# Só toma dano se ainda estiver vivo
	if player_health > 0:
		player_health -= amount
		print("Vida do Jogador: ", player_health)
		
		health_changed.emit(player_health) # Avisa a UI sobre a nova vida
		
		# Dá o feedback visual
		start_shake()
		
		# Verifica se a vida acabou
		if player_health <= 0:
			player_explode()

func player_explode():
	# Desliga o movimento e a leitura de inputs
	set_physics_process(false)
	
	# Desliga a colisão (assumindo que o CollisionShape2D é filho)
	$CollisionShape2D.set_deferred("disabled", true)
	
	# Esconde o sprite do carro
	$Sprite2D.hide()
	
	# Mostra e toca a explosão
	$playerexplosao.show()
	$playerexplosao.play("fim")

func _on_playerexplosao_animation_finished() -> void:
	# Avisa a cena principal (corrida.gd) que o jogador morreu
	player_died.emit()


func _on_body_entered(body: Node2D) -> void:
	# Verifica se o que batemos tem a etiqueta "obstacles"
	if body.is_in_group("obstaculos"):
		# Se sim, chama sua função de dano (que já treme e tira 1HP)
		take_damage(1)
