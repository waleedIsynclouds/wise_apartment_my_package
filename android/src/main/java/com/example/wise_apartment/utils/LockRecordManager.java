package com.example.wise_apartment.utils;

import android.util.Log;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel.Result;
import com.example.hxjblinklibrary.blinkble.profile.client.HxjBleClient;
import com.example.hxjblinklibrary.blinkble.profile.client.FunCallback;
import com.example.hxjblinklibrary.blinkble.entity.Response;
import com.example.hxjblinklibrary.blinkble.entity.requestaction.BlinkyAction;
import com.example.hxjblinklibrary.blinkble.entity.requestaction.BlinkyAuthAction;
import com.example.hxjblinklibrary.blinkble.entity.requestaction.SyncLockRecordAction;
import com.example.hxjblinklibrary.blinkble.entity.reslut.LockRecordDataResult;
import com.example.hxjblinklibrary.blinkble.entity.reslut.lockrecord1.HXRecordBaseModel;
import com.example.hxjblinklibrary.blinkble.entity.reslut.lockrecord2.HXRecord2BaseModel;

public class LockRecordManager {
    private static final String TAG = "LockRecordManager";
    private final HxjBleClient bleClient;

    // State for recursion
    private int currentSyncIndex = 0;
    private int totalSyncRecords = 0;
    private List<Map<String, Object>> syncLogList = new ArrayList<>();
    private Result syncResult;
    private BlinkyAuthAction syncAuth;
    private int syncLogVersion;

    public LockRecordManager(HxjBleClient client) {
        this.bleClient = client;
    }

    public void syncLockRecords(Map<String, Object> args, final Result result) {
        Log.d(TAG, "syncLockRecords called");
        syncAuth = PluginUtils.createAuthAction(args);
        syncLogVersion = (int) args.get("logVersion");
        syncResult = result;
        syncLogList.clear();
        
        BlinkyAction action = new BlinkyAction();
        action.setBaseAuthAction(syncAuth);
        
        bleClient.getRecordNum(action, new FunCallback<Integer>() {
            @Override
            public void onResponse(Response<Integer> response) {
                if (response.isSuccessful() && response.body() != null) {
                    totalSyncRecords = response.body();
                    Log.d(TAG, "Total records to sync: " + totalSyncRecords);
                    currentSyncIndex = 0;
                    recursiveQueryRecords();
                } else {
                    Log.e(TAG, "Failed to get record num: " + response.code());
                    result.error("FAILED", "Get Record Num Failed: " + response.code(), null);
                }
            }
            @Override
            public void onFailure(Throwable t) {
                Log.e(TAG, "Failed to get record num", t);
                result.error("ERROR", t.getMessage(), null);
            }
        });
    }

    private void recursiveQueryRecords() {
        Log.d(TAG, "Querying records from index: " + currentSyncIndex);
        SyncLockRecordAction action = new SyncLockRecordAction(currentSyncIndex, 10, syncLogVersion);
        action.setBaseAuthAction(syncAuth);
        
        bleClient.syncLockRecord(action, new FunCallback<LockRecordDataResult>() {
            @Override
             public void onResponse(Response<LockRecordDataResult> response) {
                 if (response.isSuccessful() && response.body() != null) {
                     LockRecordDataResult body = response.body();
                     Log.d(TAG, "Got batch of " + body.getLogNum() + " records");
                     
                     // Process logs
                     if (body.getLogNum() > 0) {
                          if (syncLogVersion == 1) {
                              for (HXRecordBaseModel r : body.getLog1Array()) {
                                  Map<String, Object> m = new HashMap<>();
                                  m.put("date", r.toString()); // Simplify for now
                                  syncLogList.add(m);
                              }
                          } else if (syncLogVersion == 2) {
                              for (HXRecord2BaseModel r : body.getLog2Array()) {
                                  Map<String, Object> m = new HashMap<>();
                                  m.put("date", r.toString());
                                  syncLogList.add(m);
                              }
                          }
                          currentSyncIndex += body.getLogNum();
                     }
                     
                     // Recursion or finish
                     if (!body.isMoreData() || currentSyncIndex >= totalSyncRecords) {
                          Log.d(TAG, "Sync complete, returning " + syncLogList.size() + " records");
                          syncResult.success(syncLogList);
                     } else {
                          recursiveQueryRecords();
                     }
                 } else {
                      Log.e(TAG, "Sync failed at index " + currentSyncIndex + " code: " + response.code());
                      syncResult.error("FAILED", "Sync Failed: " + response.code(), null);
                 }
             }
             @Override
             public void onFailure(Throwable t) {
                 Log.e(TAG, "Sync failed exception", t);
                 syncResult.error("ERROR", t.getMessage(), null);
             }
        });
    }
}
