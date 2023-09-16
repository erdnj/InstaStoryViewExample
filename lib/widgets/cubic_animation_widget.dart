import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

double degToRad(num deg) => deg * (pi / 180.0);

//Cubic transition widget, transform its child while pageview is scrooling the pages
class CubicAnimationWidget extends StatelessWidget {
  final int index;
  final PageController pageController;
  final Widget child;
  
  const CubicAnimationWidget(
      {required this.index,
      required this.pageController,
      required this.child,
      super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pageController,
      builder: (context, child) {
        final pageNotifierValue = pageController.page!;
        final isLeaving = (index - pageNotifierValue) <= 0;
        final t = (index - pageNotifierValue);
        final rotationY = lerpDouble(0, 90, t)!;
        final opacity = lerpDouble(0, 1, t.abs())!.clamp(0.0, 1.0);
        final transform = Matrix4.identity()
          ..setEntry(3, 2, 0.002)
          ..rotateY(-degToRad(rotationY));
        return Transform(
          alignment: isLeaving ? Alignment.centerRight : Alignment.centerLeft,
          transform: transform,
          child: Stack(
            children: [
              child!,
              Positioned.fill(
                child: Opacity(
                  opacity: opacity,
                  child: const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        );
      },
      child: child,
    );
  }
}
