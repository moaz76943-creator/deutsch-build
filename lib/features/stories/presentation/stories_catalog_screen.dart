import 'package:flutter/material.dart';

import '../../../design_system/app_colors.dart';
import '../../../design_system/app_glass_card.dart';
import '../../../design_system/app_typography.dart';
import '../domain/story_models.dart';
import '../domain/story_repository.dart';

class StoriesCatalogScreen extends StatefulWidget {
  const StoriesCatalogScreen({
    required this.repository,
    required this.onOpenStory,
    this.completionByStoryId = const <String, double>{},
    super.key,
  });

  final StoryRepository repository;
  final ValueChanged<StoryItem> onOpenStory;
  final Map<String, double> completionByStoryId;

  @override
  State<StoriesCatalogScreen> createState() => _StoriesCatalogScreenState();
}

class _StoriesCatalogScreenState extends State<StoriesCatalogScreen> {
  late final Future<List<StoryItem>> _stories = widget.repository.listStories();

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: AppDirectionalText(
              'القصص المصغّرة',
              languageCode: 'ar',
              style: AppTypography.title,
            ),
          ),
          body: FutureBuilder<List<StoryItem>>(
            future: _stories,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: AppDirectionalText(
                    'تعذر تحميل القصص.',
                    languageCode: 'ar',
                    style: AppTypography.body,
                  ),
                );
              }

              final stories = snapshot.data ?? const <StoryItem>[];
              return ListView(
                padding: const EdgeInsets.all(18),
                children: <Widget>[
                  _header(),
                  const SizedBox(height: 18),
                  for (final level in StoryLevel.values) ...<Widget>[
                    _levelHeader(level),
                    const SizedBox(height: 10),
                    _storyGrid(
                      stories
                          .where((story) => story.level == level)
                          .toList(growable: false),
                    ),
                    const SizedBox(height: 18),
                  ],
                ],
              );
            },
          ),
        ),
      );

  Widget _header() => AppGlassCard(
        glowColor: AppColors.primary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              'اقرأ في سياق قصير',
              languageCode: 'ar',
              style: AppTypography.title,
            ),
            const SizedBox(height: 6),
            AppDirectionalText(
              'اضغط على الكلمات الألمانية المميزة لمعناها الفوري، '
              'ثم اختبر فهمك في نهاية القصة.',
              languageCode: 'ar',
              style: AppTypography.body,
            ),
          ],
        ),
      );

  Widget _levelHeader(StoryLevel level) => Row(
        children: <Widget>[
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.secondary.withAlpha(24),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              child: AppDirectionalText(
                level.label,
                languageCode: 'de',
                style: AppTypography.label.copyWith(
                  color: AppColors.secondary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          AppDirectionalText(
            'قصص المستوى',
            languageCode: 'ar',
            style: AppTypography.title,
          ),
        ],
      );

  Widget _storyGrid(List<StoryItem> stories) {
    if (stories.isEmpty) {
      return AppDirectionalText(
        'لا توجد قصص في هذا المستوى حالياً.',
        languageCode: 'ar',
        style: AppTypography.body,
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 250,
      ),
      itemCount: stories.length,
      itemBuilder: (context, index) {
        final story = stories[index];
        final completion = (widget.completionByStoryId[story.id] ?? 0)
            .clamp(0.0, 1.0)
            .toDouble();
        final accent = story.level == StoryLevel.a1
            ? AppColors.primary
            : AppColors.achievement;

        return AppGlassCard(
          onTap: () => widget.onOpenStory(story),
          borderColor: accent.withAlpha(105),
          glowColor: accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Align(
                alignment: Alignment.centerLeft,
                child: Icon(
                  _coverIcon(story.coverKey),
                  size: 34,
                  color: AppColors.secondary,
                ),
              ),
              const Spacer(),
              AppDirectionalText(
                story.titleGerman,
                languageCode: 'de',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.title.copyWith(fontSize: 17),
              ),
              const SizedBox(height: 4),
              AppDirectionalText(
                story.titleArabic,
                languageCode: 'ar',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.body,
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: completion,
                minHeight: 6,
                borderRadius: BorderRadius.circular(8),
              ),
              const SizedBox(height: 5),
              AppDirectionalText(
                'مكتمل ${(completion * 100).round()}%',
                languageCode: 'ar',
                style: AppTypography.label,
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _coverIcon(String key) => switch (key) {
        'coffee' => Icons.local_cafe_outlined,
        'transport' => Icons.directions_bus_outlined,
        _ => Icons.auto_stories_outlined,
      };
}
