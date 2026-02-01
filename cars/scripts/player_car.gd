extends CarBase
class_name PlayerCar

@export_category("Player Input")
@export var input_steering_sensitivity : float = 1.0
@export var input_acceleration_sensitivity : float = 1.0

func calculate_desired_input(delta: float):
	# Player input is handled in get_desired_input directly
	pass
	
func get_desired_input() -> Vector2:
	var input_vector: Vector2 = Vector2.ZERO	
	# Get raw input 
	input_vector.x = Input.get_axis("right", "left") * input_steering_sensitivity
	input_vector.y = Input.get_axis("down", "up") * input_acceleration_sensitivity
	return input_vector
	
# Add player-specific methods

func boost_power(amount: float, duration: float):
	pass
	