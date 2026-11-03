/// Task 1084: Native signal emergency sync flush handler
class NativeSignalInterceptor {
  bool signalHandled = false;
  void onNativeSignal(int sig) => signalHandled = true;
}
