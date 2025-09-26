extends Node

@onready var deckCard: TextureRect = $"../DeckCard"
@export var cardDeck:= []
@export var cardBack : Texture2D
@onready var deckPile = $DeckPile
@onready var discardPile = $DiscardCard
@onready var message: Label = $"../Message"
@onready var computers_hand: GridContainer = $"../ComputerSide/ComputersHand"
@onready var my_hand: GridContainer = $"../MySide/MyHand"
@onready var switch_card: TextureRect = $"../SwitchCard"
signal changed_turn
var discardDeck := []
var choosenCard 

func _ready() -> void:
	my_hand.initialized_cards.connect(start_round)
	deckPile.chose_pile.connect(_play_turn.bind(true))
	$DiscardPile.chose_pile.connect(_play_turn.bind(false))
	_initialize_cards()
	_shuffleDeck()

func _initialize_cards():
	var texture
	var value
	var real_value
	var cardData := []
	for card in cardDeck:
		texture = card as Texture2D
		real_value = texture.resource_path.split("_")
		value = real_value[real_value.size() - 1].split(".")
		if int(value[0]) < 10:
			real_value = value[0]
		else:
			real_value = real_value[real_value.size() - 2]
		#print("CARD OF VALUE = " + value[0] + " Real Value = " + str(real_value))
		cardData.append(CardObj.new(int(value[0]), card, real_value))
	cardDeck = cardData

func _distributeCards() -> void:	
	#set first discard card
	var card = cardDeck[0]
	discardDeck.append(card)
	discardPile.set_texture(card.sprite)
	cardDeck.remove_at(0)
	
	#distribute 6 cards to each player
	var myHand := []
	var computersHand := []
	
	while myHand.size() < 6:
		myHand.append(cardDeck[0])
		computersHand.append(cardDeck[1])
		cardDeck.remove_at(0)
		cardDeck.remove_at(0)
		
	await my_hand.initialize_cards(myHand, cardBack, true, deckCard)
	await computers_hand.initialize_cards(computersHand, cardBack, false, deckCard)
	
	message.set_text("Flip 2 of your cards to continue")
	message.visible = true
	
func _play_turn(choseDraw : bool):
	if GameStuff.state == GameStuff.GameState.CHOOSING_SLOT:
		return
	
	var msg := ""
	if choseDraw:
		SoundManager.play_cardFlip()
		msg = "Discard card or choose one of your cards to switch"
		choosenCard = cardDeck[0]
		discardDeck.append(choosenCard)
		deckCard.set_texture(choosenCard.sprite)
		cardDeck.remove_at(0)
		if cardDeck.is_empty():
			reshuffle_discard_pile()
	else:
		choosenCard = discardDeck[discardDeck.size() - 1]
		msg = "Choose one of your cards to switch"
				
	if GameStuff.state != GameStuff.GameState.AI_TURN:
		$DiscardBtn.visible = choseDraw
		$DrawBtn.visible = !choseDraw
		message.set_text(msg)
		GameStuff.state = GameStuff.GameState.CHOOSING_SLOT
		message.visible = true
		
	return choosenCard
	
func _shuffleDeck(distribute := true) -> void:
	#shuffle the sprites 
	var shuffledCards := []
	while cardDeck.size() > 1:
		var ranCard = randi() % (cardDeck.size())
		shuffledCards.append(cardDeck[ranCard])
		cardDeck.remove_at(ranCard)
		
	shuffledCards.append(cardDeck[0])
	cardDeck = shuffledCards
	if distribute:
		_distributeCards()
	
func start_round():
	message.visible = false
	computers_hand.flip2random()
	var turn = $"..".initialize_turns()
	
func discard_card():
	if GameStuff.state == GameStuff.GameState.PLAYER_TURN:
		return	
	await _move_card(discardPile.global_position)
	discardPile.set_texture(discardDeck[discardDeck.size() - 1].sprite)
	end_turn()
	
func draw_card():
	GameStuff.state = GameStuff.GameState.PLAYER_TURN
	_play_turn(true)
	
func end_turn():
	message.visible = false
	$DiscardBtn.visible = false
	$DrawBtn.visible = false
	deckCard.set_texture(cardBack)
	emit_signal("changed_turn")

func _move_card(to, card := deckCard, speed := 0.15):
	SoundManager.play_cardSfx()
	var startPos = card.position	
	var tween = create_tween()
	tween.tween_property(card, "position", to, speed)
	await tween.finished
	card.position = startPos

func set_switchCard(card, position):
	switch_card.visible = true
	switch_card.set_texture(card.sprite)
	switch_card.position = position
	await _move_card(discardPile.global_position, switch_card, 0.35)
	switch_card.visible = false
	
func switch_cards(slot, newScore := 0):
	_move_card(slot.global_position, deckCard, 0.35)
	set_switchCard(slot.get_card(), slot.global_position)
	discardDeck.append(slot.get_card())
	discardPile.set_texture(discardDeck[discardDeck.size() - 1].sprite)
	if GameStuff.state == GameStuff.GameState.AI_TURN:
		computers_hand.set_score(newScore)
		slot.set_card(choosenCard, true)
	else:
		my_hand.recalculate_points(choosenCard, slot)
		slot.flip_card(false)
	end_turn()

func _get_discard_card() -> CardObj:
	return discardDeck[discardDeck.size() - 1]

func reshuffle_discard_pile():
	#keep top discard card and shuffle rest of discard pile array and place it in deck array
	print("DRAW DECK EMPTY, RESHUFFLING DISCARD PILE")
	var discardCard = discardDeck[-1]
	cardDeck = discardDeck.duplicate()
	cardDeck.remove_at(-1)
	_shuffleDeck(false)
	discardDeck.clear()
	discardDeck.append(discardCard)
	
func finish_game():
	my_hand.flip_all_hand()
	computers_hand.flip_all_hand()
