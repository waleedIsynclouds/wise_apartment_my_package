# Frameworks Directory

## HXJBLESDK.framework Setup

This directory should contain the HXJBLESDK.framework file.

### Installation Steps:

1. **Obtain HXJBLESDK.framework**
   - Get the HXJBLESDK.framework file from your SDK provider
   - Ensure you have version 2.5.0 or compatible

2. **Add Framework to Project**
   - Drag and drop `HXJBLESDK.framework` into this `ios/Frameworks/` directory
   - The framework should be embedded automatically via the podspec configuration

3. **Verify Integration**
   ```bash
   cd example/ios
   pod install
   ```

### Expected Structure:
```
ios/
├── Frameworks/
│   └── HXJBLESDK.framework/
│       ├── HXJBLESDK (binary)
│       ├── Headers/
│       ├── Info.plist
│       └── Modules/
```

### Framework Configuration:

The `wise_apartment.podspec` is already configured to:
- ✅ Link CoreBluetooth.framework (system framework)
- ✅ Link HXJBLESDK.framework (vendored framework)
- ✅ Add framework to Embedded Binaries
- ✅ Configure proper linker flags
- ✅ Set framework search paths

### Xcode Project Settings (Automatic via CocoaPods):

When you run `pod install`, the following will be configured automatically:

**Target → General → Frameworks, Libraries, and Embedded Content:**
- CoreBluetooth.framework (Do Not Embed)
- HXJBLESDK.framework (Embed & Sign)

**Target → Build Phases → Embed Frameworks:**
- HXJBLESDK.framework will be added with "Code Sign On Copy" enabled

**Target → Build Settings:**
- Framework Search Paths: Will include `$(PODS_ROOT)/../Frameworks`
- Other Linker Flags: `-framework HXJBLESDK -framework CoreBluetooth`

### Troubleshooting:

If you encounter issues:

1. **Clean Build Folder**: Product → Clean Build Folder (Cmd+Shift+K)
2. **Reinstall Pods**:
   ```bash
   cd example/ios
   rm -rf Pods Podfile.lock
   pod install
   ```
3. **Verify Framework**: Check that HXJBLESDK.framework is in `ios/Frameworks/`
4. **Check Xcode Version**: Ensure Xcode 12.2+ for proper framework embedding

### Manual Setup (if needed):

If automatic configuration doesn't work:

1. Open `example/ios/Runner.xcworkspace` in Xcode
2. Select Runner target
3. Go to **General** tab
4. Under **Frameworks, Libraries, and Embedded Content**:
   - Add CoreBluetooth.framework (select "Do Not Embed")
   - Add HXJBLESDK.framework (select "Embed & Sign")
5. Go to **Build Phases** tab
6. Verify **Embed Frameworks** section contains HXJBLESDK.framework

### Info.plist Permissions:

Already configured in `example/ios/Runner/Info.plist`:
```xml
<key>NSBluetoothPeripheralUsageDescription</key>
<string>Used to add Bluetooth lock</string>
<key>NSBluetoothAlwaysUsageDescription</key>
<string>Used to add Bluetooth lock</string>
```

---

**Status**: Ready for HXJBLESDK.framework installation
**Next Step**: Place HXJBLESDK.framework in this directory and run `pod install`
