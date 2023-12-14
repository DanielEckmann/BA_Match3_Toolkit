extends Piece

signal time_bomb_destroyed()

@export var turns_left: int

func _ready():
	self.time_bomb_destroyed.connect(get_node("/root/game_window/GoalCounter")._on_timebomb_destroyed)
	$timerlabel.text = "%d" % turns_left

func _on_turn_end():
	turns_left -= 1
	$timerlabel.text = "%d" % turns_left
	if turns_left <= 0:
		emit_signal("time_bomb_destroyed")
	super._on_turn_end()
