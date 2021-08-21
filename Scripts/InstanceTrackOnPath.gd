tool
extends MultiMeshInstance


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export(NodePath) var pathPath
onready var path = get_node(pathPath)

const end_prefab = preload("res://Models/Cube002.mesh")
onready var endpoint_start = get_child(0) if get_child_count() > 0 else null
onready var endpoint_end = get_child(1) if get_child_count() > 1 else null


func does_track_loop(track: Path) -> bool:
	var n_points = track.curve.get_point_count()
	var first_point = track.curve.get_point_position(0)
	var last_point = track.curve.get_point_position(n_points-1)
	if first_point.distance_to(last_point) < 0.1:
		return true
	return false

# Called when the node enters the scene tree for the first time.
func _ready():
	if Engine.editor_hint:
		self.multimesh.instance_count = int(path.curve.get_baked_length())+1
		for i in range(0, self.multimesh.instance_count):
			var offset = (float(i) / self.multimesh.instance_count) * path.curve.get_baked_length()
			var pos = path.curve.interpolate_baked(offset)
			var dir = path.curve.interpolate_baked(offset+1)
			var transform = Transform(Basis(), pos)
			transform = transform.looking_at(dir, Vector3.UP)
			self.multimesh.set_instance_transform(i, transform)
		
		if not does_track_loop(path):
			if endpoint_end == null or endpoint_start == null:
				endpoint_start = MeshInstance.new()
				endpoint_end = MeshInstance.new()
				endpoint_start.mesh = end_prefab
				endpoint_end.mesh = end_prefab
				endpoint_end.rotate(Vector3.UP, deg2rad(180))
				self.add_child(endpoint_start)
				self.add_child(endpoint_end)
				endpoint_start.set_owner(get_tree().get_edited_scene_root())
				endpoint_end.set_owner(get_tree().get_edited_scene_root())
			endpoint_start.translation = path.curve.get_point_position(0)
			endpoint_end.translation = path.curve.get_point_position(path.curve.get_point_count()-1)
			
