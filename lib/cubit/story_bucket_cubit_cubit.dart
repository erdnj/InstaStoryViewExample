import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:instagram_story_case_1/models/story_models.dart';
import 'package:meta/meta.dart';
part 'story_bucket_cubit_state.dart';

class StoryBucketCubit extends Cubit<StoryBucketState> {
  StoryBucketCubit() : super(StoryBucketInitial());
  late final List<StoryBucket> sbl;
  late final int bucketLenIndexed;
  int current_b = 0;

  assignDict(_dict) {
    emit(SbLoadingState());
    _storyInit(_dict).then((_sbl) {
      sbl = _sbl..sort();
      bucketLenIndexed = sbl.length - 1;
      emit(SbHomeState(sbl));
    });
  }

  storyTap(int bucketIndex) {
    current_b = bucketIndex;
    emit(SbViewState());
  }

  goHome() {
    emit(SbLoadingState());
    sbl.sort();
    emit(SbHomeState(sbl));
  }

  //Helper function
  Future<List<StoryBucket>> _storyInit(
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

  alertNewPage(int p) {
    current_b = p;
    emit(NewPageState(p));
  }

  
}
