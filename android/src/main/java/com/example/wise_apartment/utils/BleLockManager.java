package com.example.wise_apartment.utils;

import android.util.Log;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel.Result;
import com.example.hxjblinklibrary.blinkble.profile.client.HxjBleClient;
import com.example.hxjblinklibrary.blinkble.profile.client.FunCallback;
import com.example.hxjblinklibrary.blinkble.entity.Response;
import com.example.hxjblinklibrary.blinkble.entity.reslut.HxBLEUnlockResult;
import com.example.hxjblinklibrary.blinkble.entity.reslut.DnaInfo;
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
}
