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
	update_life(max_life)
	set_stars(0)

# ======================
# VIDA
# ======================

func update_life(value: int) -> void:
	current_life = clamp(value, 0, max_life)

	var animations = [
		"low",
		"half3",
		"half2",
		"half1",
		"full"
	]

	var state = clamp(int((current_life - 1) / 20), 0, animations.size() - 1)
	var anim_name = animations[state]

	if life_bar.sprite_frames:
		life_bar.play(anim_name)

# ======================
# ESTRELAS
# ======================

func set_stars(amount: int) -> void:
	score_stars = clamp(amount, 0, stars.size())

	for i in range(stars.size()):
		var star = stars[i]
		if i < score_stars:
			star.play("on")
		else:
			star.play("off")

func add_star() -> void:
	set_stars(score_stars + 1)

func remove_star() -> void:
	set_stars(score_stars - 1)
