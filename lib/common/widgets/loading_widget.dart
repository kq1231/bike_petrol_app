import 'package:flutter/material.dart';

/// A reusable loading indicator widget.
/// 
/// ARCHITECTURE NOTE:
/// Having a centralized loading widget ensures consistency across your app.
/// If you later want to change the loading indicator style (e.g., use a custom
/// animation or different colors), you only need to change it in one place.
class LoadingWidget extends StatelessWidget {
  const LoadingWidget({
    super.key,
    this.message,
  });

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
