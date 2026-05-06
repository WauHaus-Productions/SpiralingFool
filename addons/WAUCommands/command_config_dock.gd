@tool
extends Control

@onready var save_button = $SaveButton
@onready var load_button = $LoadButton
@onready var save_checkbox = $SaveOnlyCustomButton
@onready var load_checkbox = $LoadOnlyCustomButton
@onready var all_settings_textbox = $AllSettingsPath
@onready var custom_settings_textbox = $CustomSettingsPath
@onready var popup_panel = $PopupPanel

var all_settings_path = ""
var custom_settings_path = ""

func _ready():
	popup_panel.hide()
	save_button.pressed.connect(_on_save_pressed)
	load_button.pressed.connect(_on_load_pressed)
	popup_panel.confirmed.connect(_on_restart_pressed)
	
	all_settings_path = all_settings_textbox.text if all_settings_textbox.text != '' else all_settings_textbox.placeholder_text
	custom_settings_path = custom_settings_textbox.text if custom_settings_textbox.text != '' else custom_settings_textbox.placeholder_text

# -------------------------
# SAVE
# -------------------------
func _on_save_pressed():
	all_settings_path = all_settings_textbox.text if all_settings_textbox.text != '' else all_settings_textbox.placeholder_text
	custom_settings_path = custom_settings_textbox.text if custom_settings_textbox.text != '' else custom_settings_textbox.placeholder_text
	
	var path = ""
	if save_checkbox.button_pressed:
		path = custom_settings_path
	else:
		path = all_settings_path
	
	var data = CommandsConfig.new()

	for prop in ProjectSettings.get_property_list():
		var prop_name: String = prop["name"]
		if not prop_name.begins_with("input/"):
			continue
			
		var action_name = prop_name.trim_prefix("input/")
		
		if save_checkbox.button_pressed:
			if action_name.begins_with("ui_") or action_name.begins_with("editor_") or action_name.begins_with("spatial_editor"):
				continue

		var action_info = ProjectSettings.get_setting(prop_name)
		# action_info is a Dictionary with "deadzone" and "events" keys
		data.controls[action_name] = action_info["events"]
		
	var folder_path = path.left(path.rfind("/"))
	var dir_error = DirAccess.make_dir_recursive_absolute(folder_path)
	if dir_error != OK:
		printerr("Failed to create provided directory!")
		return
		
	ResourceSaver.save(data, path)
	print("Saved to ", path)

# -------------------------
# LOAD
# -------------------------
func _on_load_pressed():
	all_settings_path = all_settings_textbox.text if all_settings_textbox.text != '' else all_settings_textbox.placeholder_text
	custom_settings_path = custom_settings_textbox.text if custom_settings_textbox.text != '' else custom_settings_textbox.placeholder_text
	
	var path = ""
	if load_checkbox.button_pressed:
		path = custom_settings_path
	else:
		path = all_settings_path
		
	if not ResourceLoader.exists(path):
		printerr("No config found")
		return

	var data: CommandsConfig = ResourceLoader.load(path)

	if not data:
		printerr("Invalid data")
		return

	_apply_to_project_settings(data)
	print("Loaded and applied")


func _apply_to_project_settings(data: CommandsConfig):

	for action in data.controls.keys():
		print(action)

		var events = data.controls[action]

		# Build ProjectSettings format
		var action_data = {
			"deadzone": 0.5,
			"events": events
		}

		var path = "input/%s" % action
		ProjectSettings.set_setting(path, action_data)

	# Save to project.godot
	var error = ProjectSettings.save()
	if error != OK:
		printerr("Error loading data: ", error)
		return
	else:
		print("project settings saved")
		
	# Refresh InputMap (CRUCIAL)
	InputMap.load_from_project_settings()
	popup_panel.show()
	
	print("ProjectSettings updated")
	
# -------------------------
# BUTTONS
# -------------------------
func _on_restart_pressed():
	popup_panel.hide()
	EditorInterface.restart_editor(true)
