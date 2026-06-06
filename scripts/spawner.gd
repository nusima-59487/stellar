extends Marker2D

@export var junk_scene: PackedScene
var timer: Timer

func _ready():
	timer = $"../Timer"
	timer.timeout.connect(spawn_enemy)

func spawn_enemy():
	var junk = junk_scene.instantiate()
	junk.global_position = global_position
	junk.dir = randf() < 0.5
	get_parent().add_child(junk)
