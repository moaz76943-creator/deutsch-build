import '../services/app_dependencies.dart';

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/content_contract.dart';
import '../core/learning_core.dart';
import '../core/view_mode.dart';
import '../core/srs_facets.dart';
import '../features/session/universal_session_orchestrator.dart';
import '../language/language_content_intelligence.dart';
import '../language/language_content_quality.dart';
import '../language/language_exercise_strategy.dart';
import '../language/language_presentation.dart';
import '../language/language_text_normalizer.dart';
import '../models/assessment.dart';
import '../models/content.dart';
import '../models/learner.dart';
import '../models/learning_path.dart';
import '../services/assessment_engine.dart';
import '../services/content_depth.dart';
import '../services/learning_engine.dart';
import '../services/repository.dart';
import '../services/subscription.dart';
import '../services/ui_preferences.dart';
import 'account_pages.dart';
import 'safe_ui.dart';

part 'learning/core_session.dart';
part 'learning/vocabulary_page.dart';
part 'learning/single_item_session.dart';
part 'learning/smart_assessment.dart';
