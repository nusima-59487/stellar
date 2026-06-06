extends Marker2D

@export var junk_scene: PackedScene

func _ready():
	$Timer.timeout.connect(spawn_enemy)

func spawn_enemy():
	var junk = junk_scene.instantiate()

	junk.global_position = global_position

	get_parent().add_child(junk)
