extends Node

# This variable will survive scene changes!
var score: int = 0
var deaths: int = 0 

func reset_score():
	score = 0
	deaths = 0 

func add_death():
	deaths += 1
