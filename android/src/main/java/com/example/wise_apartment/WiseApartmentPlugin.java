package com.example.wise_apartment;

import android.Manifest;
import android.content.Context;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.os.Build;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.core.content.ContextCompat;

import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import com.example.hxjblinklibrary.blinkble.profile.client.HxjBleClient;
import android.bluetooth.BluetoothDevice;
import com.example.hxjblinklibrary.blinkble.profile.client.LinkCallBack;

import com.example.wise_apartment.utils.BleLockManager;
import com.example.wise_apartment.utils.BleScanManager;
import com.example.wise_apartment.utils.DeviceInfoManager;
import com.example.wise_apartment.utils.LockRecordManager;

/**
 * WiseApartmentPlugin
 * Delegates logic to specialized Managers in the utils package.
 */
public class WiseApartmentPlugin implements FlutterPlugin, MethodCallHandler {
  private MethodChannel channel;
  private Context context;
  private static final String PREF_NAME = "WiseApartmentPrefs";
  private static final String TAG = "WiseApartmentPlugin";

  private HxjBleClient bleClient;
  
  // Managers
  private BleLockManager lockManager;
  private BleScanManager scanManager;
  private DeviceInfoManager deviceInfoManager;
  private LockRecordManager recordManager;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "wise_apartment/methods");
    channel.setMethodCallHandler(this);
    context = flutterPluginBinding.getApplicationContext();
    initClient();
  }

  private void initClient() {
      if (bleClient == null) {
          bleClient = new HxjBleClient(context);
          Log.d(TAG, "HxjBleClient initialized");
          bleClient.setLinkCallBack(new LinkCallBack() {
              @Override
              public void onDeviceConnected(@NonNull BluetoothDevice device) {
                  Log.d(TAG, "Connected: " + device.getAddress());
              }
              @Override
              public void onDeviceDisconnected(@NonNull BluetoothDevice device) {
                  Log.d(TAG, "Disconnected: " + device.getAddress());
              }
              @Override
              public void onLinkLossOccurred(@NonNull BluetoothDevice device) {
                   Log.d(TAG, "Link Loss: " + device.getAddress());
              }
              @Override
              public void onDeviceReady(@NonNull BluetoothDevice device) {}
              @Override
              public void onDeviceNotSupported(@NonNull BluetoothDevice device) {}
              @Override
              public void onError(@NonNull BluetoothDevice device, @NonNull String message, int errorCode) {
                  Log.e(TAG, "Error: " + message + " (" + errorCode + ")");
              }
              @Override
              public void onEventReport(String data, int cmdVersion, String mac) {
                  Log.d(TAG, "Event: " + data);
              }
          });
          
          // Initialize Managers with the client
          lockManager = new BleLockManager(bleClient);
          scanManager = new BleScanManager(context);
          deviceInfoManager = new DeviceInfoManager(context, bleClient);
          recordManager = new LockRecordManager(bleClient);
      }
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    Log.v(TAG, "MethodCall: " + call.method);
    switch (call.method) {
      case "getPlatformVersion":
        result.success("Android " + android.os.Build.VERSION.RELEASE);
        break;
      case "getDeviceInfo":
        deviceInfoManager.getDeviceInfo(result);
        break;
      case "getAndroidBuildConfig":
        deviceInfoManager.getAndroidBuildConfig(result);
        break;
      case "initBleClient":
        initClient(); // Ensure client is ready
        result.success(true);
        break;
      case "startScan":
        if (!checkPermissions()) {
             result.error("PERMISSION_DENIED", "Missing Location or Bluetooth permissions", null);
             return;
        }
        Integer timeout = call.argument("timeoutMs");
        scanManager.startScan(timeout, result);
        break;
      case "stopScan":
        scanManager.stopScan(result);
        break;
      case "openLock":
        if (!checkPermissions()) {
             result.error("PERMISSION_DENIED", "Missing permissions", null);
             return;
        }
        lockManager.openLock((Map<String, Object>) call.arguments, result);
        break;
      case "closeLock":
        lockManager.closeLock((Map<String, Object>) call.arguments, result);
        break;
      case "disconnect":
        bleClient.disConnectBle(null);
        result.success(true);
        break;
      case "clearSdkState":
        handleClearSdkState(result);
        break;
      case "getNBIoTInfo":
        deviceInfoManager.getNBIoTInfo((Map<String, Object>) call.arguments, result);
        break;
      case "getCat1Info":
        deviceInfoManager.getCat1Info((Map<String, Object>) call.arguments, result);
        break;
      case "setKeyExpirationAlarmTime":
        lockManager.setKeyExpirationAlarmTime((Map<String, Object>) call.arguments, result);
        break;
      case "syncLockRecords":
        recordManager.syncLockRecords((Map<String, Object>) call.arguments, result);
        break;
      case "deleteLock":
        lockManager.deleteLock((Map<String, Object>) call.arguments, result);
        break;
      case "getDna":
        lockManager.getDna((Map<String, Object>) call.arguments, result);
        break;
      case "addDevice":
        // Orchestrated addDevice: add -> getSysParam -> pairSuccessInd
        lockManager.addDevice((Map<String, Object>) call.arguments, result);
        break;
      default:
        result.notImplemented();
        break;
    }
  }

  private void handleClearSdkState(Result result) {
      SharedPreferences prefs = context.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE);
      prefs.edit().clear().apply();
      result.success(true);
  }

  private boolean checkPermissions() {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
       return ContextCompat.checkSelfPermission(context, Manifest.permission.BLUETOOTH_SCAN) == PackageManager.PERMISSION_GRANTED &&
              ContextCompat.checkSelfPermission(context, Manifest.permission.BLUETOOTH_CONNECT) == PackageManager.PERMISSION_GRANTED;
    } else {
       return ContextCompat.checkSelfPermission(context, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED;
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
    // Cleanup if needed
  }
}
