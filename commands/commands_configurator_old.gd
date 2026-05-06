extends Control

@onready var save_button = $SaveButton
@onready var load_button = $LoadButton
@onready var save_checkbox = $SaveOnlyCustomButton
@onready var load_checkbox = $LoadOnlyCustomButton

# .tres resources (with PATH) where the commands mapping will be saved
@export var all_commands_location: String = "res://saves/all_commands.tres"
@export var custom_commands_location: String = "res://saves/custom_commands.tres"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#save_button.pressed.connect(on_saveButton_pressed)
	#load_button.pressed.connect(on_loadButton_pressed)
	pass



func save_custom_controls():
	var data = CommandsConfig.new()
	
	for action in InputMap.get_actions():
		# Skip default/editor actions
		if action.begins_with("ui_") or action.begins_with("editor_"):
			continue
		data.controls[action] = InputMap.action_get_events(action)
		
	var folder_path = custom_commands_location.left(custom_commands_location.rfind("/"))
	var dir_error = DirAccess.make_dir_recursive_absolute(folder_path)
	if dir_error != OK:
		printerr("Failed to create provided directory!")
		return
	
	var error = ResourceSaver.save(data, custom_commands_location)
	if error != OK:
		printerr("Failed to save controls!")
	else:
		print("Commands saved correctly")

func save_all_controls():
	var data = CommandsConfig.new()
	
	for action in InputMap.get_actions():
		data.controls[action] = InputMap.action_get_events(action)
	
	var folder_path = all_commands_location.left(all_commands_location.rfind("/"))
	var dir_error = DirAccess.make_dir_recursive_absolute(folder_path)
	if dir_error != OK:
		printerr("Failed to create provided directory!")
		return
		
	var error = ResourceSaver.save(data, all_commands_location)
	if error != OK:
		printerr("Failed to save controls!")   
	else:
		print("Commands saved correctly")

func load_controls():
	var file_path = ""
	if load_checkbox.button_pressed:
		file_path = custom_commands_location
		print('loading custom commands...')
	else:
		file_path = all_commands_location
		print('loading all commands...')
	
	if not ResourceLoader.exists(file_path, &"CommandsConfig"):
		printerr("No saved configuration found")   
		return
		
	var data: CommandsConfig = ResourceLoader.load(file_path, &"CommandsConfig")
	if not is_instance_valid(data):
		printerr("Invalid configuration found") 
		return

	for action in data.controls.keys():
		print(action)
		if not InputMap.has_action(action):
			print('adding new action')
			InputMap.add_action(action)
		else:
			InputMap.action_erase_events(action)
			
		for event in data.controls[action]:
			print('adding event ', event)
			InputMap.action_add_event(action, event)   
			
	print("Configuration loaded correctly") 
			
			
func on_saveButton_pressed():
	if save_checkbox.button_pressed:
		save_custom_controls()
	else:
		save_all_controls()
	
func on_loadButton_pressed():
	load_controls()
