import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram_story_case_1/cubit/story_bucket_cubit_cubit.dart';
import 'package:instagram_story_case_1/cubit/story_cubit.dart';
import 'package:instagram_story_case_1/views/story_view.dart';

class StoryWidget extends StatelessWidget {
  const StoryWidget({Key? key, required this.storyDict})
      : storiesLength = storyDict.length,
        super(key: key);
  final Map<String, Map<String, Object>> storyDict;
  final int storiesLength;

  //List<StoryBucket> get  bucketList => [];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      height: 140,
      child: BlocProvider<StoryBucketCubit>(
        create: (context) => StoryBucketCubit()..assignDict(storyDict),
        child: BlocBuilder<StoryBucketCubit, StoryBucketState>(
          buildWhen: (previous, current) {
            if (current is SbViewState) {
              return false;
            } else {
              return true;
            }
          },
          builder: (context, state) {
            print(state);
            if (state is SbHomeState) {
              return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: storiesLength,
                  itemBuilder: (_context, i) {
                    return Row(
                      children: [
                        StoryListItem(sb: state.sbl[i], i: i),
                        SizedBox(
                          width: (i != storiesLength - 1) ? 23 : 0,
                        )
                      ],
                    );
                  });
            } else if (state is SbLoadingState || state is StoryBucketInitial) {
              return const Center(child: Text("Loading..."));
            } else {
              return const Center(child: Text("That shouldn't be seen"));
            }
          },
        ),
      ),
      color: Colors.transparent,
    );
  }
}

class StoryListItem extends StatelessWidget {
  const StoryListItem({
    Key? key,
    required this.sb,
    required this.i,
  }) : super(key: key);

  final StoryBucket sb;
  final int i;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.read<StoryBucketCubit>().storyTap(i);
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) {
            return BlocProvider<StoryBucketCubit>.value(
              value: BlocProvider.of<StoryBucketCubit>(context),
              child: StoryView(),
            );
            // set block's bucket and page id +++++++*++*+*+*+*+*+**+*+*++*+*+*++**++*+*+*+*+*+++*+*+*++**++*++*+*
          }),
        ).then((_) => context.read<StoryBucketCubit>().goHome());
      },
      child: Column(
        children: [
          Container(
            height: 75,
            width: 75,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: sb.allSeen ? Colors.grey : Colors.green, width: 3),
              image: DecorationImage(
                  image: AssetImage(sb.ppPath), fit: BoxFit.cover),
            ),
          ),
          SizedBox(
            height: 30,
            width: 75,
            child: Center(
              child: Text(
                sb.owner,
                style: TextStyle(color: Colors.black54, fontSize: 14),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class StoryBucket implements Comparable<StoryBucket> {
  final List<StoryItem> stories;
  final int length;
  final String ppPath;
  final String owner;
  int last = 0;
  bool allSeen = false;

  StoryBucket(this.stories, this.ppPath, this.owner) : length = stories.length;

  markAsSeen(int index) {
    stories[index].seen = true;
    if (index == length - 1) {
      allSeen = true;
    }
  }

  @override
  int compareTo(other) {
    // age < other.age
    if (!allSeen && other.allSeen) {
      return -1;
    }

    // age > other.age
    else if (allSeen && !other.allSeen) {
      return 1;
    }

    int result = owner.compareTo(other.owner);
    if (result < 0) {
      return -1;
    } else if (result > 0) {
      return 1;
    }

    // age == other.age
    return 0;
  }
}

abstract class StoryItem {
  final String path;
  bool seen = false;
  Duration? duration;

  StoryItem(this.path, {this.duration});
}

class ImageStoryItem extends StoryItem {
  ImageStoryItem(String path)
      : super(path, duration: const Duration(seconds: 5));
}

class VideoStoryItem extends StoryItem {
  VideoStoryItem(String path, {duration}) : super(path, duration: duration);
}
