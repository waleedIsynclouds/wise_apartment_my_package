package com.example.wise_apartment.utils;

import android.util.Log;
import android.os.Handler;
import android.os.Looper;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel.Result;

import com.example.hxjblinklibrary.blinkble.entity.requestaction.AddLockKeyAction;
import com.example.hxjblinklibrary.blinkble.entity.requestaction.DelLockKeyAction;
import com.example.hxjblinklibrary.blinkble.entity.reslut.AddLockKeyResult;
import com.example.hxjblinklibrary.blinkble.entity.requestaction.SyncLockKeyAction;
import com.example.hxjblinklibrary.blinkble.entity.requestaction.ChangeKeyPwdAction;
import com.example.hxjblinklibrary.blinkble.entity.requestaction.ModifyKeyAction;
import com.example.hxjblinklibrary.blinkble.entity.requestaction.EnableLockKeyAction;
import com.example.hxjblinklibrary.blinkble.entity.reslut.LockKeyResult;
import com.example.hxjblinklibrary.blinkble.profile.client.HxjBleClient;
import com.example.hxjblinklibrary.blinkble.profile.client.FunCallback;
import com.example.hxjblinklibrary.blinkble.entity.Response;
import com.example.hxjblinklibrary.blinkble.entity.reslut.HxBLEUnlockResult;
import com.example.hxjblinklibrary.blinkble.entity.reslut.DnaInfo;
import com.example.hxjblinklibrary.blinkble.entity.reslut.SysParamResult;
import com.example.hxjblinklibrary.blinkble.profile.data.common.StatusCode;
import com.example.hxjblinklibrary.blinkble.entity.requestaction.OpenLockAction;
import com.example.hxjblinklibrary.blinkble.entity.requestaction.BlinkyAction;
import com.example.hxjblinklibrary.blinkble.entity.requestaction.BleSetHotelLockSystemAction;
import com.example.hxjblinklibrary.blinkble.entity.requestaction.BleHotelLockSystemParam;
import java.util.HashMap;
import java.util.Objects;
import java.util.ArrayList;
import java.util.List;

public class BleLockManager {
    private static final String TAG = "BleLockManager";
    private final HxjBleClient bleClient;

    /**
     * Callback interface for streaming syncLockKey events.
     * Allows incremental updates to be sent to Flutter via EventChannel.
     */
    public interface SyncLockKeyStreamCallback {
        void onChunk(Map<String, Object> chunkEvent);
        void onDone(Map<String, Object> doneEvent);
        void onError(Map<String, Object> errorEvent);
    }

    /**
     * Callback interface for streaming getSysParam events.
     */
    public interface SysParamStreamCallback {
        void onData(Map<String, Object> event);
        void onDone(Map<String, Object> event);
        void onError(Map<String, Object> event);
    }

    // Helper: convert vendor Response<?> to stable Map<String,Object>
    private Map<String, Object> responseToMap(Response<?> response, Object bodyObj) {
        Map<String, Object> m = new HashMap<>();
        if (response == null) return m;
        // Use safe getters to avoid repetitive try/catch per-field
        Integer codeVal = getSafe("response.code", response::code, -1);
        m.put("code", codeVal);
        putSafe(m, "message", response::message);
        try { m.put("ackMessage", WiseStatusCode.description(codeVal)); } catch (Exception e) { Log.w(TAG, "Failed to compute ackMessage", e); m.put("ackMessage", null); }
        putSafe(m, "isSuccessful", response::isSuccessful);
        putSafe(m, "isError", response::isError);
        putSafe(m, "lockMac", response::getLockMac);

        // body conversion
        if (bodyObj != null) {
            m.put("body", bodyObj);
        } else {
            Object body;
            try { body = response.body(); } catch (Exception e) { Log.w(TAG, "Failed to read response.body", e); body = null; }

            if (body == null) {
                m.put("body", null);
            } else if (body instanceof DnaInfo) {
                m.put("body", dnaInfoToMap((DnaInfo) body));
            } else if (body instanceof SysParamResult) {
                m.put("body", sysParamToMap((SysParamResult) body));
            } else {
                try { m.put("body", body.toString()); } catch (Exception e) { Log.w(TAG, "Failed to stringify body", e); m.put("body", null); }
            }
        }

        return m;
    }

    private Map<String, Object> dnaInfoToMap(DnaInfo dna) {
        Map<String, Object> m = new HashMap<>();
        if (dna == null) return m;
        putSafe(m, "mac", dna::getMac);
        putSafe(m, "initTag", dna::getInitTag);
        putSafe(m, "deviceType", dna::getDeviceType);
        putSafe(m, "hardware", dna::getHardWareVer);
        putSafe(m, "software", dna::getSoftWareVer);
        putSafe(m, "protocolVer", dna::getProtocolVer);
        putSafe(m, "appCmdSets", dna::getAppCmdSets);
        putSafe(m, "dnaAes128Key", dna::getDnaAes128Key);
        putSafe(m, "authorizedRoot", dna::getAuthorizedRoot);
        putSafe(m, "authorizedUser", dna::getAuthorizedUser);
        putSafe(m, "authorizedTempUser", dna::getAuthorizedTempUser);
        putSafe(m, "rFModuleType", dna::getrFMoudleType);
        putSafe(m, "lockFunctionType", dna::getLockFunctionType);
        putSafe(m, "maximumVolume", dna::getMaximumVolume);
        putSafe(m, "maximumUserNum", dna::getMaximumUserNum);
        putSafe(m, "menuFeature", dna::getMenuFeature);
        putSafe(m, "fingerPrintfNum", dna::getFingerPrintfNum);
        putSafe(m, "projectID", dna::getProjectID);
        putSafe(m, "rFModuleMac", dna::getRFModuleMac);
        putSafe(m, "motorDriverMode", dna::getMotorDriverMode);
        putSafe(m, "motorSetMenuFunction", dna::getMotorSetMenuFunction);
        putSafe(m, "MoudleFunction", dna::getMoudleFunction);
        putSafe(m, "BleActiveTimes", dna::getBleActiveTimes);
        putSafe(m, "ModuleSoftwareVer", dna::getModuleSoftwareVer);
        putSafe(m, "ModuleHardwareVer", dna::getModuleHardwareVer);
        putSafe(m, "passwordNumRange", dna::getPasswordNumRange);
        putSafe(m, "OfflinePasswordVer", dna::getOfflinePasswordVer);
        putSafe(m, "supportSystemLanguage", dna::getSupportSystemLanguage);
        putSafe(m, "hotelFunctionEn", dna::getHotelFunctionEn);
        putSafe(m, "schoolOpenNormorl", dna::getSchoolOpenNormorl);
        putSafe(m, "cabinetLock", dna::getCabinetLock);
        putSafe(m, "lockSystemFunction", dna::getLockSystemFunction);
        putSafe(m, "lockNetSystemFunction", dna::getLockNetSystemFunction);
        putSafe(m, "sysLanguage", dna::getSysLanguage);
        putSafe(m, "keyAddMenuType", dna::getKeyAddMenuType);
        putSafe(m, "functionFlag", dna::getFunctionFlag);
        putSafe(m, "bleSmartCardNfcFunction", dna::getBleSmartCardNfcFunction);
        putSafe(m, "wisapartmentCardFunction", dna::getWisapartmentCardFunction);
        putSafe(m, "lockCompanyId", dna::getLockCompanyId);
        putSafe(m, "deviceDnaInfoStr", dna::getDeviceDnaInfoStr);
        return m;
    }

    private Map<String, Object> sysParamToMap(SysParamResult s) {
        // Expose all fields via reflection for richer UI/debug output
        return objectToMap(s);
    }

    // Small functional getter that can throw; allows central Exception handling and logging
    private interface Getter<T> { T get() throws Exception; }

    private <T> void putSafe(Map<String, Object> m, String key, Getter<T> getter) {
        try {
            T val = getter.get();
            m.put(key, val);
        } catch (Exception e) {
            Log.w(TAG, "Failed to read key: " + key, e);
            m.put(key, null);
        }
    }

    private <T> T getSafe(String label, Getter<T> getter, T fallback) {
        try {
            return getter.get();
        } catch (Exception e) {
            Log.w(TAG, "Failed to read: " + label, e);
            return fallback;
        }
    }

    // Safe parsers for values coming from MethodChannel maps. These
    // tolerate Integer, Double, Long, and String inputs and return a
    // fallback when parsing fails or value is null.
    private int parseInt(Object o, int fallback) {
        if (o == null) return fallback;
        try {
            if (o instanceof Number) return ((Number) o).intValue();
            String s = o.toString();
            if (s.isEmpty()) return fallback;
            if (s.contains(".")) return (int) Double.parseDouble(s);
            return Integer.parseInt(s);
        } catch (Exception e) {
            Log.w(TAG, "parseInt failed for: " + o, e);
            return fallback;
        }
    }

    private long parseLong(Object o, long fallback) {
        if (o == null) return fallback;
        try {
            if (o instanceof Number) return ((Number) o).longValue();
            String s = o.toString();
            if (s.isEmpty()) return fallback;
            if (s.contains(".")) return (long) Double.parseDouble(s);
            return Long.parseLong(s);
        } catch (Exception e) {
            Log.w(TAG, "parseLong failed for: " + o, e);
            return fallback;
        }
    }

    private String parseString(Object o, String fallback) {
        if (o == null) return fallback;
        try { return o.toString(); } catch (Exception e) { return fallback; }
    }

    // Helper to ensure MethodChannel.Result callbacks run on the main thread.
    private void postResultSuccess(final Result result, final Object value) {
        new Handler(Looper.getMainLooper()).post(new Runnable() {
            @Override
            public void run() {
                try { result.success(value); } catch (Exception e) { Log.w(TAG, "result.success threw", e); }
            }
        });
    }

    private void postResultError(final Result result, final String code, final String message, final Object details) {
        new Handler(Looper.getMainLooper()).post(new Runnable() {
            @Override
            public void run() {
                try { result.error(code, message, details); } catch (Exception e) { Log.w(TAG, "result.error threw", e); }
            }
        });
    }

    // Map numeric ACK/status codes to human-readable messages
    private String ackMessageForCode(int code) {
        switch (code) {
            case 0x01: return "Operation successful";
            case 0x02: return "Password error";
            case 0x03: return "Remote unlocking not enabled";
            case 0x04: return "Parameter error";
            case 0x05: return "Operation prohibited (add administrator first)";
            case 0x06: return "Operation not supported by lock";
            case 0x07: return "Repeat adding (already exists)";
            case 0x08: return "Index/number error";
            case 0x09: return "Reverse locking not allowed";
            case 0x0A: return "System is locked";
            case 0x0B: return "Prohibit deleting administrators";
            case 0x0E: return "Storage full";
            case 0x0F: return "Follow-up data packets available";
            case 0x10: return "Door locked, cannot open/unlock";
            case 0x11: return "Exit and add key status";
            case 0x23: return "RF module busy";
            case 0x2B: return "Electronic lock engaged (unlock not allowed)";
            case 0xE1: return "Authentication failed";
            case 0xE2: return "Device busy, try again later";
            case 0xE4: return "Incorrect encryption type";
            case 0xE5: return "Session ID incorrect";
            case 0xE6: return "Device not in pairing mode";
            case 0xE7: return "Command not allowed";
            case 0xE8: return "Please add the device first (pairing error)";
            case 0xEA: return "Already has permission (pair repeat)";
            case 0xEB: return "Insufficient permissions";
            case 0xEC: return "Invalid command version / protocol mismatch";
            case 0xFF00: return "DNA key empty";
            case 0xFF01: return "Session ID empty";
            case 0xFF02: return "AES key empty";
            case 0xFF03: return "Authentication code empty";
            case 0xFF04: return "Scan/connection timeout";
            case 0xFF05: return "Bluetooth disconnected";
            case 0xFF07: return "Decryption failed";
            default:
                return "Unknown status code: 0x" + Integer.toHexString(code).toUpperCase();
        }
    }

    public BleLockManager(HxjBleClient client) {
        this.bleClient = client;
    }

    public void openLock(Map<String, Object> args, final Result result) {
        Log.d(TAG, "openLock called with args: " + args);
        OpenLockAction action = new OpenLockAction();
        action.setBaseAuthAction(PluginUtils.createAuthAction(args));

        bleClient.openLock(action, new FunCallback<HxBLEUnlockResult>() {
            @Override
            public void onResponse(Response<HxBLEUnlockResult> response) {
                Log.d(TAG, "openLock response: " + response.code());
                if (response.isSuccessful()) {
                    Map<String, Object> details = new HashMap<>();
                    details.put("code", response.code());
                    details.put("ackMessage", ackMessageForCode(response.code()));
                    details.put("power", response.body().power); // Add power
                    details.put("unlockingDuration", response.body().unlockingDuration); // Add unlockingDuration
                    result.success(details);
                } else {
                    // Include numeric code and ackMessage in details so Dart can act on it
                    try {
                        Map<String, Object> details = new HashMap<>();
                        details.put("code", response.code());
                        details.put("ackMessage", ackMessageForCode(response.code()));
                        result.error("FAILED", "Code: " + response.code(), details);
                    } catch (Throwable t) {
                        result.error("FAILED", "Code: " + response.code(), null);
                    }
                }
                bleClient.disConnectBle(null); // Disconnect after operation as per original logic
            }

            @Override
            public void onFailure(Throwable t) {
                Log.e(TAG, "openLock failed", t);
                result.error("ERROR", t.getMessage(), null);
                bleClient.disConnectBle(null);
            }
        });
    }

    public void closeLock(Map<String, Object> args, final Result result) {
        Log.d(TAG, "closeLock called");
        BlinkyAction action = new OpenLockAction();
        action.setBaseAuthAction(PluginUtils.createAuthAction(args));

        bleClient.closeLock(action, new FunCallback<Object>() {
            @Override
            public void onResponse(Response<Object> response) {
                Log.d(TAG, "closeLock response: " + response.code());
                if (response.isSuccessful()) result.success(true);
                else {
                    try {
                        Map<String, Object> details = new HashMap<>();
                        details.put("code", response.code());
                        details.put("ackMessage", ackMessageForCode(response.code()));
                        result.error("FAILED", "Code: " + response.code(), details);
                    } catch (Throwable t) {
                        result.error("FAILED", "Code: " + response.code(), null);
                    }
                }
            }
            @Override
            public void onFailure(Throwable t) {
                Log.e(TAG, "closeLock failed", t);
                result.error("ERROR", t.getMessage(), null);
            }
        });
    }

    public void setKeyExpirationAlarmTime(Map<String, Object> args, final Result result) {
        Log.d(TAG, "setKeyExpirationAlarmTime called");
        int time = (int) args.get("time");

        BleSetHotelLockSystemAction action = new BleSetHotelLockSystemAction();
        BleHotelLockSystemParam param = new BleHotelLockSystemParam();
        param.setExpirationAlarmTime(time);
        action.setParam(param);
        action.setBaseAuthAction(PluginUtils.createAuthAction(args));

        bleClient.bleSetHotelLockSystemParam(action, new FunCallback<Object>() {
            @Override
            public void onResponse(Response<Object> response) {
                if (response.isSuccessful()) result.success(true);
                else {
                    try {
                        Map<String, Object> details = new HashMap<>();
                        details.put("code", response.code());
                        details.put("ackMessage", ackMessageForCode(response.code()));
                        result.error("FAILED", "Code: " + response.code(), details);
                    } catch (Throwable t) {
                        result.error("FAILED", "Code: " + response.code(), null);
                    }
                }
            }
            @Override
            public void onFailure(Throwable t) {
                result.error("ERROR", t.getMessage(), null);
            }
        });
    }

    public void changeLockKeyPwd(Map<String, Object> arguments, final Result result) {
        if (bleClient == null) {
            postResultError(result, "INIT_ERROR", "BLE client is null", null);
            return;
        }

        try {
            Map<String, Object> actionMap = (Map<String, Object>) arguments.get("action");
            if (actionMap == null) {
                postResultError(result, "INVALID_ARGUMENT", "Missing 'action' map", null);
                return;
            }

            ChangeKeyPwdAction action = new ChangeKeyPwdAction();
            action.setStatus(0);

            int lockKeyId = parseInt(actionMap.get("lockKeyId"), -1);
            if (lockKeyId == -1) {
                postResultError(result, "INVALID_ARGUMENT", "Invalid lockKeyId", null);
                return;
            }
            action.setLockKeyId(lockKeyId);

            String oldPassword = parseString(actionMap.get("oldPassword"), "");
            String newPassword = parseString(actionMap.get("newPassword"), "");

            if (oldPassword.isEmpty() || newPassword.isEmpty()) {
                postResultError(result, "INVALID_ARGUMENT", "Missing passwords", null);
                return;
            }

            action.setOldPassword(oldPassword);
            action.setNewPassword(newPassword);

            action.setBaseAuthAction(PluginUtils.createAuthAction(arguments));


            bleClient.changeLockKeyPwd(action, new FunCallback<Object>() {
                 @Override
                 public void onResponse(Response<Object> response) {
                     if (response.isSuccessful()) {
                        result.success(responseToMap(response, null));
                     } else {
                        // Include numeric code and ackMessage in details
                        Map<String, Object> details = new HashMap<>();
                        details.put("code", response.code());
                        details.put("ackMessage", ackMessageForCode(response.code()));
                        result.error("FAILED", "Code: " + response.code(), details);
                     }
                 }

                 @Override
                 public void onFailure(Throwable t) {
                     result.error("ERROR", t.getMessage(), null);
                 }
            });

        } catch (Exception e) {
            Log.e(TAG, "changeLockKeyPwd failed", e);
            postResultError(result, "CHANGE_KEY_PWD_ERROR", e.getMessage(), null);
        }
    }

    public void modifyLockKey(Map<String, Object> arguments, final Result result) {
        if (bleClient == null) {
            postResultError(result, "INIT_ERROR", "BLE client is null", null);
            return;
        }

        try {
            Map<String, Object> actionMap = (Map<String, Object>) arguments.get("action");
            if (actionMap == null) {
                postResultError(result, "INVALID_ARGUMENT", "Missing 'action' map", null);
                return;
            }

            ModifyKeyAction action = new ModifyKeyAction();
            
            // AuthorMode: 1 = validity period, 2 = time period
            action.setAuthorMode(parseInt(actionMap.get("authorMode"), 1));
            
            // ChangeID: key ID or user ID depending on changeMode
            int changeID = parseInt(actionMap.get("changeID"), -1);
            if (changeID == -1) {
                postResultError(result, "INVALID_ARGUMENT", "Invalid changeID", null);
                return;
            }
            action.setChangeID(changeID);
            
            // ChangeMode: 0x01 = by key ID, 0x02 = by user ID
            action.setChangeMode(parseInt(actionMap.get("changeMode"), 1));
            
            // Day times (valid when AuthMode=2)
            action.setDayEndTimes(parseInt(actionMap.get("dayEndTimes"), 1439));
            action.setDayStartTimes(parseInt(actionMap.get("dayStartTimes"), 0));
            
            // Timestamps
            action.setModifyTimestamp(parseLong(actionMap.get("modifyTimestamp"), 0L));
            action.setValidStartTime(parseLong(actionMap.get("validStartTime"), 0L));
            action.setValidEndTime(parseLong(actionMap.get("validEndTime"), 0xFFFFFFFFL));
            
            // Status and valid number
            action.setStatus(parseInt(actionMap.get("status"), 0));
            action.setVaildNumber(parseInt(actionMap.get("vaildNumber"), 0xFF));
            
            // Weeks (valid when AuthMode=2)
            action.setWeeks(parseInt(actionMap.get("weeks"), 0x7F));
            
            action.setBaseAuthAction(PluginUtils.createAuthAction(arguments));

            bleClient.modifyLockKey(action, new FunCallback<Object>() {
                @Override
                public void onResponse(Response<Object> response) {
                    if (response.isSuccessful()) {
                        result.success(responseToMap(response, null));
                    } else {
                        Map<String, Object> details = new HashMap<>();
                        details.put("code", response.code());
                        details.put("ackMessage", ackMessageForCode(response.code()));
                        result.error("FAILED", "Code: " + response.code(), details);
                    }
                }

                @Override
                public void onFailure(Throwable t) {
                    result.error("ERROR", t.getMessage(), null);
                }
            });

        } catch (Exception e) {
            Log.e(TAG, "modifyLockKey failed", e);
            postResultError(result, "MODIFY_KEY_ERROR", e.getMessage(), null);
        }
    }

    public void deleteLock(Map<String, Object> args, final Result result) {
        Log.d(TAG, "deleteLock called");
        BlinkyAction action = new BlinkyAction();
        action.setBaseAuthAction(PluginUtils.createAuthAction(args));

        bleClient.delDevice(action, new FunCallback<String>() {
            @Override
            public void onResponse(Response<String> response) {
                bleClient.disConnectBle(null);
                if (response.isSuccessful()) result.success(true);
                else {
                    try {
                        Map<String, Object> details = new HashMap<>();
                        details.put("code", response.code());
                        details.put("ackMessage", ackMessageForCode(response.code()));
                        result.error("FAILED", "Code: " + response.code(), details);
                    } catch (Throwable t) {
                        result.error("FAILED", "Code: " + response.code(), null);
                    }
                }
            }
            @Override
            public void onFailure(Throwable t) {
                bleClient.disConnectBle(null);
                result.error("ERROR", t.getMessage(), null);
            }
        });
    }

    public void getDna(Map<String, Object> args, final Result result) {
        Log.d(TAG, "getDna called");
        BlinkyAction action = new BlinkyAction();
        action.setBaseAuthAction(PluginUtils.createAuthAction(args));

        bleClient.getDna(action, new FunCallback<DnaInfo>() {
            @Override
            public void onResponse(Response<DnaInfo> response) {
                if (response.isSuccessful() && response.body() != null) {
                    // Return the full DNA info mapped via dnaInfoToMap (through responseToMap)
                    result.success(responseToMap(response, null));
                } else {
                    try {
                        Map<String, Object> details = new HashMap<>();
                        details.put("code", response.code());
                        details.put("ackMessage", ackMessageForCode(response.code()));
                        result.error("FAILED", "Code: " + response.code(), details);
                    } catch (Throwable t) {
                        result.error("FAILED", "Code: " + response.code(), null);
                    }
                }
            }
            @Override
            public void onFailure(Throwable t) {
                result.error("ERROR", t.getMessage(), null);
            }
        });
    }

    /**
     * Add device (orchestrates the sample app flow):
     * 1) addDevice -> receives DnaInfo
     * 2) build base auth action and call getSysParam
     * 3) on success call pairSuccessInd and rfModulePairing
     */
    public void addDevice(Map<String, Object> args, final Result result) {
        Log.d(TAG, "addDevice called with args: " + args);
        // Try to build the BlinkyAuthAction from `mac` (Method 2 in sample app).
        // If `mac` is not provided, fall back to PluginUtils.createAuthAction(args).
        final com.example.hxjblinklibrary.blinkble.entity.requestaction.BlinkyAuthAction auth;

        String mac = null;
        if (args != null && args.containsKey("mac")) {
            Object m = args.get("mac");
            if (m instanceof String) mac = (String) m;
        }

        if (mac != null && !mac.isEmpty()) {
            auth = new com.example.hxjblinklibrary.blinkble.entity.requestaction.BlinkyAuthAction.Builder()
                    .mac(mac)
                    .build();
        } else {
            auth = com.example.wise_apartment.utils.PluginUtils.createAuthAction(args);
        }

        int chipType = 0;
        if (args != null && args.containsKey("chipType")) {
            Object v = args.get("chipType");
            if (v instanceof Integer) chipType = (Integer) v;
            else if (v instanceof String) {
                try { chipType = Integer.parseInt((String) v); } catch (Exception ignored) {}
            }
        }

        bleClient.addDevice(auth, chipType, new FunCallback<DnaInfo>() {
            @Override
            public void onResponse(Response<DnaInfo> response) {
                Map<String, Object> finalMap = new HashMap<>();
                Map<String, Object> responses = new HashMap<>();

                // addDevice response
                Map<String, Object> addDeviceMap = responseToMap(response, null);
                responses.put("addDevice", addDeviceMap);

                if (!response.isSuccessful() || response.body() == null) {
                    finalMap.put("ok", false);
                    finalMap.put("stage", "addDevice");
                    finalMap.put("responses", responses);
                    finalMap.put("dnaInfo", null);
                    finalMap.put("sysParam", null);
                    result.success(finalMap);
                    return;
                }

                DnaInfo dna = response.body();
                Log.d(TAG, "addDevice got DnaInfo: " + dna.getMac());

                Map<String, Object> dnaMap = dnaInfoToMap(dna);
                // Debug: log key DNA fields used to build auth and pairing
                try {
                    Log.d(TAG, "dnaMap: " + dnaMap);
                } catch (Throwable ignored) {}
                try { Log.d(TAG, "dna.dnaAes128Key present: " + (dna.getDnaAes128Key() != null)); } catch (Throwable ignored) {}
                try { Log.d(TAG, "dna.protocolVer: " + dna.getProtocolVer()); } catch (Throwable ignored) {}
                try { Log.d(TAG, "dna.authorizedRoot: " + dna.getAuthorizedRoot()); } catch (Throwable ignored) {}
                try { Log.d(TAG, "dna.mac: " + dna.getMac()); } catch (Throwable ignored) {}
                try { Log.d(TAG, "dna.deviceDnaInfoStr: " + dna.getDeviceDnaInfoStr()); } catch (Throwable ignored) {}
                // overwrite addDevice body with dna map
                responses.put("addDevice", responseToMap(response, dnaMap));
                Log.d(TAG,dna.getMac() + " AddDevice success, proceeding to getSysParam");
                // Build base auth action from dna info
                com.example.hxjblinklibrary.blinkble.entity.requestaction.BlinkyAuthAction baseAuth = new com.example.hxjblinklibrary.blinkble.entity.requestaction.BlinkyAuthAction.Builder()
                        .bleProtocolVer(dna.getProtocolVer())
                        .authCode(dna.getAuthorizedRoot())
                        .dnaKey(dna.getDnaAes128Key())
                        .mac(dna.getMac())
                        .keyGroupId(900)
                        .build();

                BlinkyAction action = new BlinkyAction();
                action.setBaseAuthAction(baseAuth);

                try {
                    bleClient.getSysParam(action, new FunCallback<SysParamResult>() {
                        @Override
                        public void onResponse(Response<SysParamResult> resp) {
                            Map<String, Object> finalMap2 = new HashMap<>();

                            // Map getSysParam response once and extract body
                            Map<String, Object> sysMap = responseToMap(resp, null);
                            responses.put("getSysParam", sysMap);

                            // Follow native flow: require explicit ACK_STATUS_SUCCESS
                            if (resp.code() != StatusCode.ACK_STATUS_SUCCESS || resp.body() == null) {
                                finalMap2.put("ok", false);
                                finalMap2.put("stage", "getSysParam");
                                finalMap2.put("responses", responses);
                                finalMap2.put("dnaInfo", dnaMap);
                                finalMap2.put("sysParam", null);
                                try { finalMap2.put("message", ackMessageForCode(resp.code())); } catch (Throwable ignored) {}
                                result.success(finalMap2);
                                return;
                            }

                            // sysParam body map and capture deviceStatusObj like native sample
                            Map<String, Object> sysBody = null;
                            final SysParamResult deviceStatusObj = resp.body();
                            try {
                                sysBody = sysParamToMap(deviceStatusObj);
                                try { Log.d(TAG, "deviceStatusStr: " + deviceStatusObj.getDeviceStatusStr()); } catch (Throwable ignored) {}
                            } catch (Throwable ignored) { sysBody = null; }

                            // pairSuccessInd
                            try {
                                bleClient.pairSuccessInd(action, true, new FunCallback() {
                                    @Override
                                    public void onResponse(Response pairResp) {
                                        // always disconnect after pair attempt
                                        bleClient.disConnectBle(null);

                                        Map<String, Object> finalMap3 = new HashMap<>();
                                        Map<String, Object> responses3 = responses;

                                        Map<String, Object> pairMap = responseToMap(pairResp, null);
                                        responses3.put("pairSuccessInd", pairMap);

                                        try { Log.d(TAG, "pairSuccessInd code: " + pairResp.code() + " pairMap: " + pairMap); } catch (Throwable ignored) {}

                                        // default rfModulePairing null
                                        responses3.put("rfModulePairing", null);

                                        if (pairResp.isSuccessful()) {
                                            // attempt rfModulePairing but do not fail flow if it fails
                                            try {
                                                // Non-blocking: start rfModulePairing and mark started; do not wait for result
                                                responses3.put("rfModulePairing", null);
                                                finalMap3.put("rfModulePairingStarted", true);
                                                bleClient.rfModulePairing(action, "", new FunCallback() {
                                                    @Override
                                                    public void onResponse(Response rfResp) {
                                                        try {
                                                            Map<String, Object> rfMap = responseToMap(rfResp, null);
                                                            responses3.put("rfModulePairing", rfMap);
                                                            Log.d(TAG, "rfModulePairing response: " + rfResp.code());
                                                        } catch (Throwable ignored) {}
                                                    }

                                                    @Override
                                                    public void onFailure(Throwable throwable) {
                                                        try {
                                                            Map<String, Object> rfMap = new HashMap<>();
                                                            rfMap.put("error", throwable.getMessage());
                                                            responses3.put("rfModulePairing", rfMap);
                                                            Log.d(TAG, "rfModulePairing failure: " + throwable.getMessage());
                                                        } catch (Throwable ignored) {}
                                                    }
                                                });
                                            } catch (Exception ignored) {}

                                            finalMap3.put("ok", true);
                                            finalMap3.put("stage", "pairSuccessInd");
                                            finalMap3.put("responses", responses3);
                                            finalMap3.put("dnaInfo", dnaMap);
                                            finalMap3.put("sysParam", responseToMap(resp, null).get("body") != null ? responseToMap(resp, null).get("body") : null);
                                            result.success(finalMap3);
                                        } else {
                                            finalMap3.put("ok", false);
                                            finalMap3.put("stage", "pairSuccessInd");
                                            finalMap3.put("responses", responses3);
                                            finalMap3.put("dnaInfo", dnaMap);
                                            finalMap3.put("sysParam", responseToMap(resp, null).get("body") != null ? responseToMap(resp, null).get("body") : null);
                                            result.success(finalMap3);
                                        }
                                    }

                                    @Override
                                    public void onFailure(Throwable t) {
                                        Log.e(TAG, "pairSuccessInd failed", t);
                                        result.error("ERROR", t.getMessage(), null);
                                    }
                                });
                            } catch (Exception e) {
                                Log.e(TAG, "Exception during pairSuccessInd", e);
                                result.error("ERROR", e.getMessage(), null);
                            }
                        }

                        @Override
                        public void onFailure(Throwable t) {
                            Log.e(TAG, "getSysParam failed", t);
                            result.error("ERROR", t.getMessage(), null);
                        }
                    });
                } catch (Exception e) {
                    Log.e(TAG, "Exception during addDevice flow", e);
                    result.error("ERROR", e.getMessage(), null);
                }
            }

            @Override
            public void onFailure(Throwable t) {
                Log.e(TAG, "addDevice failed", t);
                result.error("ERROR", t.getMessage(), null);
            }
        });
    }

    /**
     * Notify device that pairing succeeded on the server side.
     * Expects `args` to contain the auth fields used by PluginUtils.createAuthAction.
     */
    public void pairSuccessInd(Map<String, Object> args, final Result result) {
        Log.d(TAG, "pairSuccessInd called with args: " + args);
        BlinkyAction hxBleAction = new BlinkyAction();
        hxBleAction.setBaseAuthAction(PluginUtils.createAuthAction(args));

        bleClient.pairSuccessInd(hxBleAction, true, new FunCallback() {
            @Override
            public void onResponse(Response response) {
                // Disconnect first to allow future scans
                bleClient.disConnectBle(null);

                Map<String, Object> out = new HashMap<>();
                Map<String, Object> respMap = responseToMap(response, null);
                out.put("ok", response.isSuccessful());
                out.put("response", respMap);

                // attempt rfModulePairing but do not treat failure as overall error
                try {
                    bleClient.rfModulePairing(hxBleAction, "", new FunCallback() {
                        @Override
                        public void onResponse(Response rfResp) {
                            try { out.put("rfModulePairing", responseToMap(rfResp, null)); } catch (Throwable ignored) {}
                        }

                        @Override
                        public void onFailure(Throwable throwable) {
                            try { Map<String,Object> rfMap = new HashMap<>(); rfMap.put("error", throwable.getMessage()); out.put("rfModulePairing", rfMap); } catch (Throwable ignored) {}
                        }
                    });
                } catch (Exception ignored) {}

                result.success(out);
            }

            @Override
            public void onFailure(Throwable t) {
                Log.e(TAG, "pairSuccessInd failed", t);
                result.error("ERROR", t.getMessage(), null);
            }
        });
    }

    /**
     * Register/configure WiFi on the lock's RF module.
     * Expects `args` to contain:
     *  - "wifi": JSON string (or Map) with configuration fields (SSID, Password, tokenId, etc.)
     *  - "dna": Map with dna fields (protocolVer, authorizedRoot, dnaAes128Key, mac)
     */
    public void registerWifi(Map<String, Object> args, final Result result) {
        Log.d(TAG, "registerWifi called with args: " + args);

        String wifiJson = null;
        if (args != null && args.containsKey("wifi")) {
            Object w = args.get("wifi");
            if (w instanceof String) {
                wifiJson = (String) w;
            }else {
                wifiJson = w != null ? w.toString() : "";
            }
        }

        if (wifiJson == null) {
            result.error("INVALID_ARGS", "Missing wifi payload (wifi) in args", null);
            return;
        }

        // Prefer building BlinkyAuthAction from a provided mac (device mac)
        com.example.hxjblinklibrary.blinkble.entity.requestaction.BlinkyAuthAction baseAuth = null;
        try {
            String macFromArgs = null;
            if (args != null) {
                Object m = args.get("mac");
                if (m instanceof String) macFromArgs = (String) m;
                else if (args.containsKey("device") && args.get("device") instanceof Map) {
                    Object dev = ((Map) args.get("device")).get("mac");
                    if (dev instanceof String) macFromArgs = (String) dev;
                }
            }

            if (macFromArgs != null && !macFromArgs.isEmpty()) {
                baseAuth = new com.example.hxjblinklibrary.blinkble.entity.requestaction.BlinkyAuthAction.Builder()
                        .mac(macFromArgs)
                        .build();
            } else if (args != null && args.containsKey("dna") && args.get("dna") instanceof Map) {
                Map dnaMap = (Map) args.get("dna");
                com.example.hxjblinklibrary.blinkble.entity.requestaction.BlinkyAuthAction.Builder b =
                        new com.example.hxjblinklibrary.blinkble.entity.requestaction.BlinkyAuthAction.Builder();

                Object v;
                v = dnaMap.get("protocolVer");
                if (v instanceof Integer) b.bleProtocolVer((Integer) v);
                else if (v instanceof String) { try { b.bleProtocolVer(Integer.parseInt((String) v)); } catch (Exception ignored) {} }

                v = dnaMap.get("authorizedRoot");
                if (v instanceof String) b.authCode((String) v);

                v = dnaMap.get("dnaAes128Key");
                if (v instanceof String) b.dnaKey((String) v);

                v = dnaMap.get("mac");
                if (v instanceof String) b.mac((String) v);

                // use default keyGroupId 900 as in addDevice flow
                b.keyGroupId(900);
                baseAuth = b.build();
            } else {
                // fallback: use PluginUtils.createAuthAction to build from top-level args
                baseAuth = PluginUtils.createAuthAction(args);
            }
        } catch (Throwable t) {
            Log.e(TAG, "Failed to build baseAuth from dna map or mac, falling back", t);
            baseAuth = PluginUtils.createAuthAction(args);
        }

        BlinkyAction action = new BlinkyAction();
        action.setBaseAuthAction(baseAuth);

//        SyncLockRecordAction syncLockRecordAction = new SyncLockRecordAction(
//                0,
//                10,
//                1
//        );
//        syncLockRecordAction.setBaseAuthAction(baseAuth);

        try {

            bleClient.rfModuleReg(action, wifiJson, new FunCallback() {
                @Override
                public void onResponse(Response rfResp) {
                    try {
                        Map<String, Object> out = responseToMap(rfResp, null);
                        postResultSuccess(result, out);
                    } catch (Throwable t) {
                        postResultError(result, "ERROR", t.getMessage(), null);
                    }
                }

                @Override
                public void onFailure(Throwable t) {
                    Log.e(TAG, "rfModuleReg failed", t);
                    postResultError(result, "ERROR", t.getMessage(), null);
                }
            });
        } catch (Throwable t) {
            Log.e(TAG, "Exception calling rfModuleReg", t);
            postResultError(result, "ERROR", t.getMessage(), null);
        }
    }

    /**
     * Convert an arbitrary SDK model object into a Map<String,Object> via
     * reflection. Similar to LockRecordManager.mapRecord but kept local to
     * this manager for reuse when mapping AddLockKeyResult and others.
     */
    private Map<String, Object> objectToMap(Object obj) {
        Map<String, Object> out = new HashMap<>();
        if (obj == null) return out;
        Class<?> clazz = obj.getClass();
        out.put("modelType", clazz.getSimpleName());

        while (clazz != null && clazz != Object.class) {
            java.lang.reflect.Field[] fields = clazz.getDeclaredFields();
            for (java.lang.reflect.Field field : fields) {
                if (java.lang.reflect.Modifier.isStatic(field.getModifiers())) continue;
                field.setAccessible(true);
                try {
                    Object value = field.get(obj);
                    if (value == null) continue;
                    if (value instanceof Number || value instanceof Boolean || value instanceof String) {
                        out.put(field.getName(), value);
                    } else {
                        out.put(field.getName(), value.toString());
                    }
                } catch (IllegalAccessException e) {
                    Log.w(TAG, "Unable to read field " + field.getName() + " from " + clazz.getSimpleName(), e);
                }
            }
            clazz = clazz.getSuperclass();
        }
        return out;
    }

    /**
     * Call the vendor SDK to add a lock key and map the AddLockKeyResult
     * back to a stable Map for Dart.
     */
    public void addLockKey(Map<String, Object> args, final Result result) {
        Log.d(TAG, "addLockKey called with args: " + args);

        try {
            AddLockKeyAction action = new AddLockKeyAction();

            action.setBaseAuthAction(PluginUtils.createAuthAction(args));

            // If caller provided an `action` map, populate the AddLockKeyAction
            // fields from it. Fail fast with INVALID_ARGS when types are wrong.
            if (args != null && args.containsKey("action") && args.get("action") instanceof Map) {
                Map actionMap = (Map) args.get("action");
                try {
                    // Use safe parsers. If a required field is missing/invalid the
                    // existing catch will return INVALID_ARGS to Dart.
                    action.setPassword(parseString(actionMap.get("password"), ""));
                    action.setStatus(parseInt(actionMap.get("status"), 0));
                    action.setLocalRemoteMode(parseInt(actionMap.get("localRemoteMode"), 0));
                    action.setAuthorMode(parseInt(actionMap.get("authorMode"), 0));
                    action.setVaildMode(parseInt(actionMap.get("vaildMode"), 0));
//                    final int keyDataType = parseInt(actionMap.get("keyDataType"), 0);
//                    action.setKeyDataType(keyDataType);
                    action.setAddedKeyType(parseInt(actionMap.get("addedKeyType"), 0));
                    action.setAddedKeyID(parseInt(actionMap.get("addedKeyId"), 0));

                    final int addedKeyGroupID = parseInt(actionMap.get("addedKeyGroupId"), 0);
                    action.setAddedKeyGroupId(addedKeyGroupID);
                    action.setModifyTimestamp(parseLong(actionMap.get("modifyTimestamp"), 0L));
                    action.setValidStartTime(parseLong(actionMap.get("validStartTime"), 0L));
                    action.setValidEndTime(parseLong(actionMap.get("validEndTime"), 0xFFFFFFFF2L));
                    action.setWeek(parseInt(actionMap.get("week"), 0));
                    action.setDayStartTimes(parseInt(actionMap.get("dayStartTimes"), 0));
                    action.setDayEndTimes(parseInt(actionMap.get("dayEndTimes"), 0));
                    action.setVaildNumber(parseInt(actionMap.get("vaildNumber"), 0));
                } catch (Exception e) {
                    Log.w(TAG, "Invalid addLockKey action map", e);
                    postResultError(result, "INVALID_ARGS", "Invalid addLockKey action: " + e.getMessage(), null);
                    return;
                }
            }

            // Log the fully built action for debugging
            try { Log.d(TAG, "addLockKey action built: " + objectToMap(action)); } catch (Throwable ignored) {}

            bleClient.addLockKey(action, new FunCallback<AddLockKeyResult>() {
                @Override
                public void onResponse(Response<AddLockKeyResult> response) {
                    if (response.isSuccessful() && response.body() != null) {
                        try {
                            Map<String, Object> bodyMap = objectToMap(response.body());
                            postResultSuccess(result, responseToMap(response, bodyMap));
                        } catch (Throwable t) {
                            postResultError(result, "ERROR", t.getMessage(), null);
                        }
                    } else {
                        try {
                            Map<String, Object> details = new HashMap<>();
                            details.put("code", response.code());
                            details.put("ackMessage", ackMessageForCode(response.code()));
                            postResultError(result, "FAILED", "Code: " + response.code(), details);
                        } catch (Throwable t) {
                            postResultError(result, "FAILED", "Code: " + response.code(), null);
                        }
                    }
                }

                @Override
                public void onFailure(Throwable t) {
                    Log.e(TAG, "addLockKey failed", t);
                    postResultError(result, "ERROR", t.getMessage(), null);
                }
            });
        } catch (Throwable t) {
            Log.e(TAG, "Exception calling addLockKey", t);
            postResultError(result, "ERROR", t.getMessage(), null);
        }
    }

    /**
     * Call the vendor SDK to delete a lock key and map the result back to Dart.
     * Supports four deletion modes:
     * 0: Delete by key number (key type + key ID)
     * 1: Delete by key type (all non-admin keys of specified type)
     * 2: Delete by content (card number or password + key type)
     * 3: Delete by user ID (all keys for specified keyGroupId)
     */
    public void deleteLockKey(Map<String, Object> args, final Result result) {
        Log.d(TAG, "deleteLockKey called with args: " + args);

        try {
            DelLockKeyAction action = new DelLockKeyAction();
            action.setBaseAuthAction(PluginUtils.createAuthAction(args));

            // Extract and validate the action map
            if (args != null && args.containsKey("action") && args.get("action") instanceof Map) {
                Map actionMap = (Map) args.get("action");
                
                try {
                    // Parse deleteMode (required)
                    int deleteMode = parseInt(actionMap.get("deleteMode"), 0);
                    action.setDeleteMode(deleteMode);

                    // Validate and set fields based on deleteMode
                    switch (deleteMode) {
                        case 0: // Delete by key number
                            if (!actionMap.containsKey("deleteKeyType")) {
                                postResultError(result, "INVALID_ARGS", "deleteKeyType is required for deleteMode 0", null);
                                return;
                            }
                            if (!actionMap.containsKey("deleteKeyId")) {
                                postResultError(result, "INVALID_ARGS", "deleteKeyId is required for deleteMode 0", null);
                                return;
                            }
                            action.setDeleteKeyType(parseInt(actionMap.get("deleteKeyType"), 0));
                            action.setDeleteKeyID(parseInt(actionMap.get("deleteKeyId"), 0));
                            break;

                        case 1: // Delete by key type
                            if (!actionMap.containsKey("deleteKeyType")) {
                                postResultError(result, "INVALID_ARGS", "deleteKeyType is required for deleteMode 1", null);
                                return;
                            }
                            action.setDeleteKeyType(parseInt(actionMap.get("deleteKeyType"), 0));
                            break;

                        case 2: // Delete by content
                            if (!actionMap.containsKey("deleteKeyType")) {
                                postResultError(result, "INVALID_ARGS", "deleteKeyType is required for deleteMode 2", null);
                                return;
                            }
                            if (!actionMap.containsKey("cardNumOrPassword")) {
                                postResultError(result, "INVALID_ARGS", "cardNumOrPassword is required for deleteMode 2", null);
                                return;
                            }
                            action.setDeleteKeyType(parseInt(actionMap.get("deleteKeyType"), 0));
                            action.setCardNumOrPsw(parseString(actionMap.get("cardNumOrPassword"), ""));
                            break;

                        case 3: // Delete by user ID
                            if (!actionMap.containsKey("deleteKeyGroupId")) {
                                postResultError(result, "INVALID_ARGS", "deleteKeyGroupId is required for deleteMode 3", null);
                                return;
                            }
                            action.setDeleteAPPUserID(parseInt(actionMap.get("deleteKeyGroupId"), 0));
                            break;

                        default:
                            postResultError(result, "INVALID_ARGS", "deleteMode must be 0, 1, 2, or 3", null);
                            return;
                    }

                } catch (Exception e) {
                    Log.w(TAG, "Invalid deleteLockKey action map", e);
                    postResultError(result, "INVALID_ARGS", "Invalid deleteLockKey action: " + e.getMessage(), null);
                    return;
                }
            } else {
                postResultError(result, "INVALID_ARGS", "action map is required", null);
                return;
            }

            // Log the fully built action for debugging
            try { Log.d(TAG, "deleteLockKey action built: " + objectToMap(action)); } catch (Throwable ignored) {}

            bleClient.delLockKey(action, new FunCallback() {
                @Override
                public void onResponse(Response response) {
                    if (response.isSuccessful() && response.body() != null) {
                        try {
                            Map<String, Object> bodyMap = objectToMap(response.body());
                            postResultSuccess(result, responseToMap(response, bodyMap));
                        } catch (Throwable t) {
                            postResultError(result, "ERROR", t.getMessage(), null);
                        }
                    } else {
                        try {
                            Map<String, Object> details = new HashMap<>();
                            details.put("code", response.code());
                            details.put("ackMessage", ackMessageForCode(response.code()));
                            postResultError(result, "FAILED", "Code: " + response.code(), details);
                        } catch (Throwable t) {
                            postResultError(result, "FAILED", "Code: " + response.code(), null);
                        }
                    }
                }

                @Override
                public void onFailure(Throwable t) {
                    Log.e(TAG, "deleteLockKey failed", t);
                    postResultError(result, "ERROR", t.getMessage(), null);
                }
            });
        } catch (Throwable t) {
            Log.e(TAG, "Exception calling deleteLockKey", t);
            postResultError(result, "ERROR", t.getMessage(), null);
        }
    }

    /**
     * Call the vendor SDK to synchronize keys on the lock and map results.
     */
    public void syncLockKey(Map<String, Object> args, final Result result) {
        Log.d(TAG, "syncLockKey called with args: " + args);
        try {
            int lastSync = 2;
            if (args != null && args.containsKey("lastSyncTimestamp")) {
                Object v = args.get("lastSyncTimestamp");
                if (v instanceof Integer) lastSync = (Integer) v;
                else if (v instanceof Number) lastSync = ((Number) v).intValue();
                else if (v instanceof String) {
                    try { lastSync = Integer.parseInt((String) v); } catch (Exception ignored) {}
                }
            }

            SyncLockKeyAction action = new SyncLockKeyAction(lastSync);
            action.setBaseAuthAction(PluginUtils.createAuthAction(args));

            bleClient.syncLockKey(action, new FunCallback<LockKeyResult>() {
                @Override
                public void onResponse(Response<LockKeyResult> response) {
                    if (response.isSuccessful()) {
                        LockKeyResult body = null;
                        try { body = response.body(); } catch (Throwable ignored) { body = null; }
                        Object bodyToMap = null;
                        if (body != null) bodyToMap = objectToMap(body);
                        postResultSuccess(result, responseToMap(response, bodyToMap));
                    } else {
                        try {
                            Map<String, Object> details = new HashMap<>();
                            details.put("code", response.code());
                            details.put("ackMessage", ackMessageForCode(response.code()));
                            postResultError(result, "FAILED", "Code: " + response.code(), details);
                        } catch (Throwable t) {
                            postResultError(result, "FAILED", "Code: " + response.code(), null);
                        }
                    }
                }

                @Override
                public void onFailure(Throwable t) {
                    Log.e(TAG, "syncLockKey failed", t);
                    postResultError(result, "ERROR", t.getMessage(), null);
                }
            });
        } catch (Throwable t) {
            Log.e(TAG, "Exception calling syncLockKey", t);
            postResultError(result, "ERROR", t.getMessage(), null);
        }
    }

    /**
     * Streaming version of syncLockKey that emits incremental updates via callback.
     * This method is designed for use with EventChannel to send partial results
     * to Flutter as they arrive from the BLE SDK.
     * 
     * Note: Each onResponse callback receives ONE key (LockKeyResult represents a single key).
     * 
     * @param args Map containing baseAuth and optional lastSyncTimestamp
     * @param callback Callback to receive chunk, done, and error events
     */
    public void syncLockKeyStream(Map<String, Object> args, final SyncLockKeyStreamCallback callback) {
        Log.d(TAG, "syncLockKeyStream called with args: " + args);
        
        // List to accumulate all keys across responses
        final List<Map<String, Object>> allKeys = new ArrayList<>();
        
        // Flag to track if stream has been closed
        final boolean[] streamClosed = new boolean[]{false};
        
        try {
            int lastSync = 2;
            if (args != null && args.containsKey("lastSyncTimestamp")) {
                Object v = args.get("lastSyncTimestamp");
                if (v instanceof Integer) lastSync = (Integer) v;
                else if (v instanceof Number) lastSync = ((Number) v).intValue();
                else if (v instanceof String) {
                    try { lastSync = Integer.parseInt((String) v); } catch (Exception ignored) {}
                }
            }

            SyncLockKeyAction action = new SyncLockKeyAction(lastSync);
            action.setBaseAuthAction(PluginUtils.createAuthAction(args));

            bleClient.syncLockKey(action, new FunCallback<LockKeyResult>() {
                @Override
                public void onResponse(Response<LockKeyResult> response) {
                    try {
                        Log.d(TAG, "onResponse called - code: " + response.code() + ", isSuccessful: " + response.isSuccessful() + ", streamClosed: " + streamClosed[0]);
                        
                        // Process any successful response (ACK_STATUS_NEXT or final success)
                        if (response.code() == StatusCode.ACK_STATUS_NEXT || response.isSuccessful()) {
                            LockKeyResult body = null;
                            try { body = response.body(); } catch (Throwable ignored) {}
                            
                            if (body != null) {
                                int keyNum = LockKeyResultMapper.getKeyNum(body);
                                boolean isMore = true;
                                try {
                                    isMore = body.isMore();
                                    Log.d(TAG, "Received key: keyNum=" + keyNum + ", isMore=" + isMore + ", totalSoFar=" + (allKeys.size() + 1));
                                } catch (Throwable t) {
                                    Log.e(TAG, "Error reading isMore flag", t);
                                }
                                
                                if (keyNum != 0) {
                                    // Convert single key to Map and add to accumulator
                                    Map<String, Object> keyMap = LockKeyResultMapper.toMap(body);
                                    allKeys.add(keyMap);
                                    
                                    // Emit chunk event with this single key
                                    Map<String, Object> chunkEvent = new HashMap<>();
                                    chunkEvent.put("type", "syncLockKeyChunk");
                                    chunkEvent.put("item", keyMap);
                                    chunkEvent.put("keyNum", keyNum);
                                    chunkEvent.put("totalSoFar", allKeys.size());
                                    chunkEvent.put("isMore", isMore);
                                    callback.onChunk(chunkEvent);
                                }
                                
                                // If isMore is false, this is the last key - close stream now
                                if (!isMore) {
                                    if (streamClosed[0]) {
                                        Log.d(TAG, "isMore=false but stream already closed");
                                        return;
                                    }
                                    streamClosed[0] = true;
                                    
                                    Log.d(TAG, "isMore=false detected - closing stream with " + allKeys.size() + " keys");
                                    
                                    // Emit done event immediately
                                    Map<String, Object> doneEvent = new HashMap<>();
                                    doneEvent.put("type", "syncLockKeyDone");
                                    doneEvent.put("items", allKeys);
                                    doneEvent.put("total", allKeys.size());
                                    callback.onDone(doneEvent);
                                    
                                    // Safely disconnect BLE
                                    try {
                                        bleClient.disConnectBle(null);
                                        Log.d(TAG, "BLE disconnected after isMore=false");
                                    } catch (Throwable disconnectError) {
                                        Log.e(TAG, "Error disconnecting BLE", disconnectError);
                                    }
                                    return;
                                }
                            }
                        }
                        // Error response (non-successful)
                        else {
                            if (streamClosed[0]) {
                                Log.d(TAG, "Stream already closed, ignoring error response");
                                return;
                            }
                            streamClosed[0] = true; // Mark stream as closed
                            
                            Log.d(TAG, "Error response - code: " + response.code());
                            
                            Map<String, Object> errorEvent = new HashMap<>();
                            errorEvent.put("type", "syncLockKeyError");
                            errorEvent.put("message", ackMessageForCode(response.code()));
                            errorEvent.put("code", response.code());
                            callback.onError(errorEvent);
                            
                            // Safely disconnect BLE after error
                            try {
                                bleClient.disConnectBle(null);
                                Log.d(TAG, "BLE disconnected after error response");
                            } catch (Throwable disconnectError) {
                                Log.e(TAG, "Error disconnecting BLE after error response", disconnectError);
                            }
                        }
                    } catch (Throwable t) {
                        Log.e(TAG, "Exception in syncLockKeyStream onResponse", t);
                        
                        if (!streamClosed[0]) { // Only emit error if stream not already closed
                            streamClosed[0] = true; // Mark stream as closed
                            
                            Map<String, Object> errorEvent = new HashMap<>();
                            errorEvent.put("type", "syncLockKeyError");
                            errorEvent.put("message", "Internal error: " + t.getMessage());
                            errorEvent.put("code", -1);
                            callback.onError(errorEvent);
                            
                            // Safely disconnect BLE after exception
                            try {
                                bleClient.disConnectBle(null);
                                Log.d(TAG, "BLE disconnected after exception");
                            } catch (Throwable disconnectError) {
                                Log.e(TAG, "Error disconnecting BLE after exception", disconnectError);
                            }
                        } else {
                            Log.d(TAG, "Exception occurred but stream already closed, not emitting error");
                        }
                    }
                }

                @Override
                public void onFailure(Throwable t) {
                    if (streamClosed[0]) { // Don't emit if already closed
                        Log.d(TAG, "Ignoring failure - stream already closed");
                        return;
                    }
                    streamClosed[0] = true; // Mark stream as closed
                    
                    Log.e(TAG, "syncLockKeyStream failed", t);
                    Map<String, Object> errorEvent = new HashMap<>();
                    errorEvent.put("type", "syncLockKeyError");
                    errorEvent.put("message", t.getMessage() != null ? t.getMessage() : "Unknown error");
                    errorEvent.put("code", -1);
                    callback.onError(errorEvent);
                    
                    // Safely disconnect BLE after failure
                    try {
                        bleClient.disConnectBle(null);
                        Log.d(TAG, "BLE disconnected after failure");
                    } catch (Throwable disconnectError) {
                        Log.e(TAG, "Error disconnecting BLE after failure", disconnectError);
                    }
                }
            });
        } catch (Throwable t) {
            Log.e(TAG, "Exception calling syncLockKeyStream", t);
            Map<String, Object> errorEvent = new HashMap<>();
            errorEvent.put("type", "syncLockKeyError");
            errorEvent.put("message", "Failed to start sync: " + (t.getMessage() != null ? t.getMessage() : "Unknown error"));
            errorEvent.put("code", -1);
            callback.onError(errorEvent);
        }
    }

    /**
     * Sync the lock's internal clock/time.
     * Expects `args` to contain auth fields used by PluginUtils.createAuthAction.
     */
    public void syncLockTime(Map<String, Object> args, final Result result) {
        Log.d(TAG, "syncLockTime called with args: " + args);
        try {
            BlinkyAction action = new BlinkyAction();
            action.setBaseAuthAction(PluginUtils.createAuthAction(args));

            bleClient.syncLockTime(action, new FunCallback<Object>() {
                @Override
                public void onResponse(Response<Object> response) {
                    if (response.isSuccessful()) {
                        postResultSuccess(result, true);
                    } else {
                        try {
                            Map<String, Object> details = new HashMap<>();
                            details.put("code", response.code());
                            details.put("ackMessage", ackMessageForCode(response.code()));
                            postResultError(result, "FAILED", "Code: " + response.code(), details);
                        } catch (Throwable t) {
                            postResultError(result, "FAILED", "Code: " + response.code(), null);
                        }
                    }
                }

                @Override
                public void onFailure(Throwable t) {
                    Log.e(TAG, "syncLockTime failed", t);
                    postResultError(result, "ERROR", t.getMessage(), null);
                }
            });
        } catch (Throwable t) {
            Log.e(TAG, "Exception calling syncLockTime", t);
            postResultError(result, "ERROR", t.getMessage(), null);
        }
    }

    /**
     * Retrieve system parameters (SysParamResult) from the lock.
     */
    public void getSysParam(Map<String, Object> args, final Result result) {
        Log.d(TAG, "getSysParam called with args: " + args);
        try {
            BlinkyAction action = new BlinkyAction();
            action.setBaseAuthAction(PluginUtils.createAuthAction(args));

            bleClient.getSysParam(action, new FunCallback<SysParamResult>() {
                @Override
                public void onResponse(Response<SysParamResult> response) {
                    if (response.isSuccessful()) {
                        Map<String, Object> bodyMap = null;
                        try {
                            SysParamResult body = response.body();
                            if (body != null) bodyMap = sysParamToMap(body);
                        } catch (Throwable ignored) {}
                        postResultSuccess(result, responseToMap(response, bodyMap));
                    } else {
                        try {
                            Map<String, Object> details = new HashMap<>();
                            details.put("code", response.code());
                            details.put("ackMessage", ackMessageForCode(response.code()));
                            postResultError(result, "FAILED", "Code: " + response.code(), details);
                        } catch (Throwable t) {
                            postResultError(result, "FAILED", "Code: " + response.code(), null);
                        }
                    }
                }

                @Override
                public void onFailure(Throwable t) {
                    Log.e(TAG, "getSysParam failed", t);
                    postResultError(result, "ERROR", t.getMessage(), null);
                }
            });
        } catch (Throwable t) {
            Log.e(TAG, "Exception calling getSysParam", t);
            postResultError(result, "ERROR", t.getMessage(), null);
        }
    }

    /**
     * Streaming variant: emits one or more sysParam events via callback.
     * Useful when native may emit interim updates.
     */
    public void getSysParamStream(Map<String, Object> args, final SysParamStreamCallback callback) {
        Log.d(TAG, "getSysParamStream called with args: " + args);
        try {
            BlinkyAction action = new BlinkyAction();
            action.setBaseAuthAction(PluginUtils.createAuthAction(args));

            bleClient.getSysParam(action, new FunCallback<SysParamResult>() {
                @Override
                public void onResponse(Response<SysParamResult> response) {
                    try {
                        Map<String, Object> bodyMap = null;
                        try {
                            SysParamResult body = response.body();
                            if (body != null) bodyMap = sysParamToMap(body);
                        } catch (Throwable ignored) {}

                        Map<String, Object> evt = responseToMap(response, bodyMap);
                        // Tag as streaming event
                        Map<String, Object> out = new HashMap<>();
                        out.put("type", "sysParam");
                        out.put("response", evt);
                        callback.onData(out);

                        // Emit done
                        Map<String, Object> done = new HashMap<>();
                        done.put("type", "sysParamDone");
                        done.put("response", evt);
                        callback.onDone(done);
                    } catch (Throwable t) {
                        Map<String, Object> err = new HashMap<>();
                        err.put("type", "sysParamError");
                        err.put("message", t.getMessage());
                        callback.onError(err);
                    }
                }

                @Override
                public void onFailure(Throwable t) {
                    Map<String, Object> err = new HashMap<>();
                    err.put("type", "sysParamError");
                    err.put("message", t.getMessage());
                    callback.onError(err);
                }
            });
        } catch (Throwable t) {
            Map<String, Object> err = new HashMap<>();
            err.put("type", "sysParamError");
            err.put("message", t.getMessage());
            callback.onError(err);
        }
    }

    /**
     * Enable or disable key types on the lock.
     * Uses operation mode 02 (by key type).
     * - validNumber == 0 -> disable
     * - validNumber != 0 -> enable
     */
    public void enableDisableKeyByType(Map<String, Object> args, final Result result) {
        Log.d(TAG, "[BleLockManager] enableDisableKeyByType called with args: " + args);
        try {
            EnableLockKeyAction action = new EnableLockKeyAction();
            action.setBaseAuthAction(PluginUtils.createAuthAction(args));

            // Extract parameters from args
            int operationMod = getSafe("operationMod", () -> (Integer) args.get("operationMod"), 2);
            int keyTypeOperMode = getSafe("keyTypeOperMode", () -> (Integer) args.get("keyTypeOperMode"), 2);
            int keyType = getSafe("keyType", () -> (Integer) args.get("keyType"), 0);
            int validNumber = getSafe("validNumber", () -> (Integer) args.get("validNumber"), 0);

            action.setOperationMod(operationMod);
            action.setKeyType(keyTypeOperMode);

            // For operation mode 02 (by key type):
            // - If validNumber == 0, we want to DISABLE the key types
            // - If validNumber != 0, we want to ENABLE the key types
            // The keyIdEn field is used as a bitmask in mode 02:
            //   - Set bit = 1 means enable that type
            //   - Set bit = 0 means disable that type
            if (validNumber == 0) {
                // Disable: set keyIdEn to 0 (all bits off)
                action.setKeyIdEn(0);
                Log.d(TAG, "[BleLockManager] Disabling key types: " + keyType);
            } else {
                // Enable: set keyIdEn to the keyType bitmask
                action.setKeyIdEn(keyType);
                Log.d(TAG, "[BleLockManager] Enabling key types: " + keyType + " with validNumber: " + validNumber);
            }
            
            bleClient.enableLockKey(action, new FunCallback() {
                @Override
                public void onResponse(Response response) {
                    Log.d(TAG, "[BleLockManager] enableLockKey response: " + response);
                    try {
                        Map<String, Object> resMap = responseToMap(response, null);
                        if (response != null && response.isSuccessful()) {
                            resMap.put("success", true);
                            postResultSuccess(result, resMap);
                        } else {
                            resMap.put("success", false);
                            postResultError(result, "FAILED", "Code: " + (response != null ? response.code() : -1), resMap);
                        }
                    } catch (Throwable t) {
                        Log.e(TAG, "[BleLockManager] Error processing enableLockKey response", t);
                        postResultError(result, "ERROR", t.getMessage(), null);
                    }
                }

                @Override
                public void onFailure(Throwable t) {
                    Log.e(TAG, "[BleLockManager] enableLockKey failed", t);
                    postResultError(result, "ERROR", t.getMessage(), null);
                }
            });
        } catch (Throwable t) {
            Log.e(TAG, "[BleLockManager] Exception calling enableLockKey", t);
            postResultError(result, "ERROR", t.getMessage(), null);
        }
    }
}