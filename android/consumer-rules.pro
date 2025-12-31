-keep class com.example.hxjblinklibrary.** { *; }
-dontwarn com.example.hxjblinklibrary.**

# Extra safe rules: some vendor AARs use alternate package names or shading
# Add these to avoid R8 warnings or stripping when consumer app minifies.
# Note: logs sometimes reference a misspelled package `com.example.hxlibraray` or
# a missing-leading-char `om.example...` — include both variants defensively.
-keep class com.example.hxlibraray.** { *; }
-dontwarn com.example.hxlibraray.**
-dontwarn om.example.hxjblinklibrary.**
-dontwarn om.example.hxlibraray.**
