extends Marker2D

@export var junk_scene: PackedScene
var health = 10
var number = 1

func get_split_random_int() -> int:
	# randf() returns a float between 0.0 and 1.0
	if randf() < 0.5:
		return randi_range(-2000, -1000) # 50% chance for negative range
	else:
		return randi_range(1000, 2000)  # 50% chance for positive range

func spawn_enemy(health):
	var junk = junk_scene.instantiate()
	junk.global_position = Vector2(get_split_random_int(), get_split_random_int())
	junk.dir = randf() < 0.5
	junk.health = health
	get_parent().add_child(junk)

func _ready():
	while true:
		for i in range(number):
			spawn_enemy(health)
		health += 5
		number += 1
		print("This is number ", number, "stage.")
		await get_tree().create_timer(15.0).timeout
