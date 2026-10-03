import 'story_models.dart';

abstract interface class StoryRepository {
  Future<List<StoryItem>> listStories();
  Future<StoryItem?> getStory(String id);
}
