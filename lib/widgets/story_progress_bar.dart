import 'package:flutter/material.dart';

class StoryProgressBar extends StatelessWidget {
  const StoryProgressBar(
      {Key? key,
      required this.currentStory,
      required this.storyLength,
      required this.animController})
      : super(key: key);
  final int currentStory;
  final int storyLength;
  final AnimationController animController;

  @override
  Widget build(BuildContext context) {
    /* widget.sbl[widget.current_i].stories[widget.sbl[widget.current_i].last]
        .seen = true; */
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.96,
      child: Row(
        children: Iterable.generate(storyLength).map((it) {
          if (currentStory == it) {
            return Expanded(
              child: Container(
                padding: const EdgeInsets.only(right: 5, left: 5),
                child: AnimatedBuilder(
                    animation: animController,
                    builder: (context, child) {
                      return LinearProgressIndicator(
                          color: Colors.white,
                          backgroundColor: Colors.grey,
                          value: animController.value);
                    }),
              ),
            );
          } else {
            return Expanded(
              child: Container(
                padding: const EdgeInsets.only(right: 5, left: 5),
                child: LinearProgressIndicator(
                  color: Colors.white,
                  backgroundColor: Colors.grey,
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