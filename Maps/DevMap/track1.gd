extends Path3D


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

const offset: Vector3 = Vector3(0, 0, -8)
const epsilon: float = 0.05

# kind of a newton-algorithm... oh god, it's iterative :(
# this is ugly af
func get_closest_on_curve():
	var front_transform = $train1_frontAxle.transform
	var back_pos = front_transform.translated(offset).origin
	
	back_pos = self.curve.get_closest_point(back_pos)
	while abs((front_transform.origin.distance_to(back_pos) - offset.length())) > epsilon:
		var dir = front_transform.origin.direction_to(back_pos) * offset.length()
		back_pos = front_transform.origin + dir
		back_pos = self.curve.get_closest_point(back_pos)
		pass
	return self.curve.get_closest_offset(back_pos)

# Called when the node enters the scene tree for the first time.
func _physics_process(delta: float) -> void:
	$train_simple.offset += delta * 15
	
	#$train1_frontAxle.offset += delta * 15
	#$train1_backAxle.offset = get_closest_on_curve()
	
	# this works just as well!!!
	#$train2_frontAxle.offset += delta * 5
	#var front_pos = $train2_frontAxle.global_transform.origin
	#var back_pos = $train2_backAxle.global_transform.origin
	#var dist = back_pos.distance_to(front_pos) - offset.length()
	#$train2_backAxle.offset += dist
	pass
	
