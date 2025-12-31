plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.wise_apartment_example"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }
    buildFeatures {
        viewBinding = true
        dataBinding = true
    }
    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.wise_apartment_example"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        multiDexEnabled = true
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
    
    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Optionally, if you need to use the vendor SDK directly in the example app:
    // implementation("com.hxj:ble:2.5.0")
    // Or, if you only use the plugin, you may omit this.

    // Example should not bundle vendor AARs directly when the plugin provides them.
    // To use vendor SDK classes directly in the example, depend on published coordinates
    // after running the plugin publish task. Example (optional):
    implementation("com.hxj.vendor:hxjblinklibrary:2.5.0")

    // If you depend on additional vendor modules (DFU, platform-specific), add them here:
    // implementation("com.hxj.vendor:bleoad:1.0.0")
    // implementation("com.hxj.vendor:dfu:1.0.0")

     
     // Brings the new BluetoothLeScanner API to older platforms
    implementation("no.nordicsemi.android.support.v18:scanner:1.6.0")
    // Log Bluetooth LE events in nRF Logger
    implementation("no.nordicsemi.android:log:2.5.0")
    // BLE library
    //implementation("no.nordicsemi.android:ble:2.2.4")
    implementation("no.nordicsemi.android:ble:2.11.0")
}
