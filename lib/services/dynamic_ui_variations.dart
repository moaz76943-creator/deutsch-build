import 'package:flutter/material.dart';
import 'package:sqflite_common/sqlite_api.dart';

import 'sqlite_policy.dart';

import 'dart:math';

class DynamicUiVariationsEngine {
  static const String _tableName = 'ui_variations';
  static const String _columnId = 'id';
  static const String _columnDate = 'last_date';
  static const String _columnSeed = 'current_seed';

  static final DynamicUiVariationsEngine instance =
      DynamicUiVariationsEngine._init();
  static Database? _database;
  static const AppSqlitePolicy _sqlitePolicy = AppSqlitePolicy();

  DynamicUiVariationsEngine._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('dynamic_ui.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final path = await _sqlitePolicy.resolvePath(fileName: filePath);
    return _sqlitePolicy.openWritable(
      path: path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        $_columnId TEXT PRIMARY KEY,
        $_columnDate TEXT NOT NULL,
        $_columnSeed INTEGER NOT NULL
      )
    ''');
  }

  Future<int> getDailySeed() async {
    final db = await instance.database;
    final now = DateTime.now();
    final today =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    final maps = await db.query(
      _tableName,
      where: '$_columnId = ?',
      whereArgs: ['daily_variation'],
    );

    if (maps.isEmpty) {
      final newSeed = Random().nextInt(360);
      await db.insert(_tableName, {
        _columnId: 'daily_variation',
        _columnDate: today,
        _columnSeed: newSeed,
      });
      return newSeed;
    } else {
      final lastDate = maps.first[_columnDate] as String;
      if (lastDate != today) {
        final newSeed = Random().nextInt(360);
        await db.update(
          _tableName,
          {_columnDate: today, _columnSeed: newSeed},
          where: '$_columnId = ?',
          whereArgs: ['daily_variation'],
        );
        return newSeed;
      } else {
        return maps.first[_columnSeed] as int;
      }
    }
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}

class DynamicUiVariationHelpers {
  static Color getRotatedSeedColor(int seed) {
    const baseColor = Colors.indigo; // Base theme seed color
    final hsl = HSLColor.fromColor(baseColor);
    final rotatedHsl = hsl.withHue((hsl.hue + (seed % 30) - 15) % 360);
    return rotatedHsl.toColor();
  }

  static List<Color> getGradientColors(int seed, bool isDark) {
    final base = getRotatedSeedColor(seed);
    final hsl = HSLColor.fromColor(base);

    final lightnessAdjustment = isDark ? -0.05 : 0.05;

    final color1 = hsl
        .withLightness((hsl.lightness + lightnessAdjustment).clamp(0.0, 1.0))
        .withAlpha(0.05)
        .toColor();
    final color2 = hsl
        .withHue((hsl.hue + 10) % 360)
        .withLightness((hsl.lightness - lightnessAdjustment).clamp(0.0, 1.0))
        .withAlpha(0.02)
        .toColor();

    return [color1, color2];
  }

  static Alignment getGradientBegin(int seed) {
    final values = [Alignment.topLeft, Alignment.topRight, Alignment.topCenter];
    return values[seed % values.length];
  }

  static Alignment getGradientEnd(int seed) {
    final values = [
      Alignment.bottomRight,
      Alignment.bottomLeft,
      Alignment.bottomCenter,
    ];
    return values[seed % values.length];
  }

  static Duration getMicroAnimationDuration(int seed) {
    // Variations between 300ms and 800ms
    final milliseconds = 300 + (seed % 500);
    return Duration(milliseconds: milliseconds);
  }
}
