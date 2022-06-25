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

  @override
  Widget build(BuildContext context) {
    final widthSize = MediaQuery.of(context).size.width;
    final heightSize = MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.only(top: widthSize * 0.03),
      height: widthSize * 0.40,
      width: widthSize,
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
                  padding: EdgeInsets.only(
                      left: widthSize * 0.025, right: widthSize * 0.025),
                  scrollDirection: Axis.horizontal,
                  itemCount: storiesLength,
                  itemBuilder: (_context, i) {
                    return Row(
                      children: [
                        StoryListItem(
                            sb: state.sbl[i], i: i, size: widthSize * 0.2),
                        SizedBox(
                          width:
                              (i != storiesLength - 1) ? widthSize * 0.05 : 0,
                        )
                      ],
                    );
                  });
            } else if (state is SbLoadingState || state is StoryBucketInitial) {
              return const Center(child: Text("Loading..."));
            } else {
              return const Center(child: Text("That shouldn't be seen :)"));
            }
          },
        ),
      ),
    );
  }
}

class StoryListItem extends StatelessWidget {
  const StoryListItem({
    Key? key,
    required this.sb,
    required this.i,
    required this.size,
  }) : super(key: key);

  final StoryBucket sb;
  final int i;
  final double size;

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
            height: size,
            width: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: sb.allSeen ? Colors.grey : Colors.green,
                  width: size * 0.04),
              image: DecorationImage(
                  image: AssetImage(sb.ppPath), fit: BoxFit.cover),
            ),
          ),
          SizedBox(
            height: size * 0.4,
            width: size,
            child: Center(
              child: Text(
                sb.owner,
                style: TextStyle(
                    color: Colors.black54,
                    fontSize: size * 0.18,
                    fontWeight: FontWeight.w500),
              ),
            ),
          )
        ],
      ),
    );
  }
}
