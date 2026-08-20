import 'package:flutter/material.dart';

class _FormContainer extends StatelessWidget {
  final Widget child;

  const _FormContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.zero,
      ),
      child: child,
    );
  }
}
