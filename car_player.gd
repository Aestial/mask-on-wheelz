extends Car
class_name CarPlayer

@export var is_overturned : bool = false
@export var plane_vector : Vector3 = Vector3.DOWN

var initial_transform: Transform3D

func _ready() -> void:
	super._ready()
	initial_transform = transform	

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
	var current_orientation: Vector3 = global_rotation.slide(plane_vector)
	
	initial_transform.origin = current_position
	initial_transform.basis = Basis.from_euler(current_orientation)
	PhysicsServer3D.body_set_state(rid, PhysicsServer3D.BODY_STATE_TRANSFORM, initial_transform)
	
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	
		
func _process(delta: float) -> void:
	pass
	