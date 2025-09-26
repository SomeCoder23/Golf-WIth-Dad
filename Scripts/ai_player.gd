extends Node

class CardMove:
	var index
	var slot
	var weight = 0
	var newScore = 0

	func _init(i, s, w):
		index = i
		slot = s
		weight = w

@onready var deck: Control = $"../CardPile"
@onready var hand: GridContainer = $ComputersHand

@export var draw_threshold = 4
@export var discard_threshold = 3
@onready var player_hand: GridContainer = $"../MySide/MyHand"

#need to make ai take more risky moves (could be based on how many cards unflipped)
func _calculate_best_card_move(choosenCard, slots, thinkingTime = 0.5):
	await get_tree().create_timer(thinkingTime).timeout
	var moves = []
	var index = 0
	var cardAdvantage = 0
	if choosenCard.value == -2:
		cardAdvantage += 8
	elif choosenCard.value <= 6:
		cardAdvantage += 4
		
	if player_hand.needs_card(choosenCard):
		print("PLAYER NEEDS THIS CARD OF REAL VALUE " + str(choosenCard.real_value))
		cardAdvantage += 15
	
	#loop through all 6 slots and calculate weight of switching
	for slot in slots:
		var move = hand.recalculate_points(choosenCard, slot, true)
		move.weight += cardAdvantage
		if slot.isFlipped() and player_hand.needs_card(slot.get_card()):
			print("PLAYER NEEDS THIS SLOT's CARD")
			move.weight -= 20 #if the player needs the card of the slot that we're switching with, decrease the weight value of this move
		moves.append(move)
		index += 1
	moves.shuffle()
	moves.sort_custom(sort_weights)
	return moves[0]
	
func play_turn():
	print("COMPUTER PLAYING TURN")
	await get_tree().create_timer(0.5).timeout
	var choosenCard = deck._get_discard_card()
	var slots = hand.slots
	var move = await _calculate_best_card_move(choosenCard, slots)
	#print("BEST CARD MOVE WEIGHT WITH DISCARD: " + str(move.weight) + " SLOT #" + str(move.index))
	if move.weight < draw_threshold:
		#print("COMPUTER CHOSE TO DRAW")
		choosenCard = deck._play_turn(true)
		move = await _calculate_best_card_move(choosenCard, slots, 0.8)
		print("BEST CARD MOVE WEIGHT WITH DRAW: " + str(move.weight) + " SLOT #" + str(move.index))
		if move.weight < discard_threshold:
			print("BAD CARD...DISCARDING")
			deck.discard_card()
			return
		else:
			print("USING DRAW CARD!") 
	else:
		print("COMPUTER CHOSE DISCARD CARD")	
		deck._play_turn(false)
	print("****COMPUTER CHOSE SLOT #" + str(move.index))
	move.slot.flip_card(false)
	deck.switch_cards(move.slot, move.newScore)

func sort_weights(a, b):
	return a.weight > b.weight
