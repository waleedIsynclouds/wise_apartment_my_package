# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Uncomment this to preserve the line number information for
# debugging stack traces.
#-keepattributes SourceFile,LineNumberTable

# If you keep the line number information, uncomment this to
# hide the original source file name.
#-renamesourcefileattribute SourceFile
-keep class com.example.hxjblinklibrary.** { *; }
-dontwarn com.example.hxjblinklibrary.**
# Suppress warnings for the generated plugin class
-dontwarn com.example.wise_apartment.WiseApartmentPlugin

# Keep plugin classes to avoid R8 stripping reflective/Flutter-registered code
-keep class com.example.wise_apartment.** { *; }

# Also suppress warnings for vendor package reported by R8 (missing_rules.txt)
-dontwarn om.example.hxjblinklibrary.**

# Specific missing class reported by R8
-dontwarn om.example.hxjblinklibrary.b.d
