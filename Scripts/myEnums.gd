extends Node

enum Difficulty { EASY, MEDIUM, HARD }
enum CardState { }
enum GameState { IDLE, PLAYER_TURN, CHOOSING_SLOT, AI_TURN, GAME_OVER }

var state := GameState.IDLE
