extends Node

const USER_FILE_PATH = "user://posthog_user.json"
const APP_FILE_PATH = "res://posthog.json"

var api_key = ""
var capture_url = ""
var distinct_id = ""
## https://posthog.com/docs/data/anonymous-vs-identified-events
var anonymous_events = true:
	set = _update_anonymous_events
var enabled = true

signal error_occurred(e: Error)
signal api_response(response: Variant)

## Properties included in every event.
var auto_include_properties = {}

## Whether the platform should be included in every event.
@export var include_platform = true

func _ready() -> void:
	_load_post_hog_json()
	_load_post_hog_user_json()
	if include_platform:
		auto_include_properties["platform"] = get_os_platform()

func capture(event_name: String, properties: Dictionary = {}) -> void:
	if not enabled:
		return
	properties.merge(auto_include_properties)
	_send(event_name, properties)

func _send(event_name: String, properties: Dictionary = {}) -> void:
	var request = HTTPRequest.new()
	var headers = ["Content-Type: application/json"]
	var data = {
		"api_key": api_key,
		"distinct_id": distinct_id,
		"event": event_name,
		"properties": properties,
	}
	add_child(request)
	request.request_completed.connect(_http_request_completed)
	var error = request.request(capture_url, headers, HTTPClient.METHOD_POST, JSON.stringify(data))
	if error != OK:
		error_occurred.emit(error)

func _http_request_completed(_result, _response_code, _headers, body):
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	api_response.emit(response)

func _load_post_hog_json():
	if not FileAccess.file_exists(APP_FILE_PATH):
		print(APP_FILE_PATH, ' not found')
		print('Analytics disabled')
		enabled = false
		return
	var app_post_hog_file = FileAccess.open(APP_FILE_PATH, FileAccess.READ)
	var app_data = app_post_hog_file.get_as_text()
	app_post_hog_file.close()
	app_data = JSON.parse_string(app_data)
	api_key = app_data.api_key
	var base_url: String = app_data.base_url
	capture_url = base_url.path_join('i/v0/e/')

## Gets specfic user data for this device, or creates it.
func _load_post_hog_user_json():
	var data = {}
	if FileAccess.file_exists(USER_FILE_PATH):
		var user_post_hog_file = FileAccess.open(USER_FILE_PATH, FileAccess.READ)
		var data_content = user_post_hog_file.get_as_text()
		user_post_hog_file.close()
		data = JSON.parse_string(data_content)
	else:
		data = {
			"id": uuid()
		}
		var user_post_hog_file = FileAccess.open(USER_FILE_PATH, FileAccess.WRITE)
		user_post_hog_file.store_string(JSON.stringify(data))
		user_post_hog_file.close()
	distinct_id = data.id

## Updates the auto_include_properties for anonymous events.
func _update_anonymous_events(val: bool):
	anonymous_events = val
	auto_include_properties["$process_person_profile"] = !anonymous_events
	

## Create an 8 letter UUID.
static func uuid() -> String:
	var start = "A".to_ascii_buffer()[0]
	var letters = [];
	for i in 8:
		var j = randi() % 26
		var letter = char(start + j)
		letters.append(letter)
	return "".join(letters)

## Grabs the host OS platform.
static func get_os_platform() -> String:
	# First platform found in list is returned.
	var platforms = [
		"windows",
		"linux",
		"macos",
		"android",
		"ios",
		"web_android",
		"web_ios",
		"web_linuxbsd",
		"web_macos",
		"web_windows",
		"web",
		"pc",
		"mobile"
	]
	for platform in platforms:
		if OS.has_feature(platform):
			return platform
	return "unknown"
