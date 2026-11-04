# Flutter & Application Security Architecture
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.** { *; }

# الحفاظ على دوال وقواعد البيانات والـ Models
-keepattributes *Annotation*
-dontwarn io.flutter.embedding.**

<<<<<<< HEAD
# Native sqflite plugin: preserve its channel entry points and SQLite bridge.
-keep class com.tekartik.sqflite.** { *; }
<<<<<<< HEAD
-keep class com.deutschbilarabi.app.** { *; }
=======

# Flutter native registration, JNI entry points and asset lookup.
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }
-keep class io.flutter.embedding.engine.FlutterJNI { *; }
-keep class io.flutter.embedding.engine.loader.FlutterLoader { *; }
-keep class io.flutter.FlutterInjector { *; }

<<<<<<< HEAD
-keepattributes *Annotation*,Signature,InnerClasses,EnclosingMethod
-dontwarn io.flutter.embedding.**
-dontwarn io.flutter.**

# === Native / Plugin ===
-keep class com.tekartik.sqflite.** { *; }
-dontwarn com.tekartik.sqflite.**

# === App-specific: keep only public MethodChannel entry points; obfuscate private helpers ===
-keep class com.deutschbilarabi.app.MainActivity { *; }
-keep class com.deutschbilarabi.app.AndroidPlayIntegrityManager { *; }
-keep class com.deutschbilarabi.app.AndroidRootDetector { *; }
-keep class com.deutschbilarabi.app.AndroidSecureSessionStorage { *; }
-keep class com.deutschbilarabi.app.AndroidUserVaultCipher { *; }
-keep class com.deutschbilarabi.app.AndroidPackDatabaseKeyStore { *; }
-keep class com.deutschbilarabi.app.AndroidRecordedAudioPlayer { *; }

# Android Keystore / AES-GCM wrappers for offline DB keys and session storage.
-keep class com.deutschbilarabi.app.AndroidPackDatabaseKeyStore { *; }
-keep class com.deutschbilarabi.app.AndroidSecureSessionStorage { *; }

# java.security, javax.crypto, and java.util.zip.GZIP{Input,Output}Stream are
# Android platform classes: R8 cannot strip them. The app's crypto and archive
# packages (including GZIP) and SQLite/JSON schema models are Dart code, which
# is not obfuscated by Android R8. No platform or fictitious JVM keep rules needed.

# Optional Play Core APIs referenced by Flutter are not required for this APK.
-dontwarn com.google.android.play.core.**
>>>>>>> pr-179
=======
# تحسين وتقليص استهلاك الذاكرة
-repackageclasses
-allowaccessmodification
-overloadaggressively
-useuniqueclassmembernames

# Remove unused code more aggressively
-dontnote **
-ignorewarnings

# Optional future: add custom obfuscation dictionary
# -obfuscationdictionary dictionary.txt
# -classobfuscationdictionary dictionary.txt
# -packageobfuscationdictionary dictionary.txt
=======
-keepattributes *Annotation*
-dontwarn io.flutter.embedding.**
-dontwarn io.flutter.**

# Native sqflite plugin
-keep class com.tekartik.sqflite.** { *; }
-dontwarn com.tekartik.sqflite.**

# Method channels, Keystore wrappers, Play Integrity, and the voice probe.
-keep class com.deutschbilarabi.app.** { *; }

# Optional Play Core
-dontwarn com.google.android.play.core.**

# JNI and optional SQLCipher boundaries. The app keep above already covers
# the Kotlin channel classes; these names stay explicit for the release gate.
-keepclasseswithmembernames class * {
    native <methods>;
}
-keep class net.sqlcipher.** { *; }
-keep class net.zetetic.database.** { *; }
-dontwarn net.sqlcipher.**
-dontwarn net.zetetic.database.**
-keep class com.deutschbilarabi.app.AndroidRecordedAudioPlayer { *; }
-keep class com.deutschbilarabi.app.AndroidPronunciationSignalProbe { *; }
-keep class com.deutschbilarabi.app.AndroidPackDatabaseKeyStore { *; }
-keep class com.deutschbilarabi.app.AndroidSecureSessionStorage { *; }
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
}
