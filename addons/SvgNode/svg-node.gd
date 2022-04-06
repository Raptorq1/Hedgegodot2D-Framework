extends Node2D
class_name SpriteSVG
tool

var xml_tool = XMLParser.new()

export(StreamTexture) var svg_file: StreamTexture setget set_svg_file

func set_svg_file(val : StreamTexture):
	if val and !val.get_path().ends_with(".svg"): return
	svg_file = val
	update()

func _draw():
	if !svg_file or !svg_file.get_data():return
	var open = xml_tool.open_buffer(svg_file.get_data().data["data"])
	if open != OK: return
	
	var read = xml_tool.read()
	if read != OK: return
	
	for i in xml_tool.get_attribute_count():
		print(xml_tool.get_attribute_name())
