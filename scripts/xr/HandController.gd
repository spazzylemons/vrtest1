class_name HandController
extends XRController3D

const DEADZONE := 0.2

# Helper class for boolean input.
class ControllerButton:
	var _last_state := false
	var _current_state := false
	var _input_name: StringName

	func _init(input_name: StringName) -> void:
		_input_name = input_name

	func update(controller: XRController3D) -> void:
		_last_state = _current_state
		# Check type of input before assigning. If XR is not enabled, it could be null.
		var new_input = controller.get_input(_input_name)
		if new_input is bool:
			_current_state = new_input

	func held() -> bool:
		return _current_state

	func pressed() -> bool:
		return _current_state and not _last_state

static func _apply_deadzone(value: float) -> float:
	return clampf(remap(abs(value), DEADZONE, 1.0, 0.0, 1.0), 0.0, 1.0) * signf(value)

var _ax := ControllerButton.new("ax_button")
var _by := ControllerButton.new("by_button")

func get_ax() -> ControllerButton:
	return _ax

func get_by() -> ControllerButton:
	return _by

func get_stick() -> Vector2:
	# Get the raw input.
	var vec := get_vector2("primary")
	# Apply the deadzone.
	vec.x = _apply_deadzone(vec.x)
	vec.y = _apply_deadzone(vec.y)
	return vec

func _process(_delta: float) -> void:
	get_ax().update(self)
	get_by().update(self)
