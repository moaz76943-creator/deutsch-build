# Release R8 rules: keep only Android/JVM entry points that need stable names.
# Dart AOT code and bundled Flutter assets are outside R8's code-shrinking scope.

# Preserve metadata used by Java/Kotlin reflection and plugin integrations.
-keepattributes Signature,InnerClasses,EnclosingMethod,*Annotation*

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
