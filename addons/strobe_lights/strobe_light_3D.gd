@tool
class_name StrobeLight3D
extends Light3D

## The light will only strobe if set to on
@export var strobe: bool = false: 
	set(new_value):
		if new_value != strobe:
			if strobe:
				visible = true
			strobe = new_value

## Frequency of the strobe, in Hz
@export_range(1.0, 30.0, 1.0, "suffix:Hz") var frequency: float = 10.0

@export_range(0.0, 1.0) var duty_cycle: float = 0.5

var time_turned_on: float = 0
var time_turned_off: float = 0

var previous_energy: float


func _process(delta: float) -> void:
	if strobe:
		if visible:
			time_turned_on += delta
			if time_turned_on > ((1.0 / frequency) * duty_cycle):
				visible = false
				time_turned_off += time_turned_on - ((1.0 / frequency) * duty_cycle)
				time_turned_on = 0
		else:
			time_turned_off += delta
			if time_turned_off > ((1.0 / frequency) * (1 - duty_cycle)):
				visible = true
				time_turned_on += time_turned_off - ((1.0 / frequency) * (1 - duty_cycle))
				time_turned_off = 0
