import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val signingProperties = Properties()
val signingPropertiesFile = rootProject.file("key.properties")
if (signingPropertiesFile.exists()) {
    signingProperties.load(FileInputStream(signingPropertiesFile))
}

fun signingProperty(name: String): String =
    signingProperties.getProperty(name)?.trim().orEmpty()

val hasUploadSigning = listOf(
    "storeFile",
    "storePassword",
    "keyAlias",
    "keyPassword",
).all { signingProperty(it).isNotEmpty() }

// Checking the resolved graph, rather than only the command-line task name,
// also covers umbrella commands such as `assemble` that include a release
// variant alongside debug.
gradle.taskGraph.whenReady {
    val releaseTaskSelected = allTasks.any {
        it.name.contains("release", ignoreCase = true)
    }
    if (releaseTaskSelected && !hasUploadSigning) {
        throw GradleException(
            "Release AAB requires standalone upload signing. " +
                "Provide android/key.properties with storeFile, storePassword, " +
                "keyAlias, and keyPassword.",
        )
    }
}

android {
    namespace = "com.zmilastudio.kelimeavi"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    signingConfigs {
        if (hasUploadSigning) {
            create("upload") {
                keyAlias = signingProperty("keyAlias")
                keyPassword = signingProperty("keyPassword")
                // key.properties lives in android/, so relative store paths use
                // that directory as their stable base in both local and CI builds.
                storeFile = rootProject.file(signingProperty("storeFile"))
                storePassword = signingProperty("storePassword")
            }
        }
    }

    defaultConfig {
        applicationId = "com.zmilastudio.kelimeavi"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Closed-test candidates must use an owner-provisioned upload key.
            // There is intentionally no debug-key fallback for release builds.
            if (hasUploadSigning) {
                signingConfig = signingConfigs.getByName("upload")
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
