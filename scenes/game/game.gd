extends BaseScene
@export var win_screen : PackedScene 
@export var lose_screen : PackedScene 
@export var transition_duration: float = 1


var following_scene : PackedScene
@onready var dialogues = $DialogueSystem

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	dialogues.hide_all()
		
	$StartingWhip.play()
	$LevelMusic.play()
	var tweenLx= get_tree().create_tween()
	var tweenRx= get_tree().create_tween()
	tweenLx.tween_property($CurtainLx, "position", $MarkerLxOpen.position, transition_duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tweenRx.tween_property($CurtainRx, "position", $MarkerRxOpen.position, transition_duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	#TRIGGER DIALOGUES AFTER CURTAIN
	tweenLx.connect("finished", on_curtain_open)
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _win():
	following_scene = win_screen
	_end_game()

func _lose():
	following_scene = lose_screen
	_end_game()

func _end_game():
	
	var tweenLx = get_tree().create_tween()
	var tweenRx = get_tree().create_tween()
	var tweenVolume = get_tree().create_tween()
	tweenLx.tween_property($CurtainLx, "position", $MarkerClosed.position, transition_duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tweenRx.tween_property($CurtainRx, "position", $MarkerClosed.position, transition_duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tweenRx.tween_callback(_end_scene)
	tweenVolume.tween_property($LevelMusic,"volume_db",-24,transition_duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func _end_scene():
	emit_signal("next_scene",following_scene)
	
	
func on_curtain_open():
	dialogues.show_all()
	dialogues.pause_tree()
