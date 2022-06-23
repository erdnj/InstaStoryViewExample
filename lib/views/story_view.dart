import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram_story_case_1/cubit/story_cubit.dart';
import 'package:instagram_story_case_1/widgets/story_widget.dart';

class StoryView extends StatelessWidget {
  const StoryView({Key? key, required this.blocContext}) : super(key: key);
  final BuildContext blocContext;
  @override
  Widget build(BuildContext context) {
    print("loooool");

    return BlocProvider<StoryCubit>.value(
      value: BlocProvider.of<StoryCubit>(blocContext),
      child: BlocBuilder<StoryCubit, StoryState>(
        builder: (context, state) {
          print(state);
          final List<StoryBucket> sbl = context
              .read<StoryCubit>()
              .sbl; //there should be implementtttttttttttttttttttttttttttttttttttttttttt
          int current_i = context.read<StoryCubit>().current_i;
          int current_b = context.read<StoryCubit>().current_b;
          return Scaffold(
            body: Stack(
              children: [
                Center(
                  child: Container(
                    child: Text(sbl[current_b].stories[current_i].path),
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: SafeArea(
                    bottom: false,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ProgressBar(currentStory: current_i, storyLength: sbl[current_b].length),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width / 2,
                      child: GestureDetector(onTap: (() {
                        context.read<StoryCubit>().leftTap();
                        print("Tapped left");
                      })),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width / 2,
                      child: GestureDetector(onTap: (() {
                        context.read<StoryCubit>().rightTap();
                        print("Tapped right");
                        print(context.read<StoryCubit>().current_i);
                      })),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ProgressBar extends StatelessWidget {
  const ProgressBar({Key? key, required this.currentStory, required this.storyLength}) : super(key: key);
  final int currentStory;
  final int storyLength;
  @override
  Widget build(BuildContext context) {
    /* widget.sbl[widget.current_i].stories[widget.sbl[widget.current_i].last]
        .seen = true; */
    return Container(
      height: 50,
      width: 300,
      color: Colors.orange,
      child: Row(
        children: Iterable.generate(storyLength).map((it) {
          if (currentStory == it) {
            return BlocBuilder<StoryCubit, StoryState>(
              builder: (context, state) {
                return Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(right: 5, left: 5),
                    child: const LinearProgressIndicator(
                        color: Colors.black38, value: 0.5),
                  ),
                );
              },
            );
          } else {
            return Expanded(
              child: Container(
                padding: const EdgeInsets.only(right: 5, left: 5),
                child: LinearProgressIndicator(
                  color: Colors.black38,
                  value: (currentStory > it ? 1 : 0),
                ),
              ),
            );
          }
        }).toList(),
      ),
    );
  }
}
