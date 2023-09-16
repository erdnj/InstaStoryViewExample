import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram_story_case_1/cubit/story_bucket_cubit.dart';
import 'package:provider/provider.dart';
import '../../cubit/story_head_cubit.dart';
import 'story_view_item.dart';

//The widget when user tap the story circle open
class StoryView extends StatelessWidget {
  const StoryView(this.indexStartBucket, {super.key});
  final int indexStartBucket;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PageController>(
      create: (_) => PageController(initialPage: indexStartBucket),
      builder: (context, _) {
        final pageController = context.read<PageController>();
        final sbl = context.read<StoryHeadCubit>().sbList;
        return PageView.builder(
            pageSnapping: false,
            physics: const NeverScrollableScrollPhysics(),
            controller: pageController,
            itemCount: sbl.length,
            itemBuilder: (context, bi) {
              return BlocProvider<StoryBucketCubit>(
                create: (context) => StoryBucketCubit(
                    indexBucket: bi,
                    isFinalBucket:
                        context.read<StoryHeadCubit>().indexMaxBucket == bi,
                    sb: sbl[bi]),
                child: const StoryViewItem(),
              );
            });
      },
    );
  }
}
