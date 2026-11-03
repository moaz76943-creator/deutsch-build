/// Task 1093: Asynchronous microtask stack stitcher for unhandled Futures
class AsyncStackStitcher {
  String stitch(StackTrace trace) => trace.toString().split('\n').take(5).join(' | ');
}
