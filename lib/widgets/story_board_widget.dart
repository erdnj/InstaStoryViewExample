import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram_story_case_1/cubit/story_head_cubit.dart';
import 'package:instagram_story_case_1/models/story_models.dart';
import 'package:instagram_story_case_1/views/story_view/story_view.dart';

class StoryBoardWidget extends StatelessWidget {
  const StoryBoardWidget({Key? key, required this.storyDict})
      : storiesLength = storyDict.length,
        super(key: key);
  final Map<String, Map<String, Object>> storyDict;
  final int storiesLength;

  @override
  Widget build(BuildContext context) {
    final widthSize = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.only(top: widthSize * 0.03),
      height: widthSize * 0.40,
      width: widthSize,
      child: BlocProvider<StoryHeadCubit>(
        create: (context) => StoryHeadCubit()..assignDict(storyDict),
        child: BlocBuilder<StoryHeadCubit, StoryHeadState>(
          buildWhen: (previous, current) {
            if (current is SHViewState || current is SHNewState) {
              return false;
            } else {
              return true;
            }
          },
          builder: (context, state) {
            if (state is SHHomeState) {
              return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(
                      left: widthSize * 0.025, right: widthSize * 0.025),
                  scrollDirection: Axis.horizontal,
                  itemCount: storiesLength,
                  itemBuilder: (_context, i) {
                    return Row(
                      children: [
                        StoryListItem(
                            sb: state.sbList[i], i: i, size: widthSize * 0.2),
                        SizedBox(
                          width:
                              (i != storiesLength - 1) ? widthSize * 0.05 : 0,
                        )
                      ],
                    );
                  });
            } else if (state is SHLoadingState || state is SHInitialState) {
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
        context.read<StoryHeadCubit>().storyTap(i);
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) {
            return BlocProvider<StoryHeadCubit>.value(
              value: BlocProvider.of<StoryHeadCubit>(context),
              child: StoryView(i),
            );
            // set block's bucket and page id +++++++*++*+*+*+*+*+**+*+*++*+*+*++**++*+*+*+*+*+++*+*+*++**++*++*+*
          }),
        ).then((_) => context.read<StoryHeadCubit>().goHome());
      },
      child: Column(
        children: [
          Hero(
            tag: sb.owner,
            child: Container(
              height: size,
              width: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: sb.allSeen ? Colors.grey : Colors.green,
                    width: size * 0.04),
                image: DecorationImage(
                    image: AssetImage(sb.owner.pathPP), fit: BoxFit.cover),
              ),
            ),
          ),
          SizedBox(
            height: size * 0.4,
            width: size,
            child: Center(
              child: Text(
                sb.owner.nick,
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
