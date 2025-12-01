extends CanvasLayer

# ======================
# VIDA
# ======================
var max_life: int = 100
var current_life: int = 100

@onready var life_bar: AnimatedSprite2D = $LifeBar

# ======================
# ESTRELAS
# ======================
var score_stars: int = 0
@onready var stars: Array = [
	$StarsContainer/Star1,
	$StarsContainer/Star2,
	$StarsContainer/Star3,
	$StarsContainer/Star4,
	$StarsContainer/Star5
]

# ======================
# TENTAR NOVAMENTE
# ======================
@onready var morte_painel: Control = $TenteNovamente
@onready var retry_button: Button = $TenteNovamente/RetryButton


func _ready() -> void:
	update_life(max_life)
	set_stars(0)

	# painel começa invisível
	morte_painel.visible = false

	# conectar botão
	retry_button.pressed.connect(_on_retry_button_pressed)


# ======================
# VIDA
# ======================
func update_life(value: int) -> void:
	current_life = clamp(value, 0, max_life)

	var anim_list = [
		"low",
		"half3",
		"half2",
		"half1",
		"full"
	]

	# 0–19 = low, 20–39 = half3, ...
	var index = clamp(int((current_life - 1) / 20), 0, anim_list.size() - 1)
	life_bar.play(anim_list[index])


# ======================
# ESTRELAS
# ======================
func set_stars(amount: int) -> void:
	score_stars = clamp(amount, 0, stars.size())

	for i in range(stars.size()):
		if i < score_stars:
			stars[i].play("on")
		else:
			stars[i].play("off")


func add_star() -> void:
	set_stars(score_stars + 1)


# ======================
# MOSTRAR PAINEL DE MORTE
# ======================
func show_retry() -> void:
	morte_painel.visible = true


# ======================
# BOTÃO “Tentar Novamente”
# ======================
func _on_retry_button_pressed() -> void:
	get_tree().reload_current_scene()
