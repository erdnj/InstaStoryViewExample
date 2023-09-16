import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:instagram_story_case_1/models/story_models.dart';
import 'package:instagram_story_case_1/models/user.dart';
import 'package:meta/meta.dart';
part 'story_head_state.dart';

//This is the StoryWidget's cubit actually, there is only one and it help Storycubit
class StoryHeadCubit extends Cubit<StoryHeadState> {
  StoryHeadCubit() : super(SHInitialState());
  late final List<StoryBucket> sbList;
  late final int indexMaxBucket;
  int indexCurrentBucket = 0;

  assignDict(_dict) {
    emit(SHLoadingState());
    sbList = _storyInit(_dict)..sort();
    indexMaxBucket = sbList.length - 1;
    emit(SHHomeState(sbList));
  }

  storyTap(int indexBucket) {
    indexCurrentBucket = indexBucket;
    emit(SHViewState());
  }

  alertNewBucket(int indexNewBucket) {
    switch (state) {
      case SHViewState():
      case SHNewState():
        indexCurrentBucket = indexNewBucket;
        emit(SHNewState(indexNewBucket));
        break;
    }
  }

  goHome() {
    emit(SHLoadingState());
    sbList
      ..sort()
      ..where((sb) => sb.allSeen).forEach((sb) => sb.last = 0);
    sbList
        .where((sb) => !sb.allSeen)
        .forEach((sb) => sb.last = sb.stories.indexWhere((s) => !s.seen));
    emit(SHHomeState(sbList));
  }

  //Helper function
  List<StoryBucket> _storyInit(Map<String, Map<String, Object>> storyDict) {
    return storyDict.entries.map((e) {
      List<String> storyPaths = e.value["stories"] as List<String>;
      List<StoryItem> stories = storyPaths.map((path) {
        if (path.endsWith("mp4")) {
          return VideoStoryItem(path, duration: const Duration(seconds: 2));
        } else {
          return ImageStoryItem(path);
        }
      }).toList();
      String pathPP = e.value["pp"] as String;
      final owner = User(nick: e.key, pathPP: pathPP);
      return StoryBucket(stories, owner);
    }).toList(growable: false);
  }
}
