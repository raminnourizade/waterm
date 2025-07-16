plugins {
    id("com.android.application")
    id("kotlin-android")
    // Flutter plugin باید بعد از Kotlin و Android بیاد
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.water.waterm"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.water.waterm"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
            isDebuggable = false

            // غیرفعال کردن lint برای خروجی release
            lint {
                checkReleaseBuilds = false
                abortOnError = false
            }
        }
    }
}

flutter {
    source = "../.."
}
