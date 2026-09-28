import java.io.FileInputStream
import java.security.KeyStore
import java.security.MessageDigest
import java.util.Properties

plugins {
    id("com.google.gms.google-services")
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}
val hasReleaseKeystore =
    keystorePropertiesFile.exists() &&
    listOf("keyAlias", "keyPassword", "storeFile", "storePassword")
        .all(keystoreProperties::containsKey)

val adMobEnvironment =
    providers.gradleProperty("ADMOB_ENVIRONMENT").orNull ?: "test"
val adMobTestAppId = "ca-app-pub-3940256099942544~3347511713"
val adMobProductionAppId = "ca-app-pub-7452194004008791~7046504043"
val expectedProductionSigningSha1 =
    "000EE43F410ABC6B4F634C4F716D76EB19084115"

if (adMobEnvironment !in setOf("test", "production")) {
    throw GradleException(
        "ADMOB_ENVIRONMENT must be either 'test' or 'production'.",
    )
}

fun releaseSigningSha1(): String? {
    if (!hasReleaseKeystore) return null
    val storeFileName = keystoreProperties["storeFile"] as String
    val storePassword = keystoreProperties["storePassword"] as String
    val keyAlias = keystoreProperties["keyAlias"] as String
    val keyStore =
        KeyStore.getInstance(
            file(storeFileName),
            storePassword.toCharArray(),
        )
    val certificate = keyStore.getCertificate(keyAlias) ?: return null
    return MessageDigest.getInstance("SHA-1")
        .digest(certificate.encoded)
        .joinToString("") { byte -> "%02X".format(byte) }
}

val useProductionAds = adMobEnvironment == "production"
if (useProductionAds) {
    if (!hasReleaseKeystore) {
        throw GradleException(
            "Production AdMob requires the permanent release keystore.",
        )
    }
    val signingSha1 = releaseSigningSha1()
    if (signingSha1 != expectedProductionSigningSha1) {
        throw GradleException(
            "Production AdMob requires signing certificate SHA-1 " +
                expectedProductionSigningSha1,
        )
    }
}

android {
    namespace = "com.leventua.bilgirotasi"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    signingConfigs {
        if (hasReleaseKeystore) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = keystoreProperties["storeFile"]?.let { file(it) }
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.leventua.bilgirotasi"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["admobAppId"] = adMobTestAppId
    }

    buildTypes {
        debug {
            manifestPlaceholders["admobAppId"] = adMobTestAppId
        }
        release {
            manifestPlaceholders["admobAppId"] =
                if (useProductionAds) {
                    adMobProductionAppId
                } else {
                    adMobTestAppId
                }
            signingConfig =
                if (hasReleaseKeystore) {
                    signingConfigs.getByName("release")
                } else {
                    null
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
    // Google Mobile Ads 25.3.0 still declares WorkManager 2.7.0, which pulls
    // Room 2.2.5 and crashes while creating WorkDatabase on Android 16.
    // Keep the transitive API, but resolve it to the Android 16-compatible
    // stable WorkManager line.
    implementation("androidx.work:work-runtime:2.12.0")
}
