extends Car
class_name CarPlayer

@export var is_overturned : bool = false
@export var ground_plane_vector : Vector3 = Vector3.FORWARD
@export var front_wheel_roll_influence : float = 1.0 
@export var rear_wheel_roll_influence : float = 1.0

var initial_transform: Transform3D

func _ready() -> void:
	super._ready()
	initial_transform = transform
	for wheel in steering_wheels:
		wheel.wheel_roll_influence = front_wheel_roll_influence
	for wheel in driving_wheels:
		wheel.wheel_roll_influence = rear_wheel_roll_influence

# Inputs
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("turnover"):
		print("Turn over pressed!")
		if is_overturned: 
			turnover()
	
func turnover() -> void:
	print("Car turnover")
	var rid: RID = get_rid()	
	var current_position: Vector3 = global_position
	var current_orientation: Vector3 = global_rotation.slide(ground_plane_vector)
		
	initial_transform.origin = current_position
	initial_transform.basis = Basis.from_euler(current_orientation)
	PhysicsServer3D.body_set_state(rid, PhysicsServer3D.BODY_STATE_TRANSFORM, initial_transform)
	
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	
		
func _process(delta: float) -> void:
	pass
	