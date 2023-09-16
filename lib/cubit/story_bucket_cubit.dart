import 'package:bloc/bloc.dart';
import 'package:instagram_story_case_1/models/story_models.dart';
import 'package:meta/meta.dart';
part 'story_bucket_state.dart';

/// Each story group have own a [StoryBucketCubit] when they on page view
class StoryBucketCubit extends Cubit<StoryBucketState> {
  final StoryBucket sb;
  final int indexBucket;
  final bool isFinalBucket;

  final int indexEndItem;
  int _indexCurrentItem;

  StoryItem get currentItem => sb.stories[_indexCurrentItem];
  int get indexCurrentItem => _indexCurrentItem;

  StoryBucketCubit(
      {required this.indexBucket,
      required this.sb,
      required this.isFinalBucket})
      : indexEndItem = sb.length - 1,
        _indexCurrentItem = sb.last,
        super(StoryInitialState());

  leftTap() {
    if (_indexCurrentItem == 0 && indexBucket == 0) {
      continueStory();
    } else if (_indexCurrentItem == 0) {
      // go to before bucket
      _indexCurrentItem = sb.last;
      sb.markAsSeen(_indexCurrentItem);
      emit(StoryLeftState(StorySwapMod.bucket));
    } else {
      _indexCurrentItem -= 1;
      sb.last = _indexCurrentItem;
      sb.markAsSeen(_indexCurrentItem);
      emit(StoryLeftState(StorySwapMod.item));
    }
  }

  rightTap() {
    if (_indexCurrentItem == indexEndItem && isFinalBucket) {
      emit(StoryCloseState());
    } else if (_indexCurrentItem == indexEndItem) {
      // go to forward bucket
      _indexCurrentItem = sb.last;
      sb.markAsSeen(_indexCurrentItem);
      emit(StoryRightState(StorySwapMod.bucket));
    } else {
      // go to forward story in same bucket
      _indexCurrentItem += 1;
      sb.last = _indexCurrentItem;
      sb.markAsSeen(_indexCurrentItem);
      emit(StoryRightState(StorySwapMod.item));
    }
  }

  storyIsReady() {
    switch (state) {
      case StoryPlayingState():
      case StoryCloseState():
      case StoryReadyState():
        break;
      default:
        emit(StoryReadyState());
    }
  }

  playStory() {
    switch (state) {
      case StoryReadyState():
        sb.markAsSeen(_indexCurrentItem);
        continue playCase;
      playCase:
      case StoryPausedState():
        emit(StoryPlayingState());
    }
  }

  continueStory() {
    if (isClosed) return; //used check as [continueStory] mostly used in [then] clauses
    final currentState = state;
    switch (currentState) {
      case StoryPausedState():
        if (!currentState.isLoaded) {
          emit(StoryLoadingState());
          break;
        }
        continue playCase;
      playCase:
      case StoryReadyState():
        playStory();
    }
  }

  pauseStory() {
    switch (state) {
      case StoryLoadingState():
        emit(StoryPausedState(false));
        break;
      case StoryReadyState():
      case StoryPlayingState():
        emit(StoryPausedState(true));
    }
  }

  loadStory() {
    emit(StoryLoadingState());
  }

  closeStoryBucket() {
    emit(StoryCloseState());
  }
}
