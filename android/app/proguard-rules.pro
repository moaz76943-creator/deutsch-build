# Flutter & Application Security Architecture
# Optimized for high protection against reverse engineering, modding, and data theft
# Compatible with Google Play Automatic Integrity Protection + Play Integrity API
# Enhanced R8 rules: aggressive obfuscation of internals while preserving Flutter and MethodChannel surfaces

# === Flutter Core (required – do not remove) ===
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }
-keep class io.flutter.embedding.engine.FlutterJNI { *; }
-keep class io.flutter.embedding.engine.loader.FlutterLoader { *; }
-keep class io.flutter.FlutterInjector { *; }

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
-keep class com.deutschbilarabi.app.AndroidGamificationClockIntegritySource { *; }
-keep class com.deutschbilarabi.app.AndroidPronunciationSignalProbe { *; }
-keep class com.deutschbilarabi.app.AndroidOfflineVoiceCapabilityProbe { *; }

-keepclassmembers class com.deutschbilarabi.app.** {
    public <methods>;
}

# Obfuscate remaining internal classes and methods
-keepclassmembers class * {
    native <methods>;
}

# === Play Integrity & Security Libraries ===
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.integrity.** { *; }

# === EncryptedSharedPreferences / security-crypto ===
-keep class androidx.security.crypto.** { *; }
-dontwarn androidx.security.crypto.**
-keep class com.google.crypto.tink.** { *; }
-dontwarn com.google.crypto.tink.**

# === Strip debug logs in release (reduces info leakage) ===
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
    public static *** w(...);
    public static *** e(...);
}

# === Additional hardening for reverse-engineering resistance ===
-optimizationpasses 5
-dontusemixedcaseclassnames
-dontskipnonpubliclibraryclasses
-verbose
-repackageclasses ''
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
