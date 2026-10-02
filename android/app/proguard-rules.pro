# Deutsch بالعربي production R8 hardening.
#
# Keep rules are deliberately narrow. The release build stays minified and
# obfuscated while preserving only reflection/JNI/native bridge boundaries.

# Flutter/Android may inspect runtime annotations and generic signatures.
-keepattributes RuntimeVisibleAnnotations,RuntimeInvisibleAnnotations,AnnotationDefault,Signature,InnerClasses,EnclosingMethod

# Preserve any native method names used through JNI.
-keepclasseswithmembernames,includedescriptorclasses class * {
    native <methods>;
}

# Respect AndroidX @Keep contracts from plugins/platform code.
-keep @androidx.annotation.Keep class * { *; }
-keepclassmembers class * {
    @androidx.annotation.Keep *;
}

# SQLCipher native/reflection boundaries (Phase 7).
-keep,includedescriptorclasses class net.sqlcipher.** { *; }
-keep,includedescriptorclasses interface net.sqlcipher.** { *; }
-keep,includedescriptorclasses class net.zetetic.database.** { *; }
-keep,includedescriptorclasses interface net.zetetic.database.** { *; }

# Project platform channels/native audio + secure-storage bridges.
-keep class com.deutschbilarabi.app.MainActivity { *; }
-keep class com.deutschbilarabi.app.AndroidPackDatabaseKeyStore { *; }
-keep class com.deutschbilarabi.app.AndroidSecureSessionStorage { *; }
-keep class com.deutschbilarabi.app.AndroidRecordedAudioPlayer { *; }
-keep class com.deutschbilarabi.app.AndroidPronunciationSignalProbe { *; }

# Release artifacts must not retain Android debug/log calls, including logs
# emitted by generated plugin registrants.
-assumenosideeffects class android.util.Log {
    public static *** v(...);
    public static *** d(...);
    public static *** i(...);
    public static *** w(...);
    public static *** e(...);
    public static *** wtf(...);
}
