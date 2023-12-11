extends Node2D

enum goals {SCORE, CLEAR, RES_CLEAR}
enum clearable_pieces {YELLOW, PINK, ORANGE, LIGHT_GREEN, GREEN, BLUE, JELLYFISH, OBSTACLE}

signal end_game()

@export var goal: goals
@export var piece_to_clear: clearable_pieces
@export var needed_piece_count: int

var goal_pieces_destroyed: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	if goal == goals.SCORE:
		get_parent().get_node("gameover_timer").start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if goal == goals.RES_CLEAR && goal_pieces_destroyed >= needed_piece_count:
		emit_signal("end_game")
		set_process(false)

func _on_jellyfish_destroyed():
	if goal == goals.RES_CLEAR && piece_to_clear == clearable_pieces.JELLYFISH:
		goal_pieces_destroyed += 1

func _on_obstacle_destroyed():
	if goal == goals.RES_CLEAR && piece_to_clear == clearable_pieces.OBSTACLE:
		goal_pieces_destroyed += 1

func _on_timebomb_destroyed():
	emit_signal("end_game")

func _on_grid_grid_empty():
	if goal == goals.CLEAR:
		emit_signal("end_game")

func _on_reset_button_pressed():
	goal_pieces_destroyed = 0
	set_process(true)

func _on_grid_score_update(value, color):
	if goal == goals.RES_CLEAR:
		if color == piece_to_clear:
			goal_pieces_destroyed += 1
