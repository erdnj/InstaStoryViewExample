import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram_story_case_1/cubit/story_head_cubit.dart';
import 'package:instagram_story_case_1/cubit/story_bucket_cubit.dart';
import 'package:instagram_story_case_1/models/story_models.dart';
import 'package:instagram_story_case_1/widgets/cubic_animation_widget.dart';
import 'package:instagram_story_case_1/widgets/gesture_behaviorer.dart';
import 'package:instagram_story_case_1/widgets/story_progress_bar.dart';
part 'story_view_item_child.dart';

///Each page of page view is that widget
class StoryViewItem extends StatefulWidget {
  const StoryViewItem({Key? key}) : super(key: key);

  @override
  State<StoryViewItem> createState() => _StoryViewItemState();
}

class _StoryViewItemState extends State<StoryViewItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          context.read<StoryBucketCubit>().rightTap();
        }
      });
  }

  @override
  void dispose() {
    _animController.dispose();
    disposeVideoController();
    super.dispose();
  }

  void disposeVideoController() {
    // if it is initialized schedule it to dispose
    // if its not, _videoController=null make it auto disposal after it init
    // with isVideoControllerNotValid function.
    if (_videoController?.value.isInitialized == true) {
      final oldVideoController = _videoController;
      scheduleDisposeVideoController(oldVideoController);
    }
    _videoController = null;
  }

  @override
  Widget build(BuildContext context) {
    final pageController = context.read<PageController>();
    final storyBucketCubit = context.read<StoryBucketCubit>();
    final storyHeadCubit = context.read<StoryHeadCubit>();

    return BlocListener<StoryHeadCubit, StoryHeadState>(
      listenWhen: (p, c) {
        return c is SHNewState;
      },
      listener: (_, state) {
        if (state is! SHNewState) return;
        if (storyBucketCubit.indexBucket != state.indexNewBucket) {
          _animController.stop();
          return;
        }
        final storyBucketState = storyBucketCubit.state;
        switch (storyBucketState) {
          case StoryPausedState():
            if (storyBucketState.isLoaded) continue playCase;
            break;
          playCase:
          case StoryReadyState():
            storyBucketCubit.playStory();
        }
      },
      child: Stack(
        children: [
          //FutureBuilder used to wait PageView widget build to reach page value under tree
          FutureBuilder(
              future: Future.value(true),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox();
                }
                return BlocConsumer<StoryBucketCubit, StoryBucketState>(
                  listenWhen: (p, c) {
                    //to keep paused behaviour
                    if (p is StoryPausedState &&
                        (c is StoryLoadingState || c is StoryReadyState)) {
                      return false;
                    }
                    return true;
                  },
                  listener: (context, state) {
                    final currentItem = storyBucketCubit.currentItem;
                    switch (state) {
                      case StoryPlayingState():
                        _animController.forward();
                        if (currentItem is VideoStoryItem) {
                          _videoController!.play();
                        }
                        break;
                      case StoryLoadingState():
                        loadStory(currentItem, storyBucketCubit);
                        break;
                      case StoryReadyState():
                        if (storyBucketCubit.indexBucket ==
                            storyHeadCubit.indexCurrentBucket) {
                          storyBucketCubit.playStory();
                        }
                        break;
                      case StoryPausedState():
                        _animController.stop();
                        if (currentItem is VideoStoryItem) {
                          _videoController!.pause();
                        }
                        break;
                      case StoryRightState():
                        if (state.mod == StorySwapMod.bucket) {
                          final nextPage = pageController.page!.round() + 1;
                          pageController
                              .nextPage(
                                  duration: const Duration(milliseconds: 1000),
                                  curve: Curves.ease)
                              .then((value) =>
                                  storyHeadCubit.alertNewBucket(nextPage));
                        } else {
                          storyBucketCubit.loadStory();
                        }
                        break;
                      case StoryLeftState():
                        if (state.mod == StorySwapMod.bucket) {
                          final prevPage = pageController.page!.round() - 1;
                          pageController
                              .previousPage(
                                  duration: const Duration(milliseconds: 1000),
                                  curve: Curves.ease)
                              .then((value) =>
                                  storyHeadCubit.alertNewBucket(prevPage));
                        } else {
                          storyBucketCubit.loadStory();
                        }
                        break;
                      case StoryCloseState():
                        Navigator.of(context).pop();
                        break;
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
                    //trigger load after build done on [StoryInitialState]
                    if (state is StoryInitialState) {
                      Future.delayed(Duration.zero, storyBucketCubit.loadStory);
                    }
                    print("builded");
                    return CubicAnimationWidget(
                      pageController: pageController,
                      index: storyBucketCubit.indexBucket,
                      child: StoryViewItemChild(
                        videoController: _videoController,
                        animController: _animController,
                        state: state,
                      ),
                    );
                  },
                );
              }),
          //To prevent gestures on initial state
          BlocBuilder<StoryBucketCubit, StoryBucketState>(
            buildWhen: (previous, current) {
              return previous is StoryInitialState ||
                  current is StoryInitialState;
            },
            builder: (context, state) {
              return SizedBox(
                height: MediaQuery.sizeOf(context).height,
                width: MediaQuery.sizeOf(context).width,
                child: state is StoryInitialState
                    ? null
                    : const GestureBehaviorer(),
              );
            },
          ),
        ],
      ),
    );
  }

  void loadStory(StoryItem currentStory, StoryBucketCubit storyBucketCubit) {
    if (_videoController?.value.isInitialized == true) {
      final oldVideoController = _videoController;
      scheduleDisposeVideoController(oldVideoController);
    }
    _animController.reset();
    if (currentStory is ImageStoryItem) {
      _videoController = null;
      _animController.duration = currentStory.duration;
      storyBucketCubit.storyIsReady();
    } else {
      final tempVideoController =
          VideoPlayerController.asset(currentStory.path);
      _videoController = tempVideoController;
      tempVideoController.initialize().then((_) {
        if (isVideoControllerNotValid(tempVideoController)) return;
        if (tempVideoController.value.isInitialized &&
            !storyBucketCubit.isClosed) {
          _animController.duration = tempVideoController.value.duration;
          storyBucketCubit.storyIsReady();
        }
      });
    }
  }

  bool isVideoControllerNotValid(VideoPlayerController vc) {
    if (vc != _videoController) {
      scheduleDisposeVideoController(vc);
      return true;
    }
    return false;
  }

  void scheduleDisposeVideoController(VideoPlayerController? videoController) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await videoController?.pause();
      await videoController?.dispose();
    });
  }
}
