#extends Control
#
#
## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#var input_map_list: Dictionary = {}
	#for action in InputMap.get_actions():
		#print('Events for action ', action)
		#input_map_list[action] = []
		#for event in InputMap.action_get_events(action):
			#print('\t', event)
			#input_map_list[action].append(event)
			#
	#ResourceSaver.save("res://mobile_commands/test_commands.tres", input_map_list)
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
