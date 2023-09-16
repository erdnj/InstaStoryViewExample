import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram_story_case_1/cubit/story_bucket_cubit.dart';
import 'package:instagram_story_case_1/cubit/story_head_cubit.dart';

class GestureBehaviorer extends StatelessWidget {
  const GestureBehaviorer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final pageController = context.read<PageController>();
    final width = MediaQuery.sizeOf(context).width;
    final headCubit = context.read<StoryHeadCubit>();
    final bucketCubit = context.read<StoryBucketCubit>();

    checkOn() => headCubit.indexCurrentBucket != bucketCubit.indexBucket;

    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        if (checkOn()) return;
        slideUpdateAction(pageController, details);
      },
      onHorizontalDragEnd: (details) {
        if (checkOn()) return;
        slideEndAction2(pageController, width, details, context);
      },
      onTapUp: (details) {
        if (checkOn()) return;
        final screenWidth = width;
        final dx = details.globalPosition.dx;
        if (dx < screenWidth / 2) {
          context.read<StoryBucketCubit>().leftTap();
        } else {
          context.read<StoryBucketCubit>().rightTap();
        }
      },
      onLongPressDown: (_) {
        if (checkOn()) return;
        context.read<StoryBucketCubit>().pauseStory();
      },
      onVerticalDragEnd: (_) {
        if (checkOn()) return;
        context.read<StoryBucketCubit>().continueStory();
      },
      onLongPressEnd: (_) {
        if (checkOn()) return;
        context.read<StoryBucketCubit>().continueStory();
      },
    );
  }

  void slideUpdateAction(
      PageController pageController, DragUpdateDetails details) {
    final targetPosition = pageController.offset - details.delta.dx;
    if (targetPosition > pageController.position.maxScrollExtent) {
      pageController.jumpTo(pageController.position.maxScrollExtent);
    } else if (targetPosition < 0) {
      pageController.jumpTo(0);
    } else {
      pageController.jumpTo(targetPosition);
    }
  }

  void slideEndAction2(
    PageController pc,
    double width,
    DragEndDetails details,
    BuildContext context,
  ) {
    final speedTest = width;
    final speedLimit = speedTest * 3;
    final velocity =
        details.velocity.pixelsPerSecond.dx.clamp(-speedLimit, speedLimit);
    final absVelocity = velocity.abs();
    final headCubit = context.read<StoryHeadCubit>();
    final currentPageValue = pc.page!;
    final pathSign = (headCubit.indexCurrentBucket - currentPageValue).sign;
    final velocitySign = velocity.sign;
    final isSlideFit = pathSign == velocitySign;

    //for slide go
    if (absVelocity > speedTest && isSlideFit) {
      final indexEdgeBucket =
          velocity.isNegative ? headCubit.indexMaxBucket : 0;
      if (headCubit.indexCurrentBucket != indexEdgeBucket) {
        final remainWay = max((velocitySign * pc.offset % width), width * 0.1);
        final remainDuration = remainWay * 1000 ~/ absVelocity;
        final indexTargetPage =
            headCubit.indexCurrentBucket - velocitySign.toInt();
        pc
            .animateToPage(indexTargetPage,
                duration: Duration(milliseconds: remainDuration),
                curve: Curves.ease)
            .then((value) => headCubit.alertNewBucket(indexTargetPage));
        return;
      }
    }
    //for drop go
    final indexTargetPage = currentPageValue.round();
    final timeMs =
        (max((currentPageValue - indexTargetPage).abs(), 0.05) * 1000).toInt();
    final bucketCubit = context.read<StoryBucketCubit>();
    final animateEndCallback = indexTargetPage == bucketCubit.indexBucket
        ? (_) => bucketCubit.continueStory()
        : (_) => headCubit.alertNewBucket(indexTargetPage);
    pc
        .animateToPage(indexTargetPage,
            duration: Duration(milliseconds: timeMs), curve: Curves.ease)
        .then(animateEndCallback);
  }
}
