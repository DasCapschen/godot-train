@tool
extends MultiMeshInstance3D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

@export var pathPath: NodePath
const track_mesh: Mesh = preload("res://Models/Track/track_part.res")
const end_prefab: Mesh = preload("res://Models/Track/track_end.res")

func does_track_loop(track: Path3D) -> bool:
	var n_points: int = track.curve.get_point_count()
	var first_point: Vector3 = track.curve.get_point_position(0)
	var last_point: Vector3 = track.curve.get_point_position(n_points-1)
	if first_point.distance_to(last_point) < 0.1:
		return true
	return false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.multimesh.transform_format = MultiMesh.TRANSFORM_3D
	self.multimesh.mesh = track_mesh
	var path: Path3D = get_node(pathPath)
	var endpoint_start: MeshInstance3D = get_child(0) if get_child_count() > 0 else null
	var endpoint_end: MeshInstance3D = get_child(1) if get_child_count() > 1 else null
	if Engine.editor_hint:
		self.multimesh.instance_count = int(path.curve.get_baked_length())+1
		for i in range(0, self.multimesh.instance_count):
			var offset = (float(i) / self.multimesh.instance_count) * path.curve.get_baked_length()
			var pos = path.curve.interpolate_baked(offset)
			var dir = path.curve.interpolate_baked(offset+1)
			var new_transform = Transform(Basis(), pos)
			new_transform = new_transform.looking_at(dir, Vector3.UP)
			self.multimesh.set_instance_transform(i, new_transform)
		
		if not does_track_loop(path):
			if endpoint_end == null or endpoint_start == null:
				endpoint_start = MeshInstance3D.new()
				endpoint_end = MeshInstance3D.new()
				endpoint_start.mesh = end_prefab
				endpoint_end.mesh = end_prefab
				endpoint_end.rotate(Vector3.UP, deg2rad(180))
				self.add_child(endpoint_start)
				self.add_child(endpoint_end)
				endpoint_start.set_owner(get_tree().get_edited_scene_root())
				endpoint_end.set_owner(get_tree().get_edited_scene_root())
			endpoint_start.position = path.curve.get_point_position(0)
			endpoint_end.position = path.curve.get_point_position(path.curve.get_point_count()-1)
			
