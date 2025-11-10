extends CanvasLayer

# vida
var max_life: int = 100
var current_life: int = 100

@onready var life_bar: AnimatedSprite2D = $LifeBar

# estrelas (pontuação)
var score_stars: int = 0
@onready var stars: Array = [
	$StarsContainer/Star1,
	$StarsContainer/Star2,
	$StarsContainer/Star3,
	$StarsContainer/Star4,
	$StarsContainer/Star5
]

func _ready() -> void:
	# Checagens iniciais
	if not life_bar:
		push_error("LifeBar não encontrado. Verifique o nó.")
	else:
		if not life_bar.sprite_frames:
			push_warning("LifeBar não tem SpriteFrames configurado.")

	if stars.is_empty():
		push_error("Nenhuma estrela encontrada no StarsContainer.")
	for i in range(stars.size()):
		if not stars[i]:
			push_warning("Star%d não encontrada." % (i + 1))
		elif not stars[i].sprite_frames:
			push_warning("Star%d não tem SpriteFrames configurado." % (i + 1))

	# inicialização
	update_life(max_life)
	set_stars(0)
	print("[HUD] Ready completo")

# Atualiza a vida e escolhe qual animação da barra mostrar
func update_life(value: int) -> void:
	current_life = clamp(value, 0, max_life)

	var animations = [
		"low",   # 0 -> 0 vidas
		"half3", # 1 -> 1 vida
		"half2", # 2 -> 2 vidas
		"half1", # 3 -> 3 vidas
		"full"   # 4 -> 4 vidas
	]

	var state = clamp(int((current_life - 1) / 20), 0, animations.size() - 1)
	var anim_name = animations[state]

	if life_bar.sprite_frames and anim_name in life_bar.sprite_frames.get_animation_names():
		life_bar.play(anim_name)
	else:
		push_warning("Animação '%s' não encontrada na LifeBar." % anim_name)

	print("[HUD] Life:", current_life, "->", anim_name)

# Atualiza estrelas (pontuação)
func set_stars(amount: int) -> void:
	score_stars = clamp(amount, 0, stars.size())

	for i in range(stars.size()):
		var star = stars[i]
		if not star:
			continue

		var available = star.sprite_frames.get_animation_names()

		if i < score_stars:
			if "on" in available:
				star.play("on")
		else:
			if "off" in available:
				star.play("off")

	print("[HUD] Stars:", score_stars)

func add_star() -> void:
	set_stars(score_stars + 1)

func remove_star() -> void:
	set_stars(score_stars - 1)

# Teste via teclado (para desenvolvimento apenas)
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_up"):
		update_life(current_life + 20)
	if Input.is_action_just_pressed("ui_down"):
		update_life(current_life - 20)
	if Input.is_action_just_pressed("ui_right"):
		add_star()
	if Input.is_action_just_pressed("ui_left"):
		remove_star()
