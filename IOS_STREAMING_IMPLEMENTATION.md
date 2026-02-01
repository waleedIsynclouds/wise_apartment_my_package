# iOS Streaming Implementation for syncLockKey

## Overview
Implemented streaming support for `syncLockKey` on iOS to match the Android implementation. This allows real-time key synchronization updates to be sent to Flutter as they arrive from the BLE SDK.

## Changes Made

### 1. Event Channel Name Update
**File:** `ios/Classes/WiseApartmentPlugin.m`
- Updated event channel name from `wise_apartment/events` to `wise_apartment/ble_events`
- This matches the Android implementation and Dart side expectations

### 2. Protocol Definition
**File:** `ios/Classes/Managers/BleLockManager.h`
- Added `SyncLockKeyStreamDelegate` protocol with three methods:
  - `onChunk:` - Called for each key received
  - `onDone:` - Called when sync completes successfully
  - `onError:` - Called when an error occurs

### 3. Streaming Method Implementation
**File:** `ios/Classes/Managers/BleLockManager.m`
- Added `syncLockKeyStream:delegate:` method
- Features:
  - Accumulates all keys in `allKeys` array
  - Emits chunk event for each key received with:
    - `type`: "syncLockKeyChunk"
    - `item`: Single key data
    - `keyNum`: Key number
    - `totalSoFar`: Count of keys received so far
    - `isMore`: Boolean indicating if more keys are coming
  - Closes stream when `moreData` is false
  - Emits done event with all accumulated keys
  - Automatically disconnects BLE after completion/error
  - Thread-safe with `streamClosed` flag to prevent duplicate emissions

### 4. Plugin Integration
**File:** `ios/Classes/WiseApartmentPlugin.m`
- Modified `handleSyncLockKey:result:` to check for active event listener
- If listener is active, uses streaming version via `syncLockKeyStream:delegate:`
- If no listener, falls back to original `synclockkeys:result:` method
- Added `SyncLockKeyStreamDelegateImpl` class that forwards events to `WAEventEmitter`

### 5. Event Flow
```
BLE SDK → syncLockKeyStream → SyncLockKeyStreamDelegateImpl → WAEventEmitter → Flutter EventChannel
```

## Key Features

### Safe Stream Closure
- Stream closes automatically when `moreData` is false (no more keys)
- `streamClosed` flag prevents duplicate done/error emissions
- BLE disconnects safely after stream closes

### Event Types
1. **syncLockKeyChunk**: Emitted for each key
   - Contains single key data, key number, total so far, and isMore flag
   
2. **syncLockKeyDone**: Emitted when all keys are received
   - Contains array of all keys and total count
   
3. **syncLockKeyError**: Emitted on errors
   - Contains error message and status code

### Error Handling
- All operations wrapped in @try/@catch blocks
- Errors emit syncLockKeyError events with details
- BLE disconnects on errors to clean up resources
- Exception-safe disconnect operations

## Compatibility
- Backward compatible: Falls back to non-streaming version if no event listener
- Matches Android implementation behavior
- Uses same event channel name and event structure as Android
- Flutter side requires no changes (already implemented for Android)

## Testing
To test the streaming implementation:
1. Ensure Flutter app subscribes to `syncLockKeyStream` before calling `syncLockKey`
2. Monitor console logs for stream events:
   - "syncLockKeyStream called"
   - "Emitting chunk - key: X, isMore: Y"
   - "No more data - closing stream"
3. Verify all keys are received in Flutter UI
4. Confirm BLE disconnects after completion

## Notes
- iOS SDK uses `HXBluetoothLockHelper.getKeyListWithLockMac` which provides `moreData` flag
- Each callback receives one `HXKeyModel` object
- Stream closes when `moreData` is false
- Uses existing `WAEventEmitter` for thread-safe event delivery to Flutter
