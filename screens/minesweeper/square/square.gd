class_name Square
extends TextureButton

#region texture constants
const CLOSED = "uid://ui2waiwle1il"
const FLAG = "uid://d2cp2mce8mx20"
const MINE = "uid://be7wrvo21i7ll"
const MINE_RED = "uid://b5la0vud1kaj1"
const TYPE_0 = "uid://cq4a5mcjq2gw0"
const TYPE_1 = "uid://bajru73r8qdlo"
const TYPE_2 = "uid://dim8edvf800b1"
const TYPE_3 = "uid://bsuhfdnyjnuf"
const TYPE_4 = "uid://0r4avphf6u4o"
const TYPE_5 = "uid://i20mttb1qitq"
const TYPE_6 = "uid://ktpxsugm7g52"
const TYPE_7 = "uid://dtmydp2w0kkhm"
const TYPE_8 = "uid://1uxqshjmxn8y"
#endregion

var flagged:bool = false
var hint_score = 0

signal empty_square_pressed(node:Square)
signal hint_square_pressed()
signal flag_updated()
signal game_ended()

func is_mined():
	if hint_score == -1:
		return true
	else:
		return false

func is_square_pressed():
	return self.disabled

func _ready():
	set_texture_square(CLOSED)

func handle_selected_square():
	if flagged:
		return
	match hint_score:
		-1:
			game_ended.emit("Perdiste")
		0:
			empty_square_pressed.emit(self)
		_:
			disable_square()
			hint_square_pressed.emit()
	reveal_texture_score()

func reveal_texture_score():
	disable_square()
	if flagged:
		update_flag_square()
	match hint_score:
		-1:
			set_texture_square(MINE_RED)
		0:
			set_texture_square(TYPE_0)
		1:
			set_texture_square(TYPE_1)
		2:
			set_texture_square(TYPE_2)
		3:
			set_texture_square(TYPE_3)
		4:
			set_texture_square(TYPE_4)
		5:
			set_texture_square(TYPE_5)
		6:
			set_texture_square(TYPE_6)
		7:
			set_texture_square(TYPE_7)
		8:
			set_texture_square(TYPE_8)

func update_flag_square():
	if not flagged:
		set_texture_square(FLAG)
	else:
		set_texture_square(CLOSED)
	flagged = !flagged
	flag_updated.emit(flagged)

func set_texture_square(texture):
	self.texture_normal = load(texture)
	
func _on_gui_input(event):
	if event is InputEventMouseButton and event.is_pressed() and not self.disabled:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				handle_selected_square()
			MOUSE_BUTTON_RIGHT:
				update_flag_square()
			MOUSE_BUTTON_MIDDLE:
				for i:Square in get_tree().get_nodes_in_group("mines"):
					i.set_texture_square(MINE)

func index_to_vector_coordinates(num_columns:int,index:int) -> Vector2:
	@warning_ignore("integer_division")
	var row: int = int(index / num_columns)
	var column: int = index % num_columns
	return Vector2(row, column)

func mine_square():
	hint_score = -1
	add_to_group("mines")

func get_adjacent_elements(board_index:int, board_array:Array[Array])->Array:
	var columns_size = board_array[0].size()
	var index_position:Vector2 = index_to_vector_coordinates(columns_size,board_index)
	var columns = len(board_array)
	var rows = len(board_array[0])
	var adjacent_array = []
	for dx in range(-1 if index_position.x > 0 else 0, 2 if index_position.x < columns - 1 else 1):
		for dy in range(-1 if index_position.y > 0 else 0, 2 if index_position.y < rows - 1 else 1):
			if dx != 0 or dy != 0:
				adjacent_array.append(board_array[index_position.x + dx][index_position.y + dy])
	return adjacent_array

func add_hint():
	if is_mined():
		return
	hint_score = hint_score + 1
	if not is_in_group("hints"):
		add_to_group("hints")

func disable_square():
	self.disabled = true

func explode_mine():
	set_texture_square(MINE_RED)
