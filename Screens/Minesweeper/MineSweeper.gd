extends Control

var board_squares:Array[Square]
const SQUARE_NUMBER = 100
const MINES = 10
const SQUARE = preload("res://Components/Square/Square.tscn")
var board_array = []

func _ready():
	update_board_array()
	instantiate_squares()
	set_mines()
	set_hints()

func update_board_array():
	var row:Array[int] = []
	var matrix_rows:int = SQUARE_NUMBER/%GridContainer_Minesweeper.columns
	var matrix_columns:int = %GridContainer_Minesweeper.columns
	for i in range(matrix_rows):
		for j in range(matrix_columns):
			row.append(matrix_columns*i+j)
		board_array.append(row)
		row = []

func empty_square_pressed(square:Square):
	reveal_empty_squares(square)

func reveal_empty_squares(square:Square):
	if square.is_square_pressed() or square.is_mined():
		return
	square.reveal_tile()
	var adyacents:Array = square.get_adyacent_elements(board_array)
	for i in adyacents:
		if board_squares[i].hint_score != 0:
			board_squares[i].reveal_tile()
		if board_squares[i].hint_score == 0:
			reveal_empty_squares(board_squares[i])

func hint_square_pressed():
	if all_hints_pressed():
		game_ended("Ganaste")
	
func all_hints_pressed()->bool:
	for i in get_tree().get_nodes_in_group("hints"):
		if not i.is_square_pressed():
			return false
	return true

func instantiate_squares():
	var square:Square
	for ii in range(SQUARE_NUMBER):
		square = SQUARE.instantiate()
		square.connect("game_ended_signal", game_ended)
		square.connect("hint_square_pressed_signal", hint_square_pressed)
		square.connect("empty_square_pressed_signal", empty_square_pressed)
		square.connect("flag_updated_signal", flag_updated)
		square.index = ii
		board_squares.append(square)
		%GridContainer_Minesweeper.add_child(square)

func flag_updated(is_added):
	var mines_left:int = int(%Label_minesLeft.text)
	if is_added:
		mines_left -= 1
	else:
		mines_left += 1
	%Label_minesLeft.text = str(mines_left)

func set_hints():
	var adyacents:Array
	for ii:Square in get_tree().get_nodes_in_group("mines"):
		adyacents = ii.get_adyacent_elements(board_array)
		for adyacent_index in adyacents:
			board_squares[adyacent_index].add_hint()

func set_mines():
	var mines_indexes:Array[int] = get_unique_random_numbers()
	for ii:int in mines_indexes:
		board_squares[ii].mine_square()
			
	#%Label_minesLeft.text = str(mines_indexes.size())

func get_unique_random_numbers()->Array[int]:
	var numbers:Array[int] = []
	while numbers.size() < MINES:
		var number = randi() % SQUARE_NUMBER
		if not numbers.has(number):
			numbers.append(number)
	return numbers

func game_ended(message:String):
	%Label_mine.text = message
	%Label_minesLeft.text = ""
	
	for ii:Square in get_tree().get_nodes_in_group("squares"):
		ii.disable_square()
		
	for ii:Square in get_tree().get_nodes_in_group("mines"):
		ii.explode_mine()

func _on_button_pressed():
	get_tree().change_scene_to_file("res://Screens/Minesweeper/MineSweeper.tscn")

func _on_button_return_pressed():
	get_tree().change_scene_to_file("res://Screens/MainMenu/MainMenu.tscn")
