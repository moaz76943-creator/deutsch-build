import 'package:flutter/widgets.dart';

/// BidiFlexPair - Master Constitution Section 10 Compliant.
/// Prevents RenderFlex overflow across mixed LTR (German/English) and RTL (Arabic)
/// text pairs by employing adaptive flexible layouts and start/end directional alignment.
class BidiFlexPair extends StatelessWidget {
  final String sourceText;
  final String targetText;
  final TextStyle? sourceStyle;
  final TextStyle? targetStyle;
  final bool isTargetRtl;

  const BidiFlexPair({
    super.key,
    required this.sourceText,
    required this.targetText,
    this.sourceStyle,
    this.targetStyle,
    this.isTargetRtl = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext ctx, BoxConstraints constraints) {
        final isNarrow = constraints.maxWidth < 320;

        final sourceWidget = Text(
          sourceText,
          style: sourceStyle,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        );

        final targetWidget = Directionality(
          textDirection: isTargetRtl ? TextDirection.rtl : TextDirection.ltr,
          child: Text(
            targetText,
            style: targetStyle,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            textAlign: isTargetRtl ? TextAlign.right : TextAlign.left,
          ),
        );

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              sourceWidget,
              const SizedBox(height: 4),
              targetWidget,
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
              flex: 1,
              child: sourceWidget,
            ),
            const SizedBox(width: 8),
            Flexible(
              flex: 1,
              child: targetWidget,
            ),
          ],
        );
      },
    );
  }
}
