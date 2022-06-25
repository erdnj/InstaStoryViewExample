import 'package:bloc/bloc.dart';
import 'package:instagram_story_case_1/widgets/story_widget.dart';
import 'package:meta/meta.dart';
part 'story_state.dart';

class StoryCubit extends Cubit<StoryState> {
  int current_i;
  final int bucketID;
  final StoryBucket sb;
  final int bucketLenIndexed;
  final bool isLastSB;
  StoryCubit({required this.bucketID, required this.sb, required this.isLastSB})
      : bucketLenIndexed = sb.length - 1,
        current_i = sb.last,
        super(StoryInitial()) {
    print("story_cubit_created");
  }

  leftTap() {
    if (current_i == 0 && bucketID == 0) {
    } else if (current_i == 0) {
      ///// go to before bucket
      current_i = sb.last;
      sb.markAsSeen(current_i);
      emit(StoryLeftState(StorySwapMod.bucket));
    } else {
      current_i -= 1;
      sb.last = current_i;
      emit(StoryLeftState(StorySwapMod.item));
      sb.markAsSeen(current_i);
    }
  }

  rightTap() {
    if (current_i == sb.length - 1 && isLastSB) {
      emit(CloseState());
    } else if (current_i == sb.length - 1) {
      ///// go to forward bucket
      current_i = sb.last;
      sb.markAsSeen(current_i);
      emit(StoryRightState(StorySwapMod.bucket));
    } else {
      current_i += 1;
      sb.last = current_i;
      emit(StoryRightState(StorySwapMod.item));
      sb.markAsSeen(current_i);
    }
  }

  playStory() {
    print("playStory called");
    sb.markAsSeen(current_i);
    emit(StoryPlayingState());
  }

  continueStory() {
    emit(StoryContinueState());
  }

  pauseStory() {
    emit(StoryPausedState());
  }

  closeStoryBucket() {
    emit(CloseState());
  }

  loadStory() {
    emit(StoryLoadingState());
  }

  storyIsReady() {
    emit(StoryReadyState());
  }
}
