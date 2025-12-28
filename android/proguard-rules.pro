# ProGuard rules for wise_apartment Android library
# Add custom rules below as needed

# Keep all classes in the library (customize as needed)
-keep class com.example.wise_apartment.** { *; }

# Add rules for third-party libraries if needed
# Example: Gson
-keep class com.google.gson.** { *; }
-keepattributes Signature
-keepattributes *Annotation*

# Add rules for Room (if used)
-keep class androidx.room.** { *; }
-keep class androidx.sqlite.** { *; }
-keepclassmembers class * {
    @androidx.room.* <methods>;
}

# Add rules for BLE libraries if needed
-keep class no.nordicsemi.android.** { *; }

# Add any additional rules below
