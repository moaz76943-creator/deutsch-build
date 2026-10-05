abstract interface class StoryAudioPort {
  Future<bool> speak({
    required String text,
    required String conceptId,
  });
}

final class SilentStoryAudioPort implements StoryAudioPort {
  const SilentStoryAudioPort();

  @override
  Future<bool> speak({
    required String text,
    required String conceptId,
  }) async =>
      false;
}
