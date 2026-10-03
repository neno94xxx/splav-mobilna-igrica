extends Node

## AdMob interstitial controller for Android.
## Development builds use Google's public demo ad unit, while every build uses
## Raft Escape's real application ID so AdMob can deliver the published UMP
## privacy message.

signal privacy_options_availability_changed(available: bool)

const ADMOB_SCRIPT := preload("res://addons/AdmobPlugin/Admob.gd")
const ANDROID_APPLICATION_ID := "ca-app-pub-9831528888354313~9648142267"
const ANDROID_REAL_INTERSTITIAL_ID := "ca-app-pub-9831528888354313/4475706633"
const AD_FREQUENCY_SAVE_PATH := "user://ad_frequency.cfg"
const MIN_RIDES_BETWEEN_ADS := 2
const MAX_RIDES_BETWEEN_ADS := 10
const VARIABLE_FREQUENCY_UPGRADE_COUNT := 7
const FAST_FREQUENCY_UPGRADE_COUNT := 12

var _admob: Node
var _initialized := false
var _interstitial_loading := false
var _interstitial_ready := false
var _interstitial_showing := false
var _ad_due := false
var _rides_since_ad := 0
var _rides_until_ad := MAX_RIDES_BETWEEN_ADS
var _current_upgrade_count := 0
var _schedule_key := -1
var _initialization_requested := false
var _startup_consent_flow := false
var _consent_update_pending := false
var _consent_form_load_pending := false
var _consent_form_showing := false
var _privacy_options_requested := false
var _privacy_options_available := false


func _ready() -> void:
	# The plugin is Android-only. Keeping desktop runs inert makes normal Godot
	# previews and smoke tests behave exactly as they did before AdMob.
	if not OS.has_feature("android"):
		return

	_load_frequency_state()
	_admob = ADMOB_SCRIPT.new()
	_admob.name = "Admob"
	_admob.is_real = OS.has_feature("release")
	_admob.android_debug_application_id = ANDROID_APPLICATION_ID
	_admob.android_real_application_id = ANDROID_APPLICATION_ID
	_admob.android_real_interstitial_id = ANDROID_REAL_INTERSTITIAL_ID
	_admob.max_interstitial_ad_cache = 1
	_admob.remove_interstitial_ads_after_displayed = true
	_admob.initialization_completed.connect(_on_admob_initialized)
	_admob.interstitial_ad_loaded.connect(_on_interstitial_loaded)
	_admob.interstitial_ad_failed_to_load.connect(_on_interstitial_failed_to_load)
	_admob.interstitial_ad_showed_full_screen_content.connect(_on_interstitial_showed)
	_admob.interstitial_ad_failed_to_show_full_screen_content.connect(_on_interstitial_failed_to_show)
	_admob.interstitial_ad_dismissed_full_screen_content.connect(_on_interstitial_dismissed)
	_admob.consent_info_updated.connect(_on_consent_info_updated)
	_admob.consent_info_update_failed.connect(_on_consent_info_update_failed)
	_admob.consent_form_loaded.connect(_on_consent_form_loaded)
	_admob.consent_form_failed_to_load.connect(_on_consent_form_failed_to_load)
	_admob.consent_form_dismissed.connect(_on_consent_form_dismissed)
	add_child(_admob)
	# Google requires a fresh consent-information update on every app launch.
	# Mobile Ads is initialized only after this flow says ads may be requested.
	call_deferred("_start_consent_flow")


func _start_consent_flow() -> void:
	if _admob == null or _consent_update_pending:
		return
	_startup_consent_flow = true
	_consent_update_pending = true
	_admob.update_consent_info()


func _on_consent_info_updated() -> void:
	_consent_update_pending = false
	var status := _get_consent_status()
	_update_privacy_options_availability(status)
	if status == UserConsent.Status.REQUIRED:
		_show_or_load_consent_form()
	else:
		_startup_consent_flow = false
		_initialize_ads_if_allowed(status)


func _on_consent_info_update_failed(error_data) -> void:
	_consent_update_pending = false
	_startup_consent_flow = false
	var status := _get_consent_status()
	_update_privacy_options_availability(status)
	_initialize_ads_if_allowed(status)
	var message := _form_error_message(error_data)
	if not message.is_empty():
		push_warning("AdMob consent update failed: %s" % message)


func _show_or_load_consent_form() -> void:
	if _admob == null or _consent_form_showing or _consent_form_load_pending:
		return
	if _admob.is_consent_form_available():
		_consent_form_showing = true
		_admob.show_consent_form()
	else:
		_consent_form_load_pending = true
		_admob.load_consent_form()


func _on_consent_form_loaded() -> void:
	_consent_form_load_pending = false
	if not _startup_consent_flow and not _privacy_options_requested:
		return
	_consent_form_showing = true
	_admob.show_consent_form()


func _on_consent_form_failed_to_load(error_data) -> void:
	_consent_form_load_pending = false
	var was_startup_flow := _startup_consent_flow
	_startup_consent_flow = false
	_privacy_options_requested = false
	var status := _get_consent_status()
	_update_privacy_options_availability(status)
	if was_startup_flow:
		_initialize_ads_if_allowed(status)
	var message := _form_error_message(error_data)
	if not message.is_empty():
		push_warning("AdMob consent form failed to load: %s" % message)


func _on_consent_form_dismissed(error_data) -> void:
	var was_privacy_options := _privacy_options_requested
	_consent_form_showing = false
	_consent_form_load_pending = false
	_startup_consent_flow = false
	_privacy_options_requested = false
	var status := _get_consent_status()
	_update_privacy_options_availability(status)
	_initialize_ads_if_allowed(status)
	if was_privacy_options and _initialized:
		_reload_interstitial_after_privacy_change()
	var message := _form_error_message(error_data)
	if not message.is_empty():
		push_warning("AdMob consent form dismissed with an error: %s" % message)


func _get_consent_status() -> int:
	if _admob == null:
		return UserConsent.Status.UNKNOWN
	var consent = _admob.get_consent_status()
	if consent == null:
		return UserConsent.Status.UNKNOWN
	return consent.status


func _initialize_ads_if_allowed(status: int) -> void:
	if _initialization_requested or _admob == null:
		return
	if status != UserConsent.Status.NOT_REQUIRED and status != UserConsent.Status.OBTAINED:
		return
	_initialization_requested = true
	_admob.initialize()


func _update_privacy_options_availability(status: int) -> void:
	# This plugin version does not expose UMP's separate requirement-status API.
	# REQUIRED/OBTAINED identifies users who received the European privacy flow;
	# keeping the entry point visible lets them revisit that choice at any time.
	var available := status == UserConsent.Status.REQUIRED or status == UserConsent.Status.OBTAINED
	if available == _privacy_options_available:
		return
	_privacy_options_available = available
	privacy_options_availability_changed.emit(available)


func is_privacy_options_available() -> bool:
	return (
		OS.has_feature("android")
		and _privacy_options_available
		and not _consent_update_pending
		and not _consent_form_load_pending
		and not _consent_form_showing
	)


func request_privacy_options() -> void:
	if not is_privacy_options_available() or _admob == null:
		return
	_privacy_options_requested = true
	_show_or_load_consent_form()


func _reload_interstitial_after_privacy_change() -> void:
	if _interstitial_showing:
		return
	if _interstitial_ready:
		_admob.remove_interstitial_ad()
	_interstitial_ready = false
	_interstitial_loading = false
	_load_interstitial()


func _form_error_message(error_data) -> String:
	if error_data == null or not error_data.has_method("get_message"):
		return ""
	return str(error_data.get_message())


func on_ride_finished(total_upgrade_count: int) -> void:
	if not OS.has_feature("android"):
		return

	_current_upgrade_count = maxi(total_upgrade_count, 0)
	_update_frequency_schedule(_current_upgrade_count)
	_rides_since_ad += 1
	_ad_due = _rides_since_ad >= _rides_until_ad
	_save_frequency_state()
	if _ad_due:
		_try_show_interstitial()
		if not _interstitial_ready and not _interstitial_loading:
			_load_interstitial()


func _on_admob_initialized(_status_data) -> void:
	_initialized = true
	_load_interstitial()


func _load_interstitial() -> void:
	if not _initialized or _interstitial_loading or _interstitial_ready or _interstitial_showing:
		return
	_interstitial_loading = true
	_admob.load_interstitial_ad()


func _on_interstitial_loaded(_ad_info, _response_info) -> void:
	_interstitial_loading = false
	_interstitial_ready = true


func _on_interstitial_failed_to_load(_ad_info, _error_data) -> void:
	_interstitial_loading = false
	_interstitial_ready = false


func _try_show_interstitial() -> void:
	if not _ad_due or not _interstitial_ready or _interstitial_showing:
		return
	_interstitial_ready = false
	_interstitial_showing = true
	_admob.show_interstitial_ad()


func _on_interstitial_showed(_ad_info) -> void:
	# Count a new interval only after Android confirms that the ad was shown.
	_ad_due = false
	_rides_since_ad = 0
	_rides_until_ad = _choose_ride_interval(_current_upgrade_count)
	_save_frequency_state()


func _on_interstitial_failed_to_show(ad_info, _error_data) -> void:
	_interstitial_showing = false
	_interstitial_ready = false
	if ad_info != null and ad_info.has_method("get_ad_id"):
		_admob.remove_interstitial_ad(ad_info.get_ad_id())
	_load_interstitial()


func _on_interstitial_dismissed(_ad_info) -> void:
	_interstitial_showing = false
	_load_interstitial()


func _load_frequency_state() -> void:
	var config := ConfigFile.new()
	if config.load(AD_FREQUENCY_SAVE_PATH) == OK:
		_rides_since_ad = maxi(int(config.get_value("frequency", "rides_since_ad", 0)), 0)
		_rides_until_ad = clampi(
			int(config.get_value("frequency", "rides_until_ad", MAX_RIDES_BETWEEN_ADS)),
			MIN_RIDES_BETWEEN_ADS,
			MAX_RIDES_BETWEEN_ADS
		)
		_schedule_key = int(config.get_value("frequency", "schedule_key", -1))
	else:
		_rides_until_ad = MAX_RIDES_BETWEEN_ADS
		_schedule_key = -1
	_ad_due = _rides_since_ad >= _rides_until_ad


func _save_frequency_state() -> void:
	var config := ConfigFile.new()
	config.set_value("frequency", "rides_since_ad", _rides_since_ad)
	config.set_value("frequency", "rides_until_ad", _rides_until_ad)
	config.set_value("frequency", "schedule_key", _schedule_key)
	config.save(AD_FREQUENCY_SAVE_PATH)


func reset_frequency() -> void:
	_rides_since_ad = 0
	_rides_until_ad = MAX_RIDES_BETWEEN_ADS
	_current_upgrade_count = 0
	_schedule_key = 0
	_ad_due = false
	if OS.has_feature("android"):
		_save_frequency_state()


func ride_interval_range_for_upgrade_count(total_upgrade_count: int) -> Vector2i:
	var upgrade_count := maxi(total_upgrade_count, 0)
	if upgrade_count >= FAST_FREQUENCY_UPGRADE_COUNT:
		return Vector2i(2, 3)
	if upgrade_count >= VARIABLE_FREQUENCY_UPGRADE_COUNT:
		return Vector2i(3, 4)
	var fixed_interval := MAX_RIDES_BETWEEN_ADS - upgrade_count
	return Vector2i(fixed_interval, fixed_interval)


func _schedule_key_for_upgrade_count(total_upgrade_count: int) -> int:
	var upgrade_count := maxi(total_upgrade_count, 0)
	if upgrade_count >= FAST_FREQUENCY_UPGRADE_COUNT:
		return FAST_FREQUENCY_UPGRADE_COUNT
	if upgrade_count >= VARIABLE_FREQUENCY_UPGRADE_COUNT:
		return VARIABLE_FREQUENCY_UPGRADE_COUNT
	return upgrade_count


func _choose_ride_interval(total_upgrade_count: int) -> int:
	var interval_range := ride_interval_range_for_upgrade_count(total_upgrade_count)
	return randi_range(interval_range.x, interval_range.y)


func _update_frequency_schedule(total_upgrade_count: int) -> void:
	var new_schedule_key := _schedule_key_for_upgrade_count(total_upgrade_count)
	if new_schedule_key == _schedule_key:
		return
	_schedule_key = new_schedule_key
	_rides_until_ad = _choose_ride_interval(total_upgrade_count)
	_ad_due = _rides_since_ad >= _rides_until_ad
