import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties().apply {
    if (keystorePropertiesFile.exists()) {
        load(FileInputStream(keystorePropertiesFile))
    }
}
val releaseStorePath = keystoreProperties.getProperty("storeFile")
val releaseSigningReady =
    !releaseStorePath.isNullOrBlank() &&
        !keystoreProperties.getProperty("storePassword").isNullOrBlank() &&
        !keystoreProperties.getProperty("keyAlias").isNullOrBlank() &&
        !keystoreProperties.getProperty("keyPassword").isNullOrBlank() &&
        rootProject.file(releaseStorePath).isFile
val releaseRequested = gradle.startParameter.taskNames.any {
    it.contains("release", ignoreCase = true)
}

if (releaseRequested && !releaseSigningReady) {
    throw GradleException(
        "Release signing is not configured. Copy android/key.properties.example " +
            "to android/key.properties and point it at the protected release keystore.",
    )
}

android {
    namespace = "com.example.astraea"
    // amberflutter pulls in newer androidx libraries (e.g. core-ktx 1.18.0)
    // that require the consuming app to compile against SDK 36. Pin explicitly
    // rather than relying on flutter's default.
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // Required by flutter_local_notifications (it uses java.time APIs
        // that must be desugared to run on older Android API levels).
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        // Stable install identity from before the Astraea rename. Changing it
        // would install a second app and strand existing encrypted/local data.
        applicationId = "com.example.epochs"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (releaseSigningReady) {
            create("release") {
                storeFile = rootProject.file(releaseStorePath!!)
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            // AGP 9 shrinks/obfuscates release builds by default; without an
            // explicit proguard-rules.pro, R8 breaks WorkManager's reflective
            // Room database lookup (see proguard-rules.pro) and the app
            // crashes on launch. isMinifyEnabled is set explicitly here so
            // that's not implicit.
            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
            // Never fall back to the debug identity for a distributable build.
            if (releaseSigningReady) {
                signingConfig = signingConfigs.getByName("release")
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Backport of java.time (and other Java 8+ APIs) so
    // flutter_local_notifications' zonedSchedule() works on all supported
    // Android versions — see isCoreLibraryDesugaringEnabled above.
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
