extends CanvasLayer
## A basic dialogue balloon for use with Dialogue Manager.

var current_mood: String = "neutro"

signal dialogue_finished # Sinal para a cena principal esperar
@onready var portrait_left: TextureRect = $persona_left 
@onready var portrait_right: TextureRect = $persona_right
const DIM_COLOR = Color(0.5, 0.5, 0.5, 1.0)
const FULL_COLOR = Color(1.0, 1.0, 1.0, 1.0)
const PORTRAIT_BASE_PATH = "res://assets/assets alanis/personagens alanis/"

# Variável para armazenar a informação completa passada pela cena
var scene_characters_data: Dictionary = {}

# Nova função para carregar os retratos uma única vez no início
func _load_initial_portraits():
	# Itera sobre os dados da cena para preencher o retrato
	for char_name in scene_characters_data.keys():
		var char_data = scene_characters_data[char_name]
		var position = char_data.position
		
		var target_portrait = null
		if position == "left":
			target_portrait = portrait_left
		elif position == "right":
			target_portrait = portrait_right
			
		if target_portrait != null and char_data.moods.has("neutro"):
			# Usa a textura 'neutro' como textura inicial
			target_portrait.texture = char_data.moods.neutro
			target_portrait.show()
			
	# Garante que os retratos não utilizados estejam escondidos
	# CORREÇÃO: Usa .values() para obter um Array, que suporta .any()
	var char_values = scene_characters_data.values()
			
	# Garante que os retratos não utilizados estejam escondidos
	if not char_values.any(func(d): return d.position == "left"):
		portrait_left.hide()
	if not char_values.any(func(d): return d.position == "right"):
		portrait_right.hide()

## The action to use for advancing the dialogue
@export var next_action: StringName = &"ui_accept"

## The action to use to skip typing the dialogue
@export var skip_action: StringName = &"ui_cancel"

## The dialogue resource
var resource: DialogueResource

## Temporary game states
var temporary_game_states: Array = []

## See if we are waiting for the player
var is_waiting_for_input: bool = false

## See if we are running a long mutation and should hide the balloon
var will_hide_balloon: bool = false

## A dictionary to store any ephemeral variables
var locals: Dictionary = {}

var _locale: String = TranslationServer.get_locale()

## The current line
var dialogue_line: DialogueLine:
	set(value):
		if value:
			dialogue_line = value
			apply_dialogue_line()
		else:
			# AQUI: O diálogo terminou
			dialogue_finished.emit() # EMITE O SINAL!
			# The dialogue has finished so close the balloon
			queue_free()
	get:
		return dialogue_line


## A cooldown timer for delaying the balloon hide when encountering a mutation.
var mutation_cooldown: Timer = Timer.new()

## The base balloon anchor
@onready var balloon: Control = %Balloon

## The label showing the name of the currently speaking character
@onready var character_label: RichTextLabel = %CharacterLabel

## The label showing the currently spoken dialogue
@onready var dialogue_label: DialogueLabel = %DialogueLabel

## The menu of responses
@onready var responses_menu: DialogueResponsesMenu = %ResponsesMenu


func _ready() -> void:
	balloon.hide()
	Engine.get_singleton("DialogueManager").mutated.connect(_on_mutated)

	# If the responses menu doesn't have a next action set, use this one
	if responses_menu.next_action.is_empty():
		responses_menu.next_action = next_action

	mutation_cooldown.timeout.connect(_on_mutation_cooldown_timeout)
	add_child(mutation_cooldown)


func _unhandled_input(_event: InputEvent) -> void:
	# Only the balloon is allowed to handle input while it's showing
	get_viewport().set_input_as_handled()


func _notification(what: int) -> void:
	## Detect a change of locale and update the current dialogue line to show the new language
	if what == NOTIFICATION_TRANSLATION_CHANGED and _locale != TranslationServer.get_locale() and is_instance_valid(dialogue_label):
		_locale = TranslationServer.get_locale()
		var visible_ratio = dialogue_label.visible_ratio
		self.dialogue_line = await resource.get_next_dialogue_line(dialogue_line.id)
		if visible_ratio < 1:
			dialogue_label.skip_typing()


## Start some dialogue
func start(dialogue_resource: DialogueResource, title: String, extra_game_states: Array = []) -> void:
	for state in extra_game_states:
		if typeof(state) == TYPE_DICTIONARY and state.has("scene_portraits"):
			scene_characters_data = state.scene_portraits
			break
			
	# Carrega os retratos iniciais (apenas uma vez)
	_load_initial_portraits()
	
	# Chama a função original do Dialogue Manager
	temporary_game_states = [self] + extra_game_states
	is_waiting_for_input = false
	resource = dialogue_resource
	self.dialogue_line = await resource.get_next_dialogue_line(title, temporary_game_states)
	#temporary_game_states = [self] + extra_game_states
	#is_waiting_for_input = false
	#resource = dialogue_resource
	#self.dialogue_line = await resource.get_next_dialogue_line(title, temporary_game_states)

# Adicione esta função em qualquer lugar no seu script balloon.gd
func set_mood(new_mood: String):
	# 1. ATUALIZA O MOOD
	current_mood = new_mood
	
	# 2. FORÇA A APLICAÇÃO DO NOVO SPRITE E FOCO
	_update_portraits_for_mood_change()

func _update_portraits_for_mood_change():
	# Esta é uma versão simplificada do apply_dialogue_line (seção 3 e 4)
	# que é executada fora do fluxo normal do diálogo.
	
	var character_name = dialogue_line.character
	var speaker_data: Dictionary = scene_characters_data.get(character_name, {})
	var speaker_position = speaker_data.get("position", "")
	var speaker_moods: Dictionary = speaker_data.get("moods", {})
	
	var is_left_speaker = speaker_position == "left"
	var is_right_speaker = speaker_position == "right"
	
	# 3. ATUALIZA A TEXTURA (SPRITE)
	var target_portrait = null
	if is_left_speaker:
		target_portrait = portrait_left
	elif is_right_speaker:
		target_portrait = portrait_right
		
	if target_portrait != null:
		var new_texture = speaker_moods.get(current_mood, speaker_moods.get("neutro"))
		if new_texture != null:
			target_portrait.texture = new_texture
			target_portrait.show()

	# 4. APLICA O FOCO (DIMMING)
	if is_left_speaker:
		portrait_left.modulate = FULL_COLOR
		portrait_right.modulate = DIM_COLOR
	elif is_right_speaker:
		portrait_right.modulate = FULL_COLOR
		portrait_left.modulate = DIM_COLOR
	else:
		# Narrador ou personagem fora de foco
		portrait_left.modulate = DIM_COLOR
		portrait_right.modulate = DIM_COLOR

## Apply any changes to the balloon given a new [DialogueLine].
func apply_dialogue_line() -> void:
	mutation_cooldown.stop()

	is_waiting_for_input = false
	balloon.focus_mode = Control.FOCUS_ALL
	balloon.grab_focus()
	
	var character_name = dialogue_line.character

	# 1. LÊ AS TAGS DA LINHA PARA MUDAR A EMOÇÃO (MOOD)
	#current_mood = "neutro" # Padrão para neutro
	#for tag in dialogue_line.tags:
		#if tag.begins_with("mood:"):
			#current_mood = tag.split(":")[1]
			#break

	# 2. ENCONTRA O PERSONAGEM FALANTE E SUA POSIÇÃO
	var speaker_data: Dictionary = scene_characters_data.get(character_name, {})
	var speaker_position = speaker_data.get("position", "")
	var speaker_moods: Dictionary = speaker_data.get("moods", {})
	
	var is_left_speaker = speaker_position == "left"
	var is_right_speaker = speaker_position == "right"
	
	if is_left_speaker or is_right_speaker:
		# Se o falante mudou (ou a linha é a primeira),
		# garantimos o sprite e o foco baseados no mood atual.
		
		# O mood aqui será o do último [do set_mood] OU "neutro" se não houver um [do].
		
		var target_portrait = null
		if is_left_speaker:
			target_portrait = portrait_left
		elif is_right_speaker:
			target_portrait = portrait_right
			
		if target_portrait != null:
			var new_texture = speaker_moods.get(current_mood, speaker_moods.get("neutro"))
			if new_texture != null:
				target_portrait.texture = new_texture
				target_portrait.show()

		# 4. APLICA O EFEITO DE FOCO (Dimming)
		if is_left_speaker:
			portrait_left.modulate = FULL_COLOR
			portrait_right.modulate = DIM_COLOR
		elif is_right_speaker:
			portrait_right.modulate = FULL_COLOR
			portrait_left.modulate = DIM_COLOR
	else:
		# Narrador ou personagem fora de foco
		portrait_left.modulate = DIM_COLOR
		portrait_right.modulate = DIM_COLOR

	character_label.visible = not dialogue_line.character.is_empty()
	character_label.text = tr(dialogue_line.character, "dialogue")

	dialogue_label.hide()
	dialogue_label.dialogue_line = dialogue_line

	responses_menu.hide()
	responses_menu.responses = dialogue_line.responses

	# Show our balloon
	balloon.show()
	will_hide_balloon = false

	dialogue_label.show()
	if not dialogue_line.text.is_empty():
		dialogue_label.type_out()
		await dialogue_label.finished_typing

	# Wait for input
	if dialogue_line.responses.size() > 0:
		balloon.focus_mode = Control.FOCUS_NONE
		responses_menu.show()
	elif dialogue_line.time != "":
		var time = dialogue_line.text.length() * 0.02 if dialogue_line.time == "auto" else dialogue_line.time.to_float()
		await get_tree().create_timer(time).timeout
		next(dialogue_line.next_id)
	else:
		is_waiting_for_input = true
		balloon.focus_mode = Control.FOCUS_ALL
		balloon.grab_focus()


## Go to the next line
func next(next_id: String) -> void:
	self.dialogue_line = await resource.get_next_dialogue_line(next_id, temporary_game_states)


#region Signals


func _on_mutation_cooldown_timeout() -> void:
	if will_hide_balloon:
		will_hide_balloon = false
		balloon.hide()


func _on_mutated(_mutation: Dictionary) -> void:
	is_waiting_for_input = false
	will_hide_balloon = true
	mutation_cooldown.start(0.1)


func _on_balloon_gui_input(event: InputEvent) -> void:
	# See if we need to skip typing of the dialogue
	if dialogue_label.is_typing:
		var mouse_was_clicked: bool = event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed()
		var skip_button_was_pressed: bool = event.is_action_pressed(skip_action)
		if mouse_was_clicked or skip_button_was_pressed:
			get_viewport().set_input_as_handled()
			dialogue_label.skip_typing()
			return

	if not is_waiting_for_input: return
	if dialogue_line.responses.size() > 0: return

	# When there are no response options the balloon itself is the clickable thing
	get_viewport().set_input_as_handled()

	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		next(dialogue_line.next_id)
	elif event.is_action_pressed(next_action) and get_viewport().gui_get_focus_owner() == balloon:
		next(dialogue_line.next_id)


func _on_responses_menu_response_selected(response: DialogueResponse) -> void:
	next(response.next_id)


#endregion
