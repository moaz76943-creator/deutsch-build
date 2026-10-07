import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SmartCopyButton extends StatefulWidget {
  final String textToCopy;
  final String? label; // عنوان الكلمة ليظهر في التنبيه مثل "تم نسخ الكلمة"
  final Color? iconColor;
  final double iconSize;

  const SmartCopyButton({
    super.key,
    required this.textToCopy,
    this.label,
    this.iconColor,
    this.iconSize = 22.0,
  });

  @override
  State<SmartCopyButton> createState() => _SmartCopyButtonState();
}

class _SmartCopyButtonState extends State<SmartCopyButton> {
  bool _copied = false;

  Future<void> _handleCopy() async {
    if (widget.textToCopy.trim().isEmpty) return;

    // نسخ النص إلى الحافظة
    await Clipboard.setData(ClipboardData(text: widget.textToCopy.trim()));
    
    // اهتزاز لمسي خفيف للتأكيد
    HapticFeedback.lightImpact();

    if (!mounted) return;

    setState(() => _copied = true);

    // إظهار تنبيه أنيق أسفل الشاشة
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.label != null 
                    ? 'تم نسخ: "${widget.label}"' 
                    : 'تم نسخ النص إلى الحافظة',
                style: const TextStyle(fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );

    // إعادة الأيقونة لحالتها الطبيعية بعد ثانية ونصف
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      setState(() => _copied = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
      child: IconButton(
        key: ValueKey<bool>(_copied),
        tooltip: 'نسخ إلى الحافظة',
        iconSize: widget.iconSize,
        icon: Icon(
          _copied ? Icons.check_circle_rounded : Icons.copy_rounded,
          color: _copied ? Colors.green : (widget.iconColor ?? Colors.grey.shade700),
        ),
        onPressed: _copied ? null : _handleCopy,
      ),
    );
  }
}
