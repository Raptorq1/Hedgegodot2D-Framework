extends Node

var host = "127.0.0.1"
var port = 3000
var _server = WebSocketServer.new()

func start_server():
	_server.connect("client_connected", self, "on_Server_client_connected")
	_server.connect("client_disconnected", self, "on_Server_client_disconnected")
	_server.connect("client_close_request", self, "on_Server_client_close_request")
	_server.connect("data_received", self, "on_Server_data_received")
	var _err = _server.listen(port)
	set_process(true)

func shutdown_server():
	_server.disconnect("client_connected")
	_server.disconnect("client_disconnected")
	_server.disconnect("client_close_request")
	_server.disconnect("data_received", self, "on_Server_data_received")
	var _err = _server.stop()
	set_process(false)

func on_Server_client_close_request(id: int, code: int, reason: String):
	pass

func on_Server_client_connected(id: int, protocol: String):
	pass

func on_Server_client_disconnected(id: int, was_clean_close: bool):
	pass

func on_Server_data_received(id : int):
	var pkt = _server.get_peer(id).get_packet()

func _process(delta):
	_server.poll()
