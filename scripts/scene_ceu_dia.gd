extends Node2D

@onready var animation_player = $AnimationPlayer

func _ready():
	if animation_player:
		animation_player.play("rosa")
