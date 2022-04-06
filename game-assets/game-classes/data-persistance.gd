extends Object
class_name DataPersistance

static func get_max_slots():
	return 16

static func get_slot_path(val : int):
	return "user://slot%d.dat" % val

static func load_game():
	var data = File.new()
	var to_return = []
	for i in get_max_slots():
		if !data.file_exists(get_slot_path(i)): 
			to_return.append(null)
			continue
		data.open(get_slot_path(i), File.READ)
		var line = data.get_line()
		print(line)
		if line:
			to_return.append(parse_json(line.to_ascii().get_string_from_ascii()))
	data.close()
	return to_return

#Can add new arguments, like bonus and etc.
static func save_game(slot : int, character:int , zone: int, emeralds: int):
	var data = File.new()
	var save_game_dict = {
		"character": character,
		"zone": zone,
		"emeralds": emeralds
	}
	var json_save_game = to_json(save_game_dict)
	var bytes_data = json_save_game.to_ascii()
	data.open(get_slot_path(slot), File.WRITE)
	data.store_line(bytes_data.get_string_from_ascii())
	data.close()
