extends Camera


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("forward"):
		self.translate(Vector3(0, 0, -1) * delta * 10)
	if Input.is_action_pressed("backward"):
		self.translate(Vector3(0, 0, 1) * delta * 10)
	if Input.is_action_pressed("left"):
		self.translate(Vector3(-1, 0, 0) * delta * 10)
	if Input.is_action_pressed("right"):
		self.translate(Vector3(1, 0, 0) * delta * 10)
	
	
var pitch = 0.0
const max_pitch = deg2rad(89.0)
const min_pitch = -deg2rad(89.0)

func _input(event):
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit()
	if event is InputEventMouseMotion:
		var amount = -deg2rad(event.relative.x) * 0.1
		rotate(Vector3.UP, amount)
		
		amount = -deg2rad(event.relative.y) * 0.1
		pitch = clamp(pitch + amount, min_pitch, max_pitch)
		rotation.x = pitch
