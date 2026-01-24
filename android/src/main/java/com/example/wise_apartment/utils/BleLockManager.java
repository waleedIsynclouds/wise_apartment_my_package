package com.example.wise_apartment.utils;

import android.util.Log;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel.Result;
import com.example.hxjblinklibrary.blinkble.profile.client.HxjBleClient;
import com.example.hxjblinklibrary.blinkble.profile.client.FunCallback;
import com.example.hxjblinklibrary.blinkble.entity.Response;
import com.example.hxjblinklibrary.blinkble.entity.reslut.HxBLEUnlockResult;
import com.example.hxjblinklibrary.blinkble.entity.reslut.DnaInfo;
import com.example.hxjblinklibrary.blinkble.entity.reslut.SysParamResult;
import com.example.hxjblinklibrary.blinkble.entity.requestaction.OpenLockAction;
import com.example.hxjblinklibrary.blinkble.entity.requestaction.BlinkyAction;
import com.example.hxjblinklibrary.blinkble.entity.requestaction.BleSetHotelLockSystemAction;
import com.example.hxjblinklibrary.blinkble.entity.requestaction.BleHotelLockSystemParam;
import java.util.HashMap;

public class BleLockManager {
    private static final String TAG = "BleLockManager";
    private final HxjBleClient bleClient;

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
                    result.success(true);
                } else {
                    result.error("FAILED", "Code: " + response.code(), null);
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
        BlinkyAction action = new BlinkyAction();
        action.setBaseAuthAction(PluginUtils.createAuthAction(args));
        
        bleClient.closeLock(action, new FunCallback<Object>() {
            @Override
            public void onResponse(Response<Object> response) {
                 Log.d(TAG, "closeLock response: " + response.code());
                 if (response.isSuccessful()) result.success(true);
                 else result.error("FAILED", "Code: " + response.code(), null);
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
                else result.error("FAILED", "Code: " + response.code(), null);
            }
            @Override
            public void onFailure(Throwable t) {
                 result.error("ERROR", t.getMessage(), null);
            }
        });
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
                else result.error("FAILED", "Code: " + response.code(), null);
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
                    Map<String, Object> res = new HashMap<>();
                    DnaInfo dna = response.body();
                    res.put("mac", dna.getMac());
                    result.success(res);
                } else {
                     result.error("FAILED", "Code: " + response.code(), null);
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
        final com.example.hxjblinklibrary.blinkble.entity.requestaction.BlinkyAuthAction auth = com.example.wise_apartment.utils.PluginUtils.createAuthAction(args);

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
                if (!response.isSuccessful() || response.body() == null) {
                    result.error("FAILED", "addDevice failed: Code " + response.code(), null);
                    return;
                }

                DnaInfo dna = response.body();
                Log.d(TAG, "addDevice got DnaInfo: " + dna.getMac());

                // Build base auth action from dna info (mimic sample saveAuthInfo)
                com.example.hxjblinklibrary.blinkble.entity.requestaction.BlinkyAuthAction baseAuth = new com.example.hxjblinklibrary.blinkble.entity.requestaction.BlinkyAuthAction.Builder()
                        .bleProtocolVer(dna.getProtocolVer())
                        .authCode(dna.getAuthorizedRoot())
                        .dnaKey(dna.getDnaAes128Key())
                        .mac(dna.getMac())
                        .keyGroupId(900)
                        .build();

                // Query device status (getSysParam) then call pairSuccessInd
                BlinkyAction action = new BlinkyAction();
                action.setBaseAuthAction(baseAuth);

                try {
                    bleClient.getSysParam(action, new FunCallback<SysParamResult>() {
                        @Override
                        public void onResponse(Response<SysParamResult> resp) {
                            if (!resp.isSuccessful() || resp.body() == null) {
                                result.error("FAILED", "getSysParam failed: Code " + resp.code(), null);
                                return;
                            }

                            // Now notify device that pairing succeeded on server
                            bleClient.pairSuccessInd(action, true, new FunCallback() {
                                @Override
                                public void onResponse(Response response) {
                                    bleClient.disConnectBle(null);
                                    if (response.isSuccessful()) {
                                        try {
                                            bleClient.rfModulePairing(action, "", new FunCallback() {
                                                @Override
                                                public void onResponse(Response response) {
                                                    Log.d(TAG, "rfModulePairing response: " + response.code());
                                                }

                                                @Override
                                                public void onFailure(Throwable throwable) {
                                                    Log.d(TAG, "rfModulePairing failure: " + throwable.getMessage());
                                                }
                                            });
                                        } catch (Exception ignored) {}

                                        result.success(true);
                                    } else {
                                        result.error("FAILED", "pairSuccessInd failed: Code " + response.code(), null);
                                    }
                                }

                                @Override
                                public void onFailure(Throwable t) {
                                    Log.e(TAG, "pairSuccessInd failed", t);
                                    result.error("ERROR", t.getMessage(), null);
                                }
                            });
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

                if (response.isSuccessful()) {
                    // Optionally trigger rfModulePairing (as in sample app) but ignore its result here
                    try {
                        bleClient.rfModulePairing(hxBleAction, "", new FunCallback() {
                            @Override
                            public void onResponse(Response response) {
                                Log.d(TAG, "rfModulePairing response: " + response.code());
                            }

                            @Override
                            public void onFailure(Throwable throwable) {
                                Log.d(TAG, "rfModulePairing failure: " + throwable.getMessage());
                            }
                        });
                    } catch (Exception ignored) {}

                    result.success(true);
                } else {
                    result.error("FAILED", "Code: " + response.code(), null);
                }
            }

            @Override
            public void onFailure(Throwable t) {
                Log.e(TAG, "pairSuccessInd failed", t);
                result.error("ERROR", t.getMessage(), null);
            }
        });
    }
}
