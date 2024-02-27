import 'package:flutter/material.dart';

class ScaleRoute extends PageRouteBuilder {
  final Widget page;
  final int ms;
  ScaleRoute({this.page, this.ms}): super(pageBuilder: (BuildContext context, Animation<double> animation,Animation<double> secondaryAnimation,) =>
    page,
    transitionDuration: Duration(milliseconds: ms),
    transitionsBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child,) =>
        ScaleTransition(
          scale: Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(
            CurvedAnimation(
              parent: animation,
              //parent: AnimationController(vsync: context, duration: Duration(seconds: 3)),
              curve: Curves.fastOutSlowIn,
            ),
          ),
          child: child,
        ),
  );
}