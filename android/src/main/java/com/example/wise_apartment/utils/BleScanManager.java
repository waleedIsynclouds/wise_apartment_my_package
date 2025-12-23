package com.example.wise_apartment.utils;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import androidx.annotation.NonNull;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel.Result;
import com.example.hxjblinklibrary.blinkble.scanner.HxjBluetoothDevice;
import com.example.hxjblinklibrary.blinkble.scanner.HxjScanCallback;
import com.example.hxjblinklibrary.blinkble.scanner.HxjScanner;

public class BleScanManager {
    private static final String TAG = "BleScanManager";
    private final Context context;

    public BleScanManager(Context context) {
        this.context = context;
    }

    public void startScan(Integer timeout, final Result result) {
        if (timeout == null) timeout = 10000;
        Log.d(TAG, "Starting scan with timeout: " + timeout);

        final Map<String, Map<String, Object>> uniqueDevices = new HashMap<>(); // Using map to deduce duplicates by MAC

        HxjScanner.getInstance().startScan(timeout, context, new HxjScanCallback() {
            @Override
            public void onHxjScanResults(@NonNull List<HxjBluetoothDevice> results) {
                for (HxjBluetoothDevice device : results) {
                    Map<String, Object> d = new HashMap<>();
                    d.put("mac", device.getMac());
                    d.put("name", device.getName());
                    d.put("rssi", device.getRssi());
                    uniqueDevices.put(device.getMac(), d);
                }
            }
            
            @Override
            public void onScanFailed(int i) {
                 Log.e(TAG, "Scan Failed code: " + i);
            }
        });

        // Return results after timeout
        new Handler(Looper.getMainLooper()).postDelayed(new Runnable() {
            @Override
            public void run() {
                HxjScanner.getInstance().stopScan();
                List<Map<String, Object>> finalResults = new ArrayList<>(uniqueDevices.values());
                Log.d(TAG, "Scan finished, found " + finalResults.size() + " devices");
                try {
                    result.success(finalResults);
                } catch (Exception e) {
                    Log.w(TAG, "Could not send scan result (maybe channel closed)", e);
                }
            }
        }, timeout);
    }

    public void stopScan(final Result result) {
        Log.d(TAG, "Stopping scan");
        HxjScanner.getInstance().stopScan();
        result.success(true);
    }
}
