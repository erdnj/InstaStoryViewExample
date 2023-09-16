part of './story_view_item.dart';

class StoryViewItemChild extends StatelessWidget {
  const StoryViewItemChild({
    super.key,
    required this.videoController,
    required this.animController,
    required this.state,
  });

  final VideoPlayerController? videoController;
  final AnimationController animController;
  final StoryBucketState state;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;
    final sizePaddingTop = MediaQuery.paddingOf(context).top;

    final storyBucketCubit = context.read<StoryBucketCubit>();
    final indexCurrentItem = storyBucketCubit.indexCurrentItem;
    final storyItem = storyBucketCubit.currentItem;
    final isImage = storyItem is ImageStoryItem;
    final sb = storyBucketCubit.sb;
    final owner = sb.owner;

    return Stack(
      children: [
        Align(
          alignment: Alignment.center,
          child: isImage
              ? Image(
                  image: AssetImage(storyItem.path),
                  fit: BoxFit.fitWidth,
                )
              : (state is StoryReadyState)
                  ? SizedBox(
                      width: width,
                      height: height,
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
          child: SizedBox(
            width: width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                      top: sizePaddingTop, bottom: width * 0.03),
                  child: StoryProgressBar(
                    currentStory: indexCurrentItem,
                    storyLength: sb.length,
                    animController: animController,
                  ),
                ),
                Row(
                  children: [
                    Hero(
                      tag: owner,
                      child: Container(
                        margin: EdgeInsets.only(
                            left: width * 0.05, right: width * 0.02),
                        height: width / 9,
                        width: width / 9,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: AssetImage(owner.pathPP),
                              fit: BoxFit.cover),
                        ),
                      ),
                    ),
                    Text(owner.nick,
                        style: TextStyle(
                            decoration: TextDecoration.none,
                            color: const Color.fromRGBO(255, 255, 255, 1),
                            fontWeight: FontWeight.w600,
                            fontSize: width / 25))
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
