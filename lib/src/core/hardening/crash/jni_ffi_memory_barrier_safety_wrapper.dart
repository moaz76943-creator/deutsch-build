/// Task 1095: JNI/FFI cross-boundary call safety wrapper
class FfiSafetyWrapper {
  T? guardCall<T>(T Function() call) {
    try {
      return call();
    } catch (_) {
      return null;
    }
  }
}
