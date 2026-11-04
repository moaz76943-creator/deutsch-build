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
-dontwarn com.google.android.play.core.**
-dontwarn io.flutter.app.**
-keep class io.flutter.app.** { *; }

-dontwarn com.google.android.play.core.**
-dontwarn io.flutter.**
-keep class io.flutter.** { *; }
-dontwarn com.tekartik.sqflite.**
-keep class com.tekartik.sqflite.** { *; }
>>>>>>> origin/staging/v2-full-platform-1792367411258400957
