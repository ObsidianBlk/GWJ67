extends UIControl

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _slider_volume_master: HSlider = %Slider_VolumeMaster
@onready var _slider_volume_sfx: HSlider = %Slider_VolumeSFX
@onready var _slider_volume_music: HSlider = %Slider_VolumeMusic


# ------------------------------------------------------------------------------
# Setters / Getters
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	super._ready()
	GAS.volume_changed.connect(_on_volume_changed)
	_on_volume_changed(GAS.BUS_MASTER, GAS.get_volume(GAS.BUS_MASTER))
	_on_volume_changed(GAS.BUS_SFX, GAS.get_volume(GAS.BUS_SFX))
	_on_volume_changed(GAS.BUS_MUSIC, GAS.get_volume(GAS.BUS_MUSIC))

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_volume_changed(bus_name : StringName, value : float) -> void:
	var slider : HSlider = _slider_volume_master
	match bus_name:
		GAS.BUS_SFX:
			slider = _slider_volume_sfx
		GAS.BUS_MUSIC:
			slider = _slider_volume_music
	value = max(0.0, min(slider.max_value, value))
	slider.value = value

func _on_btn_back_pressed() -> void:
	request(UILayer.REQUEST_CLOSE_UI)

func _on_slider_volume_master_value_changed(value: float) -> void:
	GAS.set_volume(GAS.BUS_MASTER, value)

func _on_slider_volume_sfx_value_changed(value: float) -> void:
	GAS.set_volume(GAS.BUS_SFX, value)

func _on_slider_volume_music_value_changed(value: float) -> void:
	GAS.set_volume(GAS.BUS_MUSIC, value)



