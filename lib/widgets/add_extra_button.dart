import 'package:flutter/material.dart';

class AddExtraButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const AddExtraButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.tonal(
        onPressed: onPressed, //showExtraDialog('Lisuke'),
        style: FilledButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.inversePrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: BorderSide(
              width: 1,
              color: Theme.of(context).colorScheme.onInverseSurface,
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),
        child: const Text('+', style: TextStyle(fontSize: 30)),
      ),
    );
  }
}
