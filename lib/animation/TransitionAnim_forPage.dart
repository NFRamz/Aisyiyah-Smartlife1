import 'package:flutter/material.dart';

class SlideRightPageRoute extends PageRouteBuilder {
  final Widget page;
  final Curve animasi;

  SlideRightPageRoute({
    required this.page,
    required this.animasi

  })
      : super(
    transitionDuration: const Duration(milliseconds: 1000),

    pageBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        ) =>
    page,

    transitionsBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child,
        ) {

      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      final curve = animasi;


      final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      final offsetAnimation = animation.drive(tween);


      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
  );
}
