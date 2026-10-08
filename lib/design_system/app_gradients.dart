import 'package:flutter/material.dart';

abstract final class AppGradients {
  static const LinearGradient heroSunset = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[
      Color(0xFF0B1F4D),
      Color(0xFF355CBE),
      Color(0xFFAA5EBC),
      Color(0xFFF39C6B),
    ],
    stops: <double>[0.0, 0.34, 0.72, 1.0],
  );

  static const LinearGradient deepOcean = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[
      Color(0xFF0D1B3A),
      Color(0xFF133E87),
      Color(0xFF1E5EFF),
    ],
  );

  static const LinearGradient blueCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[
      Color(0xFF1D4ED8),
      Color(0xFF3B82F6),
      Color(0xFF60A5FA),
    ],
  );

  static const LinearGradient greenCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[
      Color(0xFF0F766E),
      Color(0xFF10B981),
      Color(0xFF6EE7B7),
    ],
  );

  static const LinearGradient purpleCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[
      Color(0xFF6D28D9),
      Color(0xFF8B5CF6),
      Color(0xFFC084FC),
    ],
  );

  static const LinearGradient pinkCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[
      Color(0xFFDB2777),
      Color(0xFFEC4899),
      Color(0xFFF9A8D4),
    ],
  );

  static const LinearGradient darkScaffold = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[
      Color(0xFF081325),
      Color(0xFF0C1E3C),
      Color(0xFF12284A),
    ],
  );

  static const LinearGradient navBarGlass = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[
      Color(0xCC13284F),
      Color(0xAA1F3C72),
    ],
  );
}
