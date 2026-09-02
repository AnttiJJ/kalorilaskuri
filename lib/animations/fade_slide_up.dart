import 'package:flutter/material.dart';

class FadeSlideUp extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const FadeSlideUp({
    super.key,
    required this.child,
    this.delay = Duration.zero,
  });

  @override
  State<FadeSlideUp> createState() => _FadeSlideUpState();
}

class _FadeSlideUpState extends State<FadeSlideUp>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1.50),
          end: Offset.zero,
        ).animate(animation),
        child: widget.child,
      ),
    );
  }
}
