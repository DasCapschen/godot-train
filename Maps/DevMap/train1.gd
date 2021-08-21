extends Node3D


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	# move the train along
	$train.transform.origin = $back_axle.transform.origin
	$train.transform = $back_axle.transform.looking_at($front_axle.transform.origin, Vector3.UP)
