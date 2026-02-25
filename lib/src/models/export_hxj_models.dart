// Top-level models
export 'dna_info_model.dart';
export 'hxj_bluetooth_device_model.dart';
export 'hxj_response_model.dart';
export 'lock_record.dart';
export 'log_type.dart';
export 'sys_param_result.dart';
export 'wifi_registration_event.dart';
export 'rf_sign_result.dart';
export 'keys/lock_key_result.dart';
export 'keys/add_lock_key_action_model.dart';
export 'keys/delete_lock_key_action_model.dart';
export 'keys/change_key_pwd_action_model.dart';
export 'keys/modify_key_action_model.dart';

// New unified models
export 'lock_response.dart';
export 'unlock_result.dart';
export 'nb_iot_info.dart';
export 'cat1_info.dart';

// Records helpers
export 'records/hx_record_factory.dart';
export 'records/lock_record_extensions.dart';
export 'records/records_models.dart';

// Gen1 record models
export 'records/gen1/hx_record1_base_model.dart';
export 'records/gen1/hx_record1_add_key_model.dart';
export 'records/gen1/hx_record1_alarm_model.dart';
export 'records/gen1/hx_record1_delete_key_model.dart';
export 'records/gen1/hx_record1_factory.dart';
export 'records/gen1/hx_record1_keyenable_model.dart';
export 'records/gen1/hx_record1_modify_key_model.dart';
export 'records/gen1/hx_record1_modify_key_time_model.dart';
export 'records/gen1/hx_record1_modify_key_value_model.dart';
export 'records/gen1/hx_record1_set_sys_pram_model.dart';
export 'records/gen1/hx_record1_unknown_model.dart';
export 'records/gen1/hx_record1_unlock_model.dart';
export 'records/gen1/hx_record1_wrong_key_unlock_model.dart';

// Gen2 record models
export 'records/gen2/hx_record2_base_model.dart';
export 'records/gen2/hx_record2_add_key_model.dart';
export 'records/gen2/hx_record2_alarm_model.dart';
export 'records/gen2/hx_record2_delete_key_model.dart';
export 'records/gen2/hx_record2_factory.dart';
export 'records/gen2/hx_record2_keyenable_model.dart';
export 'records/gen2/hx_record2_modify_key_model.dart';
export 'records/gen2/hx_record2_modify_key_time_model.dart';
export 'records/gen2/hx_record2_modify_key_value_model.dart';
export 'records/gen2/hx_record2_set_sys_pram_model.dart';
export 'records/gen2/hx_record2_unknown_model.dart';
export 'records/gen2/hx_record2_unlock_model.dart';
export 'records/gen2/hx_record2_wrong_key_unlock_model.dart';

// Shared record models
export 'records/shared/hx_record_base_model.dart';
export 'records/shared/hx_record_unknown_model.dart';
export 'records/shared/record_base_parsers.dart';
