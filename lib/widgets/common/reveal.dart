import 'package:flutter/material.dart';

import '../../constants/breakpoints.dart';
import 'page_scroll.dart';

/// Fades and lifts its child into place the first time it scrolls into view.
///
/// Deliberately one-shot and one-way: the content settles and stays settled,
/// which reads as composure rather than as an effect. Honours the platform's
/// reduced-motion preference by rendering the final state immediately.
class Reveal extends StatefulWidget {
  const Reveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.distance = 34,
    this.duration = const Duration(milliseconds: 900),
    this.scale = 1,
  });

  final Widget child;
  final Duration delay;
  final double distance;
  final Duration duration;

  /// Optional starting scale, settling to 1. Left at its default the widget is
  /// a pure fade-and-lift and no scale layer is inserted at all — worth setting
  /// just under 1 for small tiles, where a lift on its own is too slight to
  /// read.
  final double scale;

  @override
  State<Reveal> createState() => _RevealState();
}

class _RevealState extends State<Reveal> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  ScrollController? _scroll;
  bool _triggered = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (context.reduceMotion) {
      _detach();
      _triggered = true;
      _controller.value = 1;
      return;
    }

    final scroll = PageScroll.maybeOf(context)?.controller;
    if (scroll == null) {
      // No page scroller (e.g. inside an overlay) — just show it.
      _triggered = true;
      _controller.value = 1;
      return;
    }
    if (!identical(scroll, _scroll)) {
      _scroll?.removeListener(_check);
      _scroll = scroll;
      if (!_triggered) scroll.addListener(_check);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  void _detach() {
    _scroll?.removeListener(_check);
    _scroll = null;
  }

  void _check() {
    if (_triggered || !mounted) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize || !box.attached) return;

    final top = box.localToGlobal(Offset.zero).dy;
    final viewport = MediaQuery.sizeOf(context).height;

    // Trigger a little before the element reaches the fold so the motion has
    // finished by the time it is fully in view.
    if (top < viewport * 0.9 && top > -box.size.height) {
      _triggered = true;
      _detach();
      if (widget.delay == Duration.zero) {
        _controller.forward();
      } else {
        Future<void>.delayed(widget.delay, () {
          if (mounted) _controller.forward();
        });
      }
    }
  }

  @override
  void dispose() {
    _detach();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final eased = Curves.easeOutCubic.transform(_controller.value);

        Widget moved = Transform.translate(
          offset: Offset(0, (1 - eased) * widget.distance),
          child: child,
        );

        if (widget.scale != 1) {
          moved = Transform.scale(
            scale: widget.scale + (1 - widget.scale) * eased,
            child: moved,
          );
        }

        return Opacity(
          opacity: Curves.easeOut.transform(_controller.value).clamp(0.0, 1.0),
          child: moved,
        );
      },
      child: widget.child,
    );
  }
}

/// Convenience for revealing a list of children one after another.
List<Widget> staggered(
  List<Widget> children, {
  Duration step = const Duration(milliseconds: 110),
  double distance = 34,
}) {
  return <Widget>[
    for (var i = 0; i < children.length; i++)
      Reveal(
        delay: step * i,
        distance: distance,
        child: children[i],
      ),
  ];
}
