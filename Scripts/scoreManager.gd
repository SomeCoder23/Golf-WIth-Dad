extends Node

#index 0 for player and 1 for computer
var scores := [0, 0]
var wins := [0, 0]
var round := 0
var player_started := true

func resetScores():
	scores[0] = 0
	scores[1] = 0
	
func update_score(newScore, playerIndex):
	if playerIndex != 0 and playerIndex != 1:
		return
	scores[playerIndex] = newScore
	
func get_scores():
	return scores
	
func get_wins():
	return wins

func get_score(playerIndex):
	return scores[playerIndex]

func update_wins(playerIndex):
	wins[playerIndex] += 1

func debug():
	print("******************************************")
	print("ROUND #" + str(round))
	print("PLAYER SCORE: " + str(scores[0]))
	print("COMPUTER SCORE: " + str(scores[1]))
	print("PLAYER WINS: " + str(wins[0]))
	print("COMPUTER WINS: " + str(wins[1]))
	print("PLAYER STARTD LAST ROUND: " + str(player_started))
	print("******************************************")
