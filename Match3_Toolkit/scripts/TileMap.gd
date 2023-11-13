extends TileMap

# Grid Variables
@export var width: int
@export var height: int
@export var start: Vector2i
@export var offset: int
@export var y_offset: int


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func test_place_tiles():
	for i in width:
		for j in height:
			var curr_coords = start + Vector2i(i, j)
			set_cell(-1, curr_coords, 1, Vector2i(0, 0), 0)
			var tile = get_cell_tile_data(-1, curr_coords)
			
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
