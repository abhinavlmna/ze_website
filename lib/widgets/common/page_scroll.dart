import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Exposes the page's single [ScrollController] to any descendant, so
/// scroll-triggered widgets (reveal animations, parallax) can subscribe
/// without the whole page rebuilding.
class PageScroll extends InheritedWidget {
  const PageScroll({
    super.key,
    required this.controller,
    required this.offset,
    required super.child,
  });

  final ScrollController controller;

  /// Current pixel offset, published separately so widgets can listen to a
  /// cheap [ValueListenable] instead of the controller itself.
  final ValueListenable<double> offset;

  static PageScroll? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PageScroll>();

  @override
  bool updateShouldNotify(PageScroll oldWidget) =>
      oldWidget.controller != controller || oldWidget.offset != offset;
}
