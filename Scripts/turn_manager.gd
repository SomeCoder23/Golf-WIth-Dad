extends Node

@onready var turn_label: Label = $TurnPanel/TurnLabel
@onready var game_over_panel: Panel = $GameOverPanel

var last_turn := false
var round_over := false

func _ready() -> void:
	$CardPile.changed_turn.connect(change_turn)
	$ComputerSide/ComputersHand.game_over.connect(end_round)
	$MySide/MyHand.game_over.connect(end_round)
	
func end_round():
	last_turn = true
	
func change_turn():
	if round_over:
		print("GAME OVER!!!!")
		declare_winner()
		GameStuff.state = GameStuff.GameState.GAME_OVER
		return
	
	var turnLabelMsg = "Current Turn: "
	if last_turn:
		turnLabelMsg = "LAST TURN: "
		round_over = true
		
	#may change later
	print("CHANGING TURNS!!")
	if GameStuff.state == GameStuff.GameState.CHOOSING_SLOT:
		GameStuff.state = GameStuff.GameState.AI_TURN
		turn_label.set_text(turnLabelMsg + "\nComputer")
		$ComputerSide.play_turn()
	else:
		GameStuff.state = GameStuff.GameState.PLAYER_TURN
		turn_label.set_text(turnLabelMsg + "\nPlayer")
	
func initialize_turns():
	ScoreManager.debug()
	if ScoreManager.round == 0 || !ScoreManager.player_started:
		ScoreManager.player_started = true
		GameStuff.state = GameStuff.GameState.PLAYER_TURN
		turn_label.set_text("Current Turn:\nPlayer")
	else:
		ScoreManager.player_started = false
		turn_label.set_text("Current Turn:\nComputer")
		GameStuff.state = GameStuff.GameState.AI_TURN
		$ComputerSide.play_turn()
	ScoreManager.round += 1
	round_over = false
	last_turn = false
	ScoreManager.debug()
	
func declare_winner():
	$CardPile.finish_game()
	var scores = ScoreManager.get_scores()
	print("SCORESSSS: ")
	print("PLAYER: " + str(scores[0]))
	print("COMPUTER: " + str(scores[1]))
	if scores[0] < scores[1]:
		#player won
		ScoreManager.update_wins(0)
		game_over_panel.get_node("Heading").set_text("Awesome!")
		game_over_panel.get_node("Result").set_text("You Won!")
		turn_label.set_text("You're a \nWINNER!")
		
	elif scores[0] > scores[1]:
		#computer won
		ScoreManager.update_wins(1)
		game_over_panel.get_node("Heading").set_text("Oh No!")
		game_over_panel.get_node("Result").set_text("You Lost!")
		turn_label.set_text("You're a \nLOSER!")
	else:
		#tie
		game_over_panel.get_node("Heading").set_text("Dun dun dun!")
		game_over_panel.get_node("Result").set_text("A TIE!")
		turn_label.set_text("Hmm..no winner")
		
	var wins = ScoreManager.get_wins()
	game_over_panel.get_node("WinCount").set_text("       You: " + str(wins[0]) +"       Computer: " + str(wins[1]))
	game_over_panel.set_visible(true)

func restart():
	ScoreManager.resetScores()
	get_tree().reload_current_scene()

func exit():
	get_tree().quit()
