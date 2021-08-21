extends Spatial

# TODO: do this programatically
export(NodePath) var front_track_path
export(NodePath) var back_track_path
export(float) var track_offset

export(bool) var has_const_speed = false
export(float) var const_speed = 10
export(float) var acceleration = 1
export(float) var deceleration = -2
export(float) var max_speed = 30

onready var front_axle_follower = $front_axle_follow
onready var back_axle_follower = $back_axle_follow
onready var sensor = $front_sensor

const offset = Vector3(0, 0, -8) # TODO: find this automagically?
var front_loops = false
var back_loops = false
var front_track_len
var back_track_len
export var speed = 0


func does_track_loop(track: Path) -> bool:
	var n_points = track.curve.get_point_count()
	var first_point = track.curve.get_point_position(0)
	var last_point = track.curve.get_point_position(n_points-1)
	if first_point.distance_to(last_point) < 0.1:
		return true
	return false


func _ready() -> void:
	if has_const_speed:
		speed = const_speed
	
	var front_track: Path = get_node(front_track_path)
	var back_track: Path = get_node(back_track_path)
	
	front_track_len = front_track.curve.get_baked_length()
	back_track_len = back_track.curve.get_baked_length()
	
	front_loops = does_track_loop(front_track)
	back_loops = does_track_loop(back_track)
	front_axle_follower.loop = front_loops
	back_axle_follower.loop = back_loops
	
	self.remove_child(front_axle_follower)
	self.remove_child(sensor)
	front_track.add_child(front_axle_follower)
	front_track.add_child(sensor)
	#front_axle_follower.set_owner(self)  # FIXME: invalid
	
	self.remove_child(back_axle_follower)
	back_track.add_child(back_axle_follower)
	#back_axle_follower.set_owner(self)  # FIXME: invalid
	
	front_axle_follower.offset = offset.length() + track_offset
	sensor.offset = front_axle_follower.offset + 2
	back_axle_follower.offset = track_offset
	pass


func get_bremsweg() -> float:
	var t = -speed / deceleration
	return speed * t + deceleration/2 * t * t

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if not has_const_speed:
		speed = clamp(speed + acceleration * delta, 0, max_speed)
		pass

	# -2 für sicherheitsabstand :^)
	if not front_loops \
	   and acceleration > 0 \
	   and front_axle_follower.offset > (front_track_len - get_bremsweg() - 2):
		acceleration = deceleration
	
	# move the path followers
	# yes, we need to move both, because edge cases
	front_axle_follower.offset += delta * speed
	back_axle_follower.offset += delta * speed
	sensor.offset = front_axle_follower.offset + get_bremsweg() + 2
	
	# make sure distance remains fixed!
	var front_pos = front_axle_follower.global_transform.origin
	var back_pos = back_axle_follower.global_transform.origin
	var dist = back_pos.distance_to(front_pos) - offset.length()
	back_axle_follower.offset += dist
	
	# move the axel models along
	$front_axle.global_transform = front_axle_follower.global_transform
	$back_axle.global_transform = back_axle_follower.global_transform
	
	# move the train along
	$train.global_transform.origin = $back_axle.global_transform.origin
	$train.global_transform = $back_axle.global_transform.looking_at($front_axle.global_transform.origin, Vector3.UP)
