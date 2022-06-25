import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram_story_case_1/cubit/story_bucket_cubit_cubit.dart';
import 'package:instagram_story_case_1/models/story_models.dart';
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
            if (current is SbViewState || current is NewPageState) {
              return false;
            } else {
              return true;
            }
          },
          builder: (context, state) {
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
              child: StoryView(i),
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


