import 'package:flutter/material.dart';
import '../../architecture/operation_result.dart';

class ContentErrorState extends StatelessWidget {
  final Object error;
  final VoidCallback? onRetry;
  final bool compact;

  const ContentErrorState({
    super.key,
    required this.error,
    this.onRetry,
    this.compact = false,
  });

  String _getErrorMessage() {
    if (error is OperationFailure) {
      return (error as OperationFailure).message;
    }
    return 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.';
  }

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Center(
        child: IconButton(
          icon: Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
          onPressed: onRetry,
          tooltip: 'إعادة المحاولة',
        ),
      );
    }

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                _getErrorMessage(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.error,
                    ),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('إعادة المحاولة'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
