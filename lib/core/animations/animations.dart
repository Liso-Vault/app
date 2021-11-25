import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:supercharged/supercharged.dart';

enum AnimationProps { opacity, translationX, translationY, scale }

class GridItemAnimation extends StatelessWidget {
  final Widget child;
  final double scale;

  const GridItemAnimation({
    Key? key,
    required this.child,
    this.scale = 0.5,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tween = MultiTween<AnimationProps>()
      ..add(AnimationProps.opacity, 0.0.tweenTo(1.0))
      ..add(
        AnimationProps.scale,
        scale.tweenTo(1.0),
      );

    return PlayAnimation<MultiTweenValues<AnimationProps>>(
      delay: 300.milliseconds,
      duration: 300.milliseconds,
      tween: tween,
      child: child,
      builder: (context, child, value) => Transform.scale(
        scale: value.get(AnimationProps.scale),
        child: Opacity(
          opacity: value.get(AnimationProps.opacity),
          child: child,
        ),
      ),
    );
  }
}

class ListItemAnimation extends StatelessWidget {
  final Widget child;
  final Axis axis;
  final Offset offset;
  final Duration delay, duration;

  const ListItemAnimation({
    Key? key,
    required this.child,
    this.axis = Axis.vertical,
    this.offset = const Offset(0.0, 50.0),
    this.delay = const Duration(milliseconds: 300),
    this.duration = const Duration(milliseconds: 300),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tween = MultiTween<AnimationProps>()
      ..add(AnimationProps.opacity, 0.0.tweenTo(1.0))
      ..add(AnimationProps.translationX, offset.dx.tweenTo(0.0))
      ..add(
        AnimationProps.translationY,
        offset.dy.tweenTo(0.0),
      );

    return PlayAnimation<MultiTweenValues<AnimationProps>>(
      delay: delay,
      duration: duration,
      tween: tween,
      child: child,
      builder: (context, child, value) {
        final horizontalOffset = value.get(AnimationProps.translationX);
        final verticalOffset = value.get(AnimationProps.translationY);

        return Transform.translate(
          offset: Offset(horizontalOffset, verticalOffset),
          child: Opacity(
            opacity: value.get(AnimationProps.opacity),
            child: child,
          ),
        );
      },
    );
  }
}
