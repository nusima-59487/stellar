extends StaticBody2D
class_name Earth

@export var hp: int = 80

var progress_bar: ProgressBar; 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	progress_bar = $"../CanvasLayer/ProgressBar"; 
	progress_bar.max_value = hp; 
	progress_bar.value = hp;
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

# on body enter detection area
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Junk: 
		hp -= body.health
		progress_bar.value = hp
		body.queue_free()
		if hp <= 0:
			queue_free() # Earth is destroyed
