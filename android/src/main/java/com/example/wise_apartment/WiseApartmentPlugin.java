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
import io.flutter.plugin.common.EventChannel;

import com.example.hxjblinklibrary.blinkble.profile.client.HxjBleClient;
import android.bluetooth.BluetoothDevice;
import com.example.hxjblinklibrary.blinkble.profile.client.LinkCallBack;
import com.example.hxjblinklibrary.blinkble.profile.client.FunCallback;
import com.example.hxjblinklibrary.blinkble.entity.requestaction.BlinkyAction;
import com.example.hxjblinklibrary.blinkble.entity.Response;

import com.example.wise_apartment.utils.BleLockManager;
import com.example.wise_apartment.utils.BleScanManager;
import com.example.wise_apartment.utils.DeviceInfoManager;
import com.example.wise_apartment.utils.LockRecordManager;
import com.example.wise_apartment.utils.OneShotResult;
import com.example.wise_apartment.utils.PluginUtils;
import com.example.wise_apartment.utils.MyBleClient;

/**
 * WiseApartmentPlugin
 * Delegates logic to specialized Managers in the utils package.
 */
public class WiseApartmentPlugin implements FlutterPlugin, MethodCallHandler {
  private MethodChannel channel;
  private EventChannel eventChannel;
  private EventChannel.EventSink eventSink;
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
    
    // Register EventChannel for streaming events
    eventChannel = new EventChannel(flutterPluginBinding.getBinaryMessenger(), "wise_apartment/ble_events");
    eventChannel.setStreamHandler(new EventChannel.StreamHandler() {
      @Override
      public void onListen(Object arguments, EventChannel.EventSink events) {
        eventSink = events;
        Log.d(TAG, "EventChannel listener attached");
      }

      @Override
      public void onCancel(Object arguments) {
        eventSink = null;
        Log.d(TAG, "EventChannel listener cancelled");
      }
    });
    
    context = flutterPluginBinding.getApplicationContext();
    initClient();
  }

  private void initClient() {
      if (bleClient == null) {
        try {
          // Use MyBleClient which handles WiFi registration events
          bleClient = MyBleClient.getInstance(context);
          Log.d(TAG, "MyBleClient initialized");
          
          // Register WiFi registration callback to emit events to Flutter
          if (bleClient instanceof MyBleClient) {
            ((MyBleClient) bleClient).setWifiRegistrationCallback(new MyBleClient.WifiRegistrationCallback() {
              @Override
              public void onWifiRegistrationEvent(final int status, final String moduleMac, final String lockMac) {
                new android.os.Handler(android.os.Looper.getMainLooper()).post(new Runnable() {
                  @Override
                  public void run() {
                    if (eventSink != null) {
                      Map<String, Object> event = new java.util.HashMap<>();
                      event.put("type", "wifiRegistration");
                      event.put("status", status);
                      event.put("moduleMac", moduleMac != null ? moduleMac : "");
                      event.put("lockMac", lockMac != null ? lockMac : "");
                      
                      // Add status message for convenience
                      String statusMessage;
                      switch (status) {
                        case 0x02:
                          statusMessage = "Network distribution binding in progress";
                          break;
                        case 0x04:
                          statusMessage = "WiFi module connected to router";
                          break;
                        case 0x05:
                          statusMessage = "WiFi module connected to cloud (success)";
                          break;
                        case 0x06:
                          statusMessage = "Incorrect password";
                          break;
                        case 0x07:
                          statusMessage = "WiFi configuration timeout";
                          break;
                        default:
                          statusMessage = "Unknown status: 0x" + Integer.toHexString(status);
                          break;
                      }
                      event.put("statusMessage", statusMessage);
                      
                      Log.d(TAG, "Emitting wifiRegistration event: " + statusMessage);
                      eventSink.success(event);
                    }
                  }
                });
              }
            });
          }
          
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
        } catch (Throwable t) {
          // Defensive: log full stacktrace so release builds show cause
          Log.e(TAG, "initClient failed", t);
          // Ensure partial objects aren't left in a bad state
          bleClient = null;
          lockManager = null;
          scanManager = null;
          deviceInfoManager = null;
          recordManager = null;
        }
      }
  }

  /**
   * Ensure the plugin and underlying HXJ BLE SDK objects are initialized.
   * Returns true when ready. If initialization fails, sends an error on the
   * provided Result and returns false.
   */
  private boolean ensureInitialized(@NonNull Result result) {
    try {
      if (context == null) {
        result.error("INIT_ERROR", "Plugin context is null. Plugin not attached.", null);
        return false;
      }

      if (bleClient == null || lockManager == null || scanManager == null || deviceInfoManager == null || recordManager == null) {
        try {
          initClient();
        } catch (Throwable t) {
          Log.e(TAG, "initClient() threw", t);
          result.error("INIT_ERROR", "Failed to initialize BLE client: " + t.getMessage(), null);
          return false;
        }
      }

      if (bleClient == null || lockManager == null || scanManager == null || deviceInfoManager == null || recordManager == null) {
        result.error("INIT_ERROR", "BLE SDK not fully initialized.", null);
        return false;
      }
      return true;
    } catch (Throwable t) {
      Log.e(TAG, "ensureInitialized unexpected", t);
      try { result.error("INIT_ERROR", "Unexpected initialization error: " + t.getMessage(), null); } catch (Throwable ignore) {}
      return false;
    }
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    Log.v(TAG, "MethodCall: " + call.method);
    // Wrap the incoming Result so we only ever reply once and always on
    // the main thread. Use `safeResult` for all replies below.
    final Result safeResult = new OneShotResult(result, TAG);

    // Ensure initialization for all methods that depend on the BLE SDK.
    String _method = call.method;
    if (!"getPlatformVersion".equals(_method) && !"initBleClient".equals(_method)) {
      if (!ensureInitialized(safeResult)) {
        return; // ensureInitialized already sent an error to Flutter
      }
    }

    switch (_method) {
      case "getPlatformVersion":
        safeResult.success("Android " + android.os.Build.VERSION.RELEASE);
        break;
      case "getDeviceInfo":
        if (deviceInfoManager != null) {
          deviceInfoManager.getDeviceInfo(safeResult);
        } else {
          safeResult.error("INIT_ERROR", "DeviceInfoManager not initialized", null);
        }
        break;
      case "getAndroidBuildConfig":
        if (deviceInfoManager != null) {
          deviceInfoManager.getAndroidBuildConfig(safeResult);
        } else {
          safeResult.error("INIT_ERROR", "DeviceInfoManager not initialized", null);
        }
        break;
      case "initBleClient":
        initClient(); // Ensure client is ready
        safeResult.success(true);
        break;
      case "startScan":
        if (!checkPermissions()) {
             safeResult.error("PERMISSION_DENIED", "Missing Location or Bluetooth permissions", null);
             return;
        }
        if (scanManager != null) {
          Integer timeout = call.argument("timeoutMs");
          scanManager.startScan(timeout, safeResult);
        } else {
          safeResult.error("INIT_ERROR", "Scan manager not initialized", null);
        }
        break;
      case "stopScan":
        if (scanManager != null) {
          scanManager.stopScan(safeResult);
        } else {
          safeResult.error("INIT_ERROR", "Scan manager not initialized", null);
        }
        break;
      case "openLock":
        if (!checkPermissions()) {
             safeResult.error("PERMISSION_DENIED", "Missing permissions", null);
             return;
        }
        if (lockManager != null) {
          lockManager.openLock((Map<String, Object>) call.arguments, safeResult);
        } else {
          safeResult.error("INIT_ERROR", "Lock manager not initialized", null);
        }
        break;
      case "closeLock":
        if (lockManager != null) {
          lockManager.closeLock((Map<String, Object>) call.arguments, safeResult);
        } else {
          safeResult.error("INIT_ERROR", "Lock manager not initialized", null);
        }
        break;
      case "disconnect":
        if (bleClient != null) {
          bleClient.disConnectBle(null);
          safeResult.success(true);
        } else {
          safeResult.error("INIT_ERROR", "BLE client not initialized", null);
        }
        break;
      case "disconnectBle":
        if (bleClient != null) {
          try {
            bleClient.disConnectBle(new FunCallback() {
              @Override
              public void onResponse(Response response) {
                safeResult.success(true);
              }

              @Override
              public void onFailure(Throwable t) {
                safeResult.error("ERROR", t.getMessage(), null);
              }
            });
          } catch (Throwable t) {
            // Fallback to immediate disconnect if callback variant fails
            safeResult.error("ERROR", "disconnectBle failed: " + t.getMessage(), null);
          }
        } else {
          safeResult.error("INIT_ERROR", "BLE client not initialized", null);
        }
        break;
      case "connectBle":
        if (bleClient != null) {
          try {
            BlinkyAction action = new BlinkyAction();
            action.setBaseAuthAction(PluginUtils.createAuthAction((Map<String, Object>) call.arguments));
            bleClient.connectBle(action, new FunCallback() {
              @Override
              public void onResponse(Response response) {
                if (response != null && response.isSuccessful()) {
                  safeResult.success(true);
                } else {
                  try {
                    Map<String, Object> details = new java.util.HashMap<>();
                    if (response != null) details.put("code", response.code());
                    details.put("ackMessage", com.example.wise_apartment.utils.WiseStatusCode.description(response == null ? -1 : response.code()));
                    safeResult.error("FAILED", "Code: " + (response == null ? "-1" : response.code()), details);
                  } catch (Throwable t) {
                    safeResult.error("FAILED", "Connect failed", null);
                  }
                }
              }

              @Override
              public void onFailure(Throwable t) {
                safeResult.error("ERROR", t.getMessage(), null);
              }
            });
          } catch (Throwable t) {
            Log.e(TAG, "connectBle invocation failed", t);
            safeResult.error("ERROR", "connectBle invocation failed: " + t.getMessage(), null);
          }
        } else {
          safeResult.error("INIT_ERROR", "BLE client not initialized", null);
        }
        break;
      case "clearSdkState":
        handleClearSdkState(safeResult);
        break;
      case "getNBIoTInfo":
        if (deviceInfoManager != null) {
          deviceInfoManager.getNBIoTInfo((Map<String, Object>) call.arguments, safeResult);
        } else {
          safeResult.error("INIT_ERROR", "DeviceInfoManager not initialized", null);
        }
        break;
      case "getCat1Info":
        if (deviceInfoManager != null) {
          deviceInfoManager.getCat1Info((Map<String, Object>) call.arguments, safeResult);
        } else {
          safeResult.error("INIT_ERROR", "DeviceInfoManager not initialized", null);
        }
        break;
      case "setKeyExpirationAlarmTime":
        if (lockManager != null) {
          lockManager.setKeyExpirationAlarmTime((Map<String, Object>) call.arguments, safeResult);
        } else {
          safeResult.error("INIT_ERROR", "Lock manager not initialized", null);
        }
        break;
      case "syncLockRecords":
        if (recordManager != null) {
          // Use streaming version if eventSink is available
          if (eventSink != null) {
            Log.d(TAG, "Using streaming syncLockRecords");
            recordManager.syncLockRecordsStream((Map<String, Object>) call.arguments,
                new LockRecordManager.SyncLockRecordsStreamCallback() {
                  @Override
                  public void onChunk(final Map<String, Object> event) {
                    new android.os.Handler(android.os.Looper.getMainLooper()).post(new Runnable() {
                      @Override
                      public void run() {
                        if (eventSink != null) {
                          Log.d(TAG, "Emitting syncLockRecordsChunk event");
                          eventSink.success(event);
                        }
                      }
                    });
                  }

                  @Override
                  public void onDone(final Map<String, Object> event) {
                    new android.os.Handler(android.os.Looper.getMainLooper()).post(new Runnable() {
                      @Override
                      public void run() {
                        if (eventSink != null) {
                          Log.d(TAG, "Emitting syncLockRecordsDone event");
                          eventSink.success(event);
                        }
                      }
                    });
                  }

                  @Override
                  public void onError(final Map<String, Object> event) {
                    new android.os.Handler(android.os.Looper.getMainLooper()).post(new Runnable() {
                      @Override
                      public void run() {
                        if (eventSink != null) {
                          Log.d(TAG, "Emitting syncLockRecordsError event");
                          eventSink.success(event);
                        }
                      }
                    });
                  }
                });
            safeResult.success(null); // Acknowledge method call immediately
          } else {
            // Fallback to non-streaming version
            Log.d(TAG, "EventSink not available, using non-streaming syncLockRecords");
            recordManager.syncLockRecords((Map<String, Object>) call.arguments, safeResult);
          }
        } else {
          safeResult.error("INIT_ERROR", "Record manager not initialized", null);
        }
        break;
      case "syncLockRecordsPage":
        if (recordManager != null) {
          recordManager.syncLockRecordsPage((Map<String, Object>) call.arguments, safeResult);
        } else {
          safeResult.error("INIT_ERROR", "Record manager not initialized", null);
        }
        break;
      case "deleteLock":
        if (lockManager != null) {
          lockManager.deleteLock((Map<String, Object>) call.arguments, safeResult);
        } else {
          safeResult.error("INIT_ERROR", "Lock manager not initialized", null);
        }
        break;
      case "changeLockKeyPwd":
        if (lockManager != null) {
          lockManager.changeLockKeyPwd((Map<String, Object>) call.arguments, safeResult);
        } else {
          safeResult.error("INIT_ERROR", "Lock manager not initialized", null);
        }
        break;
      case "modifyLockKey":
        if (lockManager != null) {
          lockManager.modifyLockKey((Map<String, Object>) call.arguments, safeResult);
        } else {
          safeResult.error("INIT_ERROR", "Lock manager not initialized", null);
        }
        break;
      case "getDna":
        if (lockManager != null) {
          lockManager.getDna((Map<String, Object>) call.arguments, safeResult);
        } else {
          safeResult.error("INIT_ERROR", "Lock manager not initialized", null);
        }
        break;
      case "addDevice":
        // Orchestrated addDevice: add -> getSysParam -> pairSuccessInd
        if (lockManager != null) {
          lockManager.addDevice((Map<String, Object>) call.arguments, safeResult);
        } else {
          safeResult.error("INIT_ERROR", "Lock manager not initialized", null);
        }
        break;
      case "regWifi":
        if (lockManager != null) {
          lockManager.registerWifi((Map<String, Object>) call.arguments, safeResult);
        } else {
          safeResult.error("INIT_ERROR", "Lock manager not initialized", null);
        }
        break;
      case "addLockKey":
        if (lockManager != null) {
          lockManager.addLockKey((Map<String, Object>) call.arguments, safeResult);
        } else {
          safeResult.error("INIT_ERROR", "Lock manager not initialized", null);
        }
        break;
      case "addFingerprintKeyStream":
        if (lockManager != null) {
          if (eventSink != null) {
            lockManager.addFingerprintKeyStream((Map<String, Object>) call.arguments, new com.example.wise_apartment.utils.BleLockManager.AddLockKeyStreamCallback() {
              @Override
              public void onChunk(final Map<String, Object> chunkEvent) {
                new android.os.Handler(android.os.Looper.getMainLooper()).post(new Runnable() {
                  @Override
                  public void run() {
                    if (eventSink != null) eventSink.success(chunkEvent);
                  }
                });
              }

              @Override
              public void onDone(final Map<String, Object> doneEvent) {
                new android.os.Handler(android.os.Looper.getMainLooper()).post(new Runnable() {
                  @Override
                  public void run() {
                    if (eventSink != null) eventSink.success(doneEvent);
                  }
                });
              }

              @Override
              public void onError(final Map<String, Object> errorEvent) {
                new android.os.Handler(android.os.Looper.getMainLooper()).post(new Runnable() {
                  @Override
                  public void run() {
                    if (eventSink != null) {
                      eventSink.error(String.valueOf(errorEvent.get("code")), String.valueOf(errorEvent.get("message")), errorEvent);
                    }
                  }
                });
              }
            });
            safeResult.success(java.util.Collections.singletonMap("streaming", true));
          } else {
            safeResult.error("NO_LISTENER", "EventChannel listener not attached", null);
          }
        } else {
          safeResult.error("INIT_ERROR", "Lock manager not initialized", null);
        }
        break;
      case "addLockKeyStream":
        if (lockManager != null) {
          if (eventSink != null) {
            lockManager.addLockKeyStream((Map<String, Object>) call.arguments, new com.example.wise_apartment.utils.BleLockManager.AddLockKeyStreamCallback() {
              @Override
              public void onChunk(final Map<String, Object> chunkEvent) {
                new android.os.Handler(android.os.Looper.getMainLooper()).post(new Runnable() {
                  @Override
                  public void run() {
                    if (eventSink != null) eventSink.success(chunkEvent);
                  }
                });
              }

              @Override
              public void onDone(final Map<String, Object> doneEvent) {
                new android.os.Handler(android.os.Looper.getMainLooper()).post(new Runnable() {
                  @Override
                  public void run() {
                    if (eventSink != null) eventSink.success(doneEvent);
                  }
                });
              }

              @Override
              public void onError(final Map<String, Object> errorEvent) {
                new android.os.Handler(android.os.Looper.getMainLooper()).post(new Runnable() {
                  @Override
                  public void run() {
                    if (eventSink != null) {
                      eventSink.error(String.valueOf(errorEvent.get("code")), String.valueOf(errorEvent.get("message")), errorEvent);
                    }
                  }
                });
              }
            });
            safeResult.success(java.util.Collections.singletonMap("streaming", true));
          } else {
            // No event sink: fallback to non-streaming addLockKey
            lockManager.addLockKey((Map<String, Object>) call.arguments, safeResult);
          }
        } else {
          safeResult.error("INIT_ERROR", "Lock manager not initialized", null);
        }
        break;
      case "deleteLockKey":
        if (lockManager != null) {
          lockManager.deleteLockKey((Map<String, Object>) call.arguments, safeResult);
        } else {
          safeResult.error("INIT_ERROR", "Lock manager not initialized", null);
        }
        break;
      case "syncLockKey":
        if (lockManager != null) {
          // Use streaming version if EventSink is available
          if (eventSink != null) {
            lockManager.syncLockKeyStream((Map<String, Object>) call.arguments, new BleLockManager.SyncLockKeyStreamCallback() {
              @Override
              public void onChunk(final Map<String, Object> chunkEvent) {
                new android.os.Handler(android.os.Looper.getMainLooper()).post(new Runnable() {
                  @Override
                  public void run() {
                    if (eventSink != null) {
                      eventSink.success(chunkEvent);
                    }
                  }
                });
              }

              @Override
              public void onDone(final Map<String, Object> doneEvent) {
                new android.os.Handler(android.os.Looper.getMainLooper()).post(new Runnable() {
                  @Override
                  public void run() {
                    if (eventSink != null) {
                      eventSink.success(doneEvent);
                    }
                  }
                });
              }

              @Override
              public void onError(final Map<String, Object> errorEvent) {
                new android.os.Handler(android.os.Looper.getMainLooper()).post(new Runnable() {
                  @Override
                  public void run() {
                    if (eventSink != null) {
                      eventSink.error(
                        String.valueOf(errorEvent.get("code")),
                        String.valueOf(errorEvent.get("message")),
                        errorEvent
                      );
                    }
                  }
                });
              }
            });
            // Return immediately - results come via EventChannel
            safeResult.success(null);
          } else {
            // Fallback to old non-streaming version
            lockManager.syncLockKey((Map<String, Object>) call.arguments, safeResult);
          }
        } else {
          safeResult.error("INIT_ERROR", "Lock manager not initialized", null);
        }
        break;
      case "syncLockTime":
        if (lockManager != null) {
          lockManager.syncLockTime((Map<String, Object>) call.arguments, safeResult);
        } else {
          safeResult.error("INIT_ERROR", "Lock manager not initialized", null);
        }
        break;
      case "getSysParam":
        if (lockManager != null) {
          lockManager.getSysParam((Map<String, Object>) call.arguments, safeResult);
        } else {
          safeResult.error("INIT_ERROR", "Lock manager not initialized", null);
        }
        break;
      case "enableDisableKeyByType":
      case "enableLockKey":
        if (lockManager != null) {
          lockManager.enableDisableKeyByType((Map<String, Object>) call.arguments, safeResult);
        } else {
          safeResult.error("INIT_ERROR", "Lock manager not initialized", null);
        }
        break;
      case "getSysParamStream":
        if (lockManager != null) {
          if (eventSink != null) {
            lockManager.getSysParamStream((Map<String, Object>) call.arguments, new BleLockManager.SysParamStreamCallback() {
              @Override
              public void onData(final Map<String, Object> event) {
                new android.os.Handler(android.os.Looper.getMainLooper()).post(new Runnable() {
                  @Override
                  public void run() {
                    if (eventSink != null) eventSink.success(event);
                  }
                });
              }

              @Override
              public void onDone(final Map<String, Object> event) {
                new android.os.Handler(android.os.Looper.getMainLooper()).post(new Runnable() {
                  @Override
                  public void run() {
                    if (eventSink != null) eventSink.success(event);
                  }
                });
              }

              @Override
              public void onError(final Map<String, Object> event) {
                new android.os.Handler(android.os.Looper.getMainLooper()).post(new Runnable() {
                  @Override
                  public void run() {
                    if (eventSink != null) eventSink.error(String.valueOf(event.get("code")), String.valueOf(event.get("message")), event);
                  }
                });
              }
            });
            safeResult.success(null);
          } else {
            safeResult.error("NO_LISTENER", "EventChannel listener not attached", null);
          }
        } else {
          safeResult.error("INIT_ERROR", "Lock manager not initialized", null);
        }
        break;
      case "exitCmd":
        if (bleClient != null) {
          try {
            BlinkyAction action = new BlinkyAction();
            action.setBaseAuthAction(PluginUtils.createAuthAction((Map<String, Object>) call.arguments));
            bleClient.abortCurrentCmd(action, new FunCallback() {
              @Override
              public void onResponse(Response response) {
                try {
                  Map<String, Object> details = new java.util.HashMap<>();
                  details.put("code", response == null ? -1 : response.code());
                  details.put("ackMessage", com.example.wise_apartment.utils.WiseStatusCode.description(response == null ? -1 : response.code()));
                  safeResult.success(details);
                } catch (Throwable t) {
                  safeResult.error("FAILED", "exitCmd response processing failed: " + t.getMessage(), null);
                }
              }

              @Override
              public void onFailure(Throwable t) {
                safeResult.error("ERROR", t.getMessage(), null);
              }
            });
          } catch (Throwable t) {
            Log.e(TAG, "exitCmd invocation failed", t);
            safeResult.error("ERROR", "exitCmd invocation failed: " + t.getMessage(), null);
          }
        } else {
          safeResult.error("INIT_ERROR", "BLE client not initialized", null);
        }
        break;
      default:
        safeResult.notImplemented();
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