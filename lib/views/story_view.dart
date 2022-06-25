import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram_story_case_1/cubit/story_cubit.dart';
import 'package:instagram_story_case_1/models/story_models.dart';
import 'package:instagram_story_case_1/widgets/story_progress_bar.dart';
import 'package:video_player/video_player.dart';
import '../cubit/story_bucket_cubit_cubit.dart';

class StoryView extends StatefulWidget {
  const StoryView(this.current_b, {Key? key}) : super(key: key);
  final int current_b;
  @override
  State<StoryView> createState() => _StoryViewState();
}

class _StoryViewState extends State<StoryView> {
  late PageController pageController;

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: widget.current_b);
    pageController.addListener(() {
      print(pageController.position.haveDimensions);
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<StoryBucket> sbl = context.read<StoryBucketCubit>().sbl;
    StoryBucket sb = sbl[widget.current_b];

    return PageView.builder(
        onPageChanged: (newPageIndex) {
          context.read<StoryBucketCubit>().alertNewPage(newPageIndex);
        },
        controller: pageController,
        itemCount: sbl.length,
        itemBuilder: (context, bi) {
          return BlocProvider<StoryCubit>(
            create: (context) => StoryCubit(
                bucketID: bi,
                isLastSB:
                    context.read<StoryBucketCubit>().bucketLenIndexed == bi,
                sb: sbl[bi]),
            child: StoryViewItem(
                bucketID: bi, sb: sbl[bi], pageController: pageController),
          );
        });
  }
}

double degToRad(num deg) => deg * (pi / 180.0);

class _SwipeWidget extends StatelessWidget {
  final int index;

  final double pageNotifier;

  final Widget child;

  const _SwipeWidget(
      {required this.index,
      required this.pageNotifier,
      required this.child,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isLeaving = (index - pageNotifier) <= 0;
    final t = (index - pageNotifier);
    final rotationY = lerpDouble(0, 90, t)!;
    final opacity = lerpDouble(0, 1, t.abs())!.clamp(0.0, 1.0);
    final transform = Matrix4.identity();
    transform.setEntry(3, 2, 0.001);
    transform.rotateY(-degToRad(rotationY));
    return Transform(
      alignment: isLeaving ? Alignment.centerRight : Alignment.centerLeft,
      transform: transform,
      child: Stack(
        children: [
          child,
          Positioned.fill(
            child: Opacity(
              opacity: opacity,
              child: SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}

class StoryViewItem extends StatefulWidget {
  const StoryViewItem(
      {Key? key,
      required this.bucketID,
      required this.sb,
      required this.pageController})
      : super(key: key);
  final PageController pageController;
  final int bucketID;
  final StoryBucket sb;

  @override
  State<StoryViewItem> createState() => _StoryViewItemState();
}

class _StoryViewItemState extends State<StoryViewItem>
    with SingleTickerProviderStateMixin {
  late AnimationController animController;
  VideoPlayerController? videoController;

  @override
  void initState() {
    super.initState();
    animController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    animController.dispose();
    videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        context.read<StoryCubit>().rightTap();
      }
    });

    StoryItem current_story =
        widget.sb.stories[context.read<StoryCubit>().current_i];

    if (current_story is ImageStoryItem) {
      animController.duration = current_story.duration;
      if (widget.bucketID == context.read<StoryBucketCubit>().current_b) {
        animController.forward();
      }
    } else {
      videoController?.dispose();
      videoController = VideoPlayerController.asset(current_story.path)
        ..initialize().then((_) {
          if (videoController!.value.isInitialized) {
            animController.duration = videoController!.value.duration;
            context.read<StoryCubit>().storyIsReady();
          }
        });
    }

    return BlocListener<StoryBucketCubit, StoryBucketState>(
        listenWhen: (p, c) {
          if (c is NewPageState) {
            return true;
          } else {
            return false;
          }
        },
        listener: (context, state) {
          if (state is NewPageState) {
            if (widget.bucketID == state.newPage) {
              StoryItem cs =
                  widget.sb.stories[context.read<StoryCubit>().current_i];
              if (cs is ImageStoryItem) {
                context.read<StoryCubit>().playStory();
              } else if (context.read<StoryCubit>().state is StoryReadyState) {
                context.read<StoryCubit>().playStory();
              }
            } else {
              animController.stop();
            }
          }
        },
        child: BlocConsumer<StoryCubit, StoryState>(
          listener: (context, state) {
            StoryItem current_story =
                widget.sb.stories[context.read<StoryCubit>().current_i];
            if (state is StoryPlayingState) {
              animController.forward();
              if (current_story is VideoStoryItem) {
                videoController!.play();
              }
            } else if (state is StoryLoadingState) {
              animController.reset();
              videoController?.dispose();
              if (current_story is ImageStoryItem) {
                animController.duration = current_story.duration;
                context.read<StoryCubit>().playStory();
              } else {
                videoController =
                    VideoPlayerController.asset(current_story.path)
                      ..initialize().then((_) {
                        if (videoController!.value.isInitialized) {
                          animController.duration =
                              videoController!.value.duration;
                          context.read<StoryCubit>().storyIsReady();
                        }
                      });
              }
            } else if (state is StoryReadyState) {
              if (widget.bucketID ==
                  context.read<StoryBucketCubit>().current_b) {
                context.read<StoryCubit>().playStory();
              }
            } else if (state is StoryPausedState) {
              animController.stop();
              if (current_story is VideoStoryItem) {
                videoController!.pause();
              }
            } else if (state is StoryContinueState) {
              animController.forward();
              if (current_story is VideoStoryItem) {
                videoController!.play();
              }
            } else if (state is StoryRightState) {
              if (state.mod == StorySwapMod.bucket) {
                widget.pageController.nextPage(
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.ease);
              } else {
                context.read<StoryCubit>().loadStory();
              }
            } else if (state is StoryLeftState) {
              if (state.mod == StorySwapMod.bucket) {
                widget.pageController.previousPage(
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.ease);
              } else {
                context.read<StoryCubit>().loadStory();
              }
            } else if (state is CloseState) {
              Navigator.of(context).pop();
            }
          },
          buildWhen: (p, c) {
            if (c is StoryRightState && c.mod == StorySwapMod.item ||
                c is StoryLeftState && c.mod == StorySwapMod.item ||
                c is StoryReadyState) {
              return true;
            } else {
              return false;
            }
          },
          builder: (context, state) {
            int current_i = context.read<StoryCubit>().current_i;
            StoryItem current_story = widget.sb.stories[current_i];
            bool isImage = current_story is ImageStoryItem;

            return Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: isImage
                      ? Image(
                          image: AssetImage(current_story.path),
                          fit: BoxFit.fitWidth,
                        )
                      : (state is StoryReadyState)
                          ? SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height,
                              child: FittedBox(
                                clipBehavior: Clip.hardEdge,
                                fit: BoxFit.cover,
                                child: SizedBox(
                                  width: videoController!.value.size.width,
                                  height: videoController!.value.size.height,
                                  child: VideoPlayer(videoController!),
                                ),
                              ),
                            )
                          : const SizedBox(),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: SafeArea(
                    bottom: false,
                    child: StoryProgressBar(
                      currentStory: current_i,
                      storyLength: widget.sb.length,
                      animController: animController,
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: GestureDetector(
                    onVerticalDragEnd: (detail) {
                      context.read<StoryCubit>().continueStory();
                    },
                    onTapUp: (details) {
                      final double screenWidth =
                          MediaQuery.of(context).size.width;
                      final double dx = details.globalPosition.dx;
                      if (dx < screenWidth / 2) {
                        context.read<StoryCubit>().leftTap();
                      } else {
                        context.read<StoryCubit>().rightTap();
                      }
                    },
                    onLongPressDown: (details) {
                      context.read<StoryCubit>().pauseStory();
                    },
                    onLongPressEnd: (details) {
                      context.read<StoryCubit>().continueStory();
                    },
                  ),
                ),
              ],
            );
          },
        ));
  }
}
