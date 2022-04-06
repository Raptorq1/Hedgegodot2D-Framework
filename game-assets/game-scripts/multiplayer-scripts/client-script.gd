extends Node

var _client = WebSocketClient.new()

func start_client():
	_client.connect("connection_established", self, "on_Client_connection_established")
	_client.connect("connection_error", self, "on_Client_connection_error")
	_client.connect("connection_closed", self, "on_Client_connection_closed")
	_client.connect("data_received", self, "on_Client_data_received")
	set_process(true)

func close_client():
	_client.connect("connection_established", self, "on_Client_connection_established")
	_client.connect("connection_error", self, "on_Client_connection_error")
	_client.connect("connection_closed", self, "on_Client_connection_closed")
	_client.connect("data_received", self, "on_Client_data_received")
	set_process(false)

func connect_url(url:String) -> int:
	return _client.connect_to_url(url)

func on_Client_connection_established(_protocol: String):
	_client.get_peer(1).put_packet("HelloServer!".to_utf8())
func on_Client_connection_error():
	pass
func on_Client_connection_closed(_was_clean_close:bool):
	pass

func on_Client_data_received():
	pass

func _process(_delta):
	_client.poll()
