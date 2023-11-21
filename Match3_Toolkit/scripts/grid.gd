extends Node2D

# A lot of code taken from https://www.youtube.com/watch?v=YhykrMFHOV4&list=PL4vbr3u7UKWqwQlvwvgNcgDL1p_3hcNn2
# however most of it heavily changed. Where code was taken as-is, it is marked by a comment

enum states {WAIT, MOVE}
enum colors {YELLOW, PINK, ORANGE, LIGHT_GREEN, GREEN, BLUE, NONE}
enum bomb_types {HORIZONTAL, VERTICAL, COLOR, RADIUS}

var state

# Grid Variables
@export var width: int
@export var height: int
@export var start: Vector2
@export var offset: int
@export var y_offset: int
@export var use_bombs: bool
@export var use_c_bombs: bool
@export var c_bomb_limit: int

var sprites = [
	preload("res://Match 3 Assets/Pieces/Yellow Piece.png"),
	preload("res://Match 3 Assets/Pieces/Pink Piece.png"),
	preload("res://Match 3 Assets/Pieces/Orange Piece.png"),
	preload("res://Match 3 Assets/Pieces/Light Green Piece.png"),
	preload("res://Match 3 Assets/Pieces/Green Piece.png"),
	preload("res://Match 3 Assets/Pieces/Blue Piece.png")
]

var bomb_sprites = [
	preload("res://Match 3 Assets/Pieces/Yellow Row.png"),
	preload("res://Match 3 Assets/Pieces/Yellow Column.png"),
	preload("res://Match 3 Assets/Pieces/Yellow Adjacent.png"),
	preload("res://Match 3 Assets/Pieces/Rainbow.png"),
	preload("res://Match 3 Assets/Pieces/Pink Row.png"),
	preload("res://Match 3 Assets/Pieces/Pink Column.png"),
	preload("res://Match 3 Assets/Pieces/Pink Adjacent.png"),
	preload("res://Match 3 Assets/Pieces/Rainbow.png"),
	preload("res://Match 3 Assets/Pieces/Orange Row.png"),
	preload("res://Match 3 Assets/Pieces/Orange Column.png"),
	preload("res://Match 3 Assets/Pieces/Orange Adjacent.png"),
	preload("res://Match 3 Assets/Pieces/Rainbow.png"),
	preload("res://Match 3 Assets/Pieces/Light Green Row.png"),
	preload("res://Match 3 Assets/Pieces/Light Green Column.png"),
	preload("res://Match 3 Assets/Pieces/Light Green Adjacent.png"),
	preload("res://Match 3 Assets/Pieces/Rainbow.png"),
	preload("res://Match 3 Assets/Pieces/Green Row.png"),
	preload("res://Match 3 Assets/Pieces/Green Column.png"),
	preload("res://Match 3 Assets/Pieces/Green Adjacent.png"),
	preload("res://Match 3 Assets/Pieces/Rainbow.png"),
	preload("res://Match 3 Assets/Pieces/Blue Row.png"),
	preload("res://Match 3 Assets/Pieces/Blue Column.png"),
	preload("res://Match 3 Assets/Pieces/Blue Adjacent.png"),
	preload("res://Match 3 Assets/Pieces/Rainbow.png")
]

var piece_prefab = preload("res://scenes/piece.tscn")
var bomb_prefab = preload("res://scenes/bomb.tscn")
var obstacle_prefab = preload("res://scenes/obstacle.tscn")
var bomb_dict = {}
class Tile_data:
	var pos: Vector2
	var color: colors
	
	func _init(p, c):
		pos = p
		color = c


var all_pieces = []

var obstacles: PackedVector2Array = [Vector2i(2, 5), Vector2i(3, 5), Vector2i(4, 5), Vector2i(5, 5)]

var game_start = true
var c_bomb_used = false

# touch variables
var first_touch = Vector2(0, 0)
var final_touch = Vector2(0, 0)
var controlling = false

# Called when the node enters the scene tree for the first time.
func _ready():
	state = states.WAIT
	game_start = true
	all_pieces = make_2d_array()
	spawn_pieces()
	game_start = false
	state = states.MOVE

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# This function was taken from source outlined at the top
func _input(event):
	if Input.is_action_just_pressed("right_click") && use_c_bombs:
		if !c_bomb_used && state == states.MOVE && is_in_grid(pixel_to_grid(get_global_mouse_position())):
			color_bomb(pixel_to_grid(get_global_mouse_position()), colors.BLUE)
	
	if Input.is_action_just_pressed("ui_touch"):
		if state == states.MOVE && is_in_grid(pixel_to_grid(get_global_mouse_position())):
			controlling = true
			first_touch = get_global_mouse_position()
		else:
			controlling = false
	
	if Input.is_action_just_released("ui_touch"):
		if state == states.MOVE && (is_in_grid(pixel_to_grid(get_global_mouse_position())) && controlling):
			controlling = false
			final_touch = get_global_mouse_position()
			touch_difference(pixel_to_grid(first_touch), pixel_to_grid(final_touch))

# This was originally adapted from the source above, but heavily changed
func spawn_pieces():
	if game_start:
		var type_arr = []
		for k in range (0, colors.size() - 1):
			type_arr.append(k)
		
		for o in obstacles:
			var obstacle = obstacle_prefab.instantiate()
			add_child(obstacle)
			obstacle.set_position(grid_to_pixel(o.x, o.y + y_offset))
			obstacle.move(grid_to_pixel(o.x, o.y))
			all_pieces[o.x][o.y] = obstacle
		
		for i in width:
			for j in height:
				if all_pieces[i][j] != null:
					continue
				# choose random number
				randomize()
				type_arr.shuffle()
				
				var pos = 0
				var type = type_arr[pos]
				
				while (match_at(i, j, type) && pos < type_arr.size() - 1):
					pos += 1
					type = type_arr[pos]
					
				# instantiate piece
				var piece
				piece = piece_prefab.instantiate()
				add_child(piece)
				piece.set_attributes(type, sprites[type], 1)
				piece.set_position(grid_to_pixel(i, j + y_offset))
				piece.move(grid_to_pixel(i, j))
				all_pieces[i][j] = piece
		for i in width:
			for j in height:
				all_pieces[i][j].moved = false
	else:
		var type_arr = []
		for k in range (0, colors.size() - 1):
			type_arr.append(k)
		
		var spawned_pieces = []
		
		for i in width:
			for j in height:
				if all_pieces[i][j] != null:
					continue
				# choose random number
				randomize()
				type_arr.shuffle()
				
				var type = type_arr[0]
				
				# instantiate piece
				var piece = piece_prefab.instantiate()
				add_child(piece)
				spawned_pieces.append(piece)
				piece.set_attributes(type, sprites[type], 1)
				piece.set_position(grid_to_pixel(i, j + y_offset))
				piece.move(grid_to_pixel(i, j))
				all_pieces[i][j] = piece
		
		find_matches()
		
		if use_c_bombs:
			c_bomb_used = false

# This function was taken from source outlined at the top
func swap_pieces(loc, dir):
	var first_piece = all_pieces[loc.x][loc.y]
	var other_piece = all_pieces[loc.x + dir.x][loc.y + dir.y]
	
	if(first_piece == null || other_piece == null) || (!first_piece.movable || !other_piece.movable):
		return
	
	state = states.WAIT
	
	all_pieces[loc.x][loc.y] = other_piece
	all_pieces[loc.x + dir.x][loc.y + dir.y] = first_piece
	
	first_piece.move(grid_to_pixel(loc.x + dir.x, loc.y + dir.y))
	other_piece.move(grid_to_pixel(loc.x, loc.y))
	
	if !find_matches():
		all_pieces[loc.x][loc.y] = first_piece
		all_pieces[loc.x + dir.x][loc.y + dir.y] = other_piece
	
		other_piece.move(grid_to_pixel(loc.x + dir.x, loc.y + dir.y))
		first_piece.move(grid_to_pixel(loc.x, loc.y))
		
		state = states.MOVE

# This function was taken from source outlined at the top
func touch_difference(pos_1, pos_2):
	var diff = pos_2 - pos_1
	if abs(diff.x) > abs(diff.y):
		if diff.x > 0:
			swap_pieces(pos_1, Vector2.RIGHT)
		elif diff.x < 0:
			swap_pieces(pos_1, Vector2.LEFT)
	elif abs(diff.y) > abs(diff.x):
		# Vector UP is (0, -1) and DOWN is (0, 1), so a bit of confusing naming
		if diff.y > 0:
			swap_pieces(pos_1, Vector2.DOWN)
		elif diff.y < 0:
			swap_pieces(pos_1, Vector2.UP)

# This function was taken from source outlined at the top
func match_at(column, row, type):
	# this function checks if a match is created on initial generation of the board only
	if column > 1:
		if (all_pieces[column - 1][row].color == type && all_pieces[column - 2][row].color == type):
			return true
	if row > 1:
		if (all_pieces[column][row - 1].color == type && all_pieces[column][row - 2].color == type):
			return true
	return false

func get_connected_shapes():
	var visited_pieces = []
	var shapes_array = []
	
	for i in width:
		for j in height:
			var piece = all_pieces[i][j]
			if visited_pieces.has(piece) || piece.color == colors.NONE:
				continue
			var queue = []
			var shape = []
			queue.push_back(piece)
			visited_pieces.append(piece)
			
			while !queue.is_empty():
				var curr = queue.pop_front()
				shape.append(curr)
				var neighbors = get_neighbors(pixel_to_grid(curr.pos), false)
				if neighbors != null:
					for n in neighbors:
						if n.color == curr.color && !visited_pieces.has(n):
							queue.push_back(n)
							visited_pieces.append(n)
			
			if shape.size() >= 3:
				shapes_array.append(shape)
	
	return shapes_array

func get_match_centers():
	var shapes = get_connected_shapes()
	
	if shapes.size() == 0:
		return null
	
	var match_centers = []
	
	for s in shapes:
		for tile in s:
			var neighbors_h = get_horizontal_neighbors(pixel_to_grid(tile.pos))
			var neighbors_v = get_vertical_neighbors(pixel_to_grid(tile.pos))
			
			var is_center_h = false
			var is_center_v = false
			
			if neighbors_h.size() >= 2:
				is_center_h = true
				var is_center = true
				for n in neighbors_h:
					if n.color != tile.color:
						is_center = false
						is_center_h = false
					elif match_centers.has(n):
						is_center = false
				
				if is_center && !match_centers.has(tile):
					match_centers.append(tile)
			
			if neighbors_v.size() >= 2:
				is_center_v = true
				var is_center = true
				for n in neighbors_v:
					if n.color != tile.color:
						is_center = false
						is_center_v = false
					elif match_centers.has(n):
						is_center = false
				
				if is_center && !match_centers.has(tile):
					match_centers.append(tile)
			
			if is_center_h && is_center_v:
				if !match_centers.has(tile):
					match_centers.append(tile)
				for n in get_neighbors(pixel_to_grid(tile.pos), false):
					if match_centers.has(n):
						match_centers.erase(n)
	
	if match_centers.size() == 0:
		return null
	
	return match_centers

func find_matches():
	var matched_pieces = []
	
	var match_centers = get_match_centers()
	
	if match_centers == null:
		state = states.MOVE
		return false
	
	for tile in match_centers:
		matched_pieces.append(tile)
		
		var horizontal_match = []
		var vertical_match = []
		
		var queue = []
		queue.push_back(tile)
		
		while !queue.is_empty():
			var t = queue.pop_front()
			if t.color == tile.color:
				if t != tile:
					horizontal_match.append(t)
				for n in get_horizontal_neighbors(pixel_to_grid(t.pos)):
					if !horizontal_match.has(n) && n != tile:
						queue.push_back(n)
		
		queue = []
		queue.push_back(tile)
		
		while !queue.is_empty():
			var t = queue.pop_front()
			if t.color == tile.color:
				if t != tile:
					vertical_match.append(t)
				for n in get_vertical_neighbors(pixel_to_grid(t.pos)):
					if !vertical_match.has(n) && n != tile:
						queue.push_back(n)
		
		var horizontal_count = horizontal_match.size() + 1 # adding 1 because center is not in list
		var vertical_count = vertical_match.size() + 1
		
		if horizontal_count >= 3:
			matched_pieces.append_array(horizontal_match)
		if vertical_count >= 3:
			matched_pieces.append_array(vertical_match)
		
		if horizontal_count >= 5 || vertical_count >= 5:
			bomb_dict[Tile_data.new(tile.pos, tile.color)] = bomb_types.COLOR
		elif horizontal_count >= 3 && vertical_count >= 3:
			bomb_dict[Tile_data.new(tile.pos, tile.color)] = bomb_types.RADIUS
		elif vertical_count >= 4:
			bomb_dict[Tile_data.new(tile.pos, tile.color)] = bomb_types.HORIZONTAL
		elif horizontal_count >= 4:
			bomb_dict[Tile_data.new(tile.pos, tile.color)] = bomb_types.VERTICAL
	
	damage(matched_pieces)
	get_parent().get_node("destroy_timer").start()
	return true

func spawn_bombs():
	if !use_bombs:
		return
	
	for t in bomb_dict.keys():
		instantiate_bomb(t.pos, t.color, bomb_dict[t])
	bomb_dict.clear()

func color_bomb(pos, color):
	if c_bomb_limit <= 0:
		return
	
	var neighbors = get_neighbors(pos, true)
	for n in neighbors:
		n.set_color(color, sprites[color])
	all_pieces[pos.x][pos.y].set_color(color, sprites[color])
	
	c_bomb_used = true
	c_bomb_limit -= 1

func damage(array):
	for i in array:
		i.take_damage(1)

func is_null(array):
	for i in array:
		if i == null:
			return true
	return false

# This function was taken from source outlined at the top
func make_2d_array():
	var array = []
	for i in width:
		array.append([])
		for j in height:
			array[i].append(null)
			
	return array

# This function was taken from source outlined at the top
func grid_to_pixel(column, row):
	var new_x = start.x + offset * column
	var new_y = start.y - offset * row
	
	return Vector2(new_x, new_y)

# This function was taken from source outlined at the top
func pixel_to_grid(pixel_coords):
	var new_x = round((pixel_coords.x - start.x) / offset)
	var new_y = round((pixel_coords.y - start.y) / -offset)
	
	return Vector2(new_x, new_y)

# This function was taken from source outlined at the top
func is_in_grid(pos):
	if pos.x >= 0 && pos.x < width:
		if pos.y >= 0 && pos.y < height:
			return true
	return false

# This function was taken from source outlined at the top
func destroy_matched():
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				if all_pieces[i][j].matched:
					all_pieces[i][j].queue_free()
	
	spawn_bombs()
	get_parent().get_node("collapse_timer").start()

func get_neighbors(pos, get_diagonal):
	var neighbors = []
	if pos.x + 1 < width:
		if all_pieces[pos.x + 1][pos.y] != null:
			neighbors.append(all_pieces[pos.x + 1][pos.y])
	if pos.x - 1 >= 0:
		if all_pieces[pos.x - 1][pos.y] != null:
			neighbors.append(all_pieces[pos.x - 1][pos.y])
	if pos.y + 1 < height:
		if all_pieces[pos.x][pos.y + 1] != null:
			neighbors.append(all_pieces[pos.x][pos.y + 1])
	if pos.y - 1 >= 0:
		if all_pieces[pos.x][pos.y - 1] != null:
			neighbors.append(all_pieces[pos.x][pos.y - 1])
	
	if get_diagonal:
		if pos.x + 1 < width && pos.y + 1 < height:
			if all_pieces[pos.x + 1][pos.y + 1] != null:
				neighbors.append(all_pieces[pos.x + 1][pos.y + 1])
		if pos.x + 1 < width && pos.y - 1 >= 0:
			if all_pieces[pos.x + 1][pos.y - 1] != null:
				neighbors.append(all_pieces[pos.x + 1][pos.y - 1])
		if pos.x - 1 >= 0 && pos.y + 1 < height:
			if all_pieces[pos.x - 1][pos.y + 1] != null:
				neighbors.append(all_pieces[pos.x - 1][pos.y + 1])
		if pos.x - 1 >= 0 && pos.y - 1 >= 0:
			if all_pieces[pos.x - 1][pos.y - 1] != null:
				neighbors.append(all_pieces[pos.x - 1][pos.y - 1])
	
	if !neighbors.is_empty():
		return neighbors
	
	return null

func get_horizontal_neighbors(pos):
	var neighbors = []
	if pos.x + 1 < width:
		if all_pieces[pos.x + 1][pos.y] != null:
			neighbors.append(all_pieces[pos.x + 1][pos.y])
	if pos.x - 1 >= 0:
		if all_pieces[pos.x - 1][pos.y] != null:
			neighbors.append(all_pieces[pos.x - 1][pos.y])
	
	if !neighbors.is_empty():
		return neighbors
	
	return null

func get_vertical_neighbors(pos):
	var neighbors = []
	if pos.y + 1 < height:
		if all_pieces[pos.x][pos.y + 1] != null:
			neighbors.append(all_pieces[pos.x][pos.y + 1])
	if pos.y - 1 >= 0:
		if all_pieces[pos.x][pos.y - 1] != null:
			neighbors.append(all_pieces[pos.x][pos.y - 1])
	
	if !neighbors.is_empty():
		return neighbors
	
	return null

# This function was taken from source outlined at the top
func collapse_columns():
	for i in width:
		for j in height:
			if all_pieces[i][j] == null:
				for k in range(j + 1, height):
					if all_pieces[i][k] != null && all_pieces[i][k].movable:
						all_pieces[i][k].move(grid_to_pixel(i, j))
						all_pieces[i][j] = all_pieces[i][k]
						all_pieces[i][k] = null
						break
	
	get_parent().get_node("refill_timer").start()

func instantiate_bomb(pos, color, type):
	var bomb = bomb_prefab.instantiate()
	add_child(bomb)
	var sprite_pos = color * 4 + type
	bomb.set_attributes(color, bomb_sprites[sprite_pos], 1)
	bomb.set_type(type)
	bomb.set_position(pos)
	bomb.move(pos)
	var piece_pos = pixel_to_grid(pos)
	if all_pieces[piece_pos.x][piece_pos.y] != null:
		all_pieces[piece_pos.x][piece_pos.y].queue_free()
	all_pieces[piece_pos.x][piece_pos.y] = bomb

func _on_bomb_destroyed(position, type, color):
	var pos = pixel_to_grid(position)
	
	if type == bomb_types.HORIZONTAL:
		for i in width:
			all_pieces[i][pos.y].matched = true
	elif type == bomb_types.VERTICAL:
		for j in height:
			all_pieces[pos.x][j].matched = true
	elif type == bomb_types.COLOR:
		for i in width:
			for j in height:
				if all_pieces[i][j].color == color:
					all_pieces[i][j].matched = true
	elif type == bomb_types.RADIUS:
		var neighbors = get_neighbors(pos, true)
		if neighbors != null:
			for p in neighbors:
				p.matched = true

func _on_destroy_timer_timeout():
	destroy_matched()

func _on_collapse_timer_timeout():
	collapse_columns()

func _on_refill_timer_timeout():
	spawn_pieces()
