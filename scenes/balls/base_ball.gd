extends Area2D
class_name BaseBall


@export var dmg: float
@onready var audio: AudioStreamPlayer2D = $Sounds

var boss: BossBase


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(on_boss_entered)
	body_exited.connect(on_boss_exited)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if boss != null:
		if self.overlaps_body(boss):
			boss.take_damage(dmg*delta)
			audio.play_sound("DEAL_DMG")


func on_boss_entered(body: Node2D):
	if body.is_in_group("Boss"):
		# add a cast
		print("start hitting Boss")
		self.boss = body as BossBase

	
func on_boss_exited(body: Node2D):
	if body.is_in_group("Boss"):
		# add a cast
		print("finish hitting Boss")
		self.boss = null
