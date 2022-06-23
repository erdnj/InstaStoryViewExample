import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram_story_case_1/cubit/story_cubit.dart';
import 'package:instagram_story_case_1/views/story_view.dart';

class StoryWidget extends StatelessWidget {
  StoryWidget({Key? key, required this.storyDict})
      : storiesLength = storyDict.length,
        super(key: key);
  final Map<String, Map<String, Object>> storyDict;
  final int storiesLength;
  late final List<StoryBucket> bucketList;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      height: 140,
      child: FutureBuilder<List<StoryBucket>>(
          future: storyInit(storyDict),
          builder: (context, _snapshot) {
            if (_snapshot.hasData) {
              bucketList = _snapshot.data!;
              bucketList.sort();
              return BlocProvider<StoryCubit>(
                create: (_) => StoryCubit()..assignBucket(bucketList),
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: storiesLength,
                    itemBuilder: (_context, i) {
                      return Row(
                        children: [
                          StoryListItem(sbl: bucketList, i: i),
                          SizedBox(
                            width: (i != storiesLength - 1) ? 23 : 0,
                          )
                        ],
                      );
                    }),
              );
            } else
              return SizedBox();
          }),
      color: Colors.transparent,
    );
  }

  Future<List<StoryBucket>> storyInit(
      Map<String, Map<String, Object>> storyDict) async {
    return Future.wait<StoryBucket>(storyDict.entries.map((e) async {
      List<String> storyPaths = e.value["stories"] as List<String>;
      List<StoryItem> _stories = storyPaths.map((p) {
        if (p.endsWith("mp4")) {
          return VideoStoryItem(p, duration: Duration(seconds: 2));
        } else {
          return ImageStoryItem(p);
        }
      }).toList();
      String _ppPath = e.value["pp"] as String;
      return StoryBucket(_stories, _ppPath, e.key);
    }));
  }
}

class StoryListItem extends StatelessWidget {
  const StoryListItem({
    Key? key,
    required this.sbl,
    required this.i,
  }) : super(key: key);

  final List<StoryBucket> sbl;
  final int i;

  @override
  Widget build(BuildContext context) {
    var sb = sbl[i];
    return InkWell(
      onTap: () {
        context.read<StoryCubit>().storyTap(i);
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) {
            // set block's bucket and page id +++++++*++*+*+*+*+*+**+*+*++*+*+*++**++*+*+*+*+*+++*+*+*++**++*++*+*
            return StoryView(blocContext: context);
          }),
        );
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
