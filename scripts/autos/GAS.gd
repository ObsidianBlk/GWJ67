extends Node

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal volume_changed(bus_name : StringName, linear_volume : float)

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const CONFIG_SECTION : String = "AUDIO_VOLUME"
const BUS_MASTER : StringName = &"Master"
const BUS_MUSIC : StringName = &"Music"
const BUS_SFX : StringName = &"SFX"

const MAX_VOLUME_VALUE : float = 100.0

const DEFAULT_VOLUME : float = MAX_VOLUME_VALUE
const DEFAULT_MUSIC_VOLUME : float = MAX_VOLUME_VALUE * 0.2

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	Settings.loaded.connect(_on_settings_loaded)
	Settings.reset.connect(_on_settings_reset)

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _SetVolume(bus_name : StringName, value : float) -> bool:
	var busidx : int = AudioServer.get_bus_index(bus_name)
	if busidx < 0: return false
	
	AudioServer.set_bus_volume_db(busidx, linear_to_db(value / MAX_VOLUME_VALUE))
	volume_changed.emit(bus_name, value)
	return true


# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func set_volume(bus_name : StringName, value : float) -> void:
	value = max(0.0, min(MAX_VOLUME_VALUE, value))
	if _SetVolume(bus_name, value):
		Settings.set_value(CONFIG_SECTION, bus_name, value)

func get_volume(bus_name : StringName) -> float:
	var busidx : int = AudioServer.get_bus_index(bus_name)
	if busidx >= 0:
		return db_to_linear(AudioServer.get_bus_volume_db(busidx)) * MAX_VOLUME_VALUE
	return 0.0

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func _on_settings_reset() -> void:
	set_volume(BUS_MASTER, DEFAULT_VOLUME)
	set_volume(BUS_MUSIC, DEFAULT_MUSIC_VOLUME)
	set_volume(BUS_SFX, DEFAULT_VOLUME)

func _on_settings_loaded() -> void:
	_SetVolume(BUS_MASTER, Settings.get_value(CONFIG_SECTION, BUS_MASTER, DEFAULT_VOLUME))
	_SetVolume(BUS_MUSIC, Settings.get_value(CONFIG_SECTION, BUS_MUSIC, DEFAULT_MUSIC_VOLUME))
	_SetVolume(BUS_SFX, Settings.get_value(CONFIG_SECTION, BUS_SFX, DEFAULT_VOLUME))

