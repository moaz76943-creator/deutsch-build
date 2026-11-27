package com.google.android.play.protections.annotations

/**
 * Describes that a method is a candidate for enhanced protection.
 * <p>This annotation will be removed automatically from the dex code of your
 * bundle at the time when Google Play protects your bundle. Only use it as
 * a method level annotation. Any other usage (e.g. accessing the class
 * reflectively at runtime) is unsupported.
 */
@Retention(AnnotationRetention.RUNTIME)
@Target(AnnotationTarget.FUNCTION)
annotation class PlayAutomaticIntegrityProtection(
    /**
     * If true, the annotated method will be loaded at startup. If false, it will
     * be loaded on demand.
     * <p>For on demand loading, calling the method will incur a performance
     * penalty. For startup loading, the method will remain deobfuscated in memory
     * for the lifetime of the app.
     */
    val loadAtStartup: Boolean = false
)
