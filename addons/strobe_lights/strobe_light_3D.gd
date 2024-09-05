@tool

## Gives the ability to any [class Light3D] (Such as [class SpotLight3D] or [class OmniLight3D]) to strobe at a specific frequency. 
class_name StrobeLight3D
extends Light3D

## The different properties that can be used to strobe the light.
enum StrobableProperties {
	ENERGY = 1,
	COLOR = 2,
	## [u]Only available[/u] if using physical light units
	INTENSITY = 4,
}

## When set, the light will strobe using the selected [member property_to_strobe] at the set [member frequency]
@export var active: bool = false:
	set(new_value):
		if new_value != active:
			if new_value == false:
				if property_to_strobe & StrobableProperties.ENERGY:
					light_energy = strobe_energy_on
				if property_to_strobe & StrobableProperties.COLOR:
					light_color = strobe_color_on
				if property_to_strobe & StrobableProperties.INTENSITY:
					light_intensity_lumens = strobe_intensity_on
					light_intensity_lux = strobe_intensity_on
			
			if new_value == true:
				if property_to_strobe & StrobableProperties.ENERGY:
					light_energy = strobe_energy_off
				if property_to_strobe & StrobableProperties.COLOR:
					light_color = strobe_color_off
				if property_to_strobe & StrobableProperties.INTENSITY:
					light_intensity_lumens = strobe_intensity_off
					light_intensity_lux = strobe_intensity_off
				
				_time_turned_off = 0
				_time_turned_on = 0
				_state = false
		
		active = new_value

## How many times per second the light will complete a full ON/OFF cycle.[br]
## The frequency is only accurate up to half of the effective refresh rate, as one full cycle requires at least two frames (one frame OFF and one frame ON)
@export_custom(PROPERTY_HINT_NONE, "suffix:Hz") var frequency:  = 10.0:
	set(new_value):
		if new_value < 0.0:
			new_value = 0.01
		frequency = new_value
		update_configuration_warnings()

## Percentage of time the light is [b]ON[/b] during each cycle.[br]
## A 0.25 duty cycle means the light is ON for 25% of the time and OFF for 75%.
@export_range(0.0, 1.0) var duty_cycle: float = 0.5

## The specific properties that will be modified to achieve the strobing effect.
@export_flags("Energy:1", "Color:2", "Intensity:4") var property_to_strobe: int = StrobableProperties.ENERGY:
	set(new_value):
		if not active:
			property_to_strobe = new_value
			update_configuration_warnings()

@export_group("Energy", "strobe_energy_")
@export_range(0, 16) var strobe_energy_on: float = 1
@export_range(0, 16) var strobe_energy_off: float = 0

@export_group("Color", "strobe_color_")
@export var strobe_color_on: Color = Color.WHITE
@export var strobe_color_off: Color = Color.BLACK

@export_group("Intensity", "strobe_intensity_")
@export_range(0, 100000) var strobe_intensity_on: float = 1000
@export_range(0, 100000) var strobe_intensity_off: float = 0

var _time_turned_on: float = 0.0
var _time_turned_off: float = 0.0

var _state: bool = true


func _process(delta: float) -> void:
	if active:
		if _state:
			_time_turned_on += delta
			if _time_turned_on > ((1.0 / frequency) * duty_cycle):
				if property_to_strobe & StrobableProperties.ENERGY:
					light_energy = strobe_energy_off
				if property_to_strobe & StrobableProperties.COLOR:
					light_color = strobe_color_off
				if property_to_strobe & StrobableProperties.INTENSITY:
					light_intensity_lumens = strobe_intensity_off
					light_intensity_lux = strobe_intensity_off
				
				_time_turned_off += _time_turned_on - ((1.0 / frequency) * duty_cycle)
				# Prevents endless built-up of excess time if frequency is set higher than effective refresh rate 
				_time_turned_off = min(_time_turned_off, ((1.0 / frequency) * (1 - duty_cycle)))
				_time_turned_on = 0
				_state = false
		else:
			_time_turned_off += delta
			if _time_turned_off > ((1.0 / frequency) * (1 - duty_cycle)):
				if property_to_strobe & StrobableProperties.ENERGY:
					light_energy = strobe_energy_on
				if property_to_strobe & StrobableProperties.COLOR:
					light_color = strobe_color_on
				if property_to_strobe & StrobableProperties.INTENSITY:
					light_intensity_lumens = strobe_intensity_on
					light_intensity_lux = strobe_intensity_on
				
				_time_turned_on += _time_turned_off - ((1.0 / frequency) * (1 - duty_cycle))
				# Prevents endless built-up of excess time if frequency is set higher than effective refresh rate 
				_time_turned_on = min(_time_turned_on, ((1.0 / frequency) * duty_cycle))
				_time_turned_off = 0
				_state = true


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if property_to_strobe & StrobableProperties.INTENSITY and not ProjectSettings.get_setting("rendering/lights_and_shadows/use_physical_light_units"):
		warnings.append("Strobing the intensity is only available when using physical light units")
	return warnings


func _notification(what: int) -> void:
	pass
