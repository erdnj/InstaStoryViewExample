import 'package:bloc/bloc.dart';
import 'package:instagram_story_case_1/widgets/story_widget.dart';
import 'package:meta/meta.dart';
part 'story_state.dart';

class StoryCubit extends Cubit<StoryState> {
  int current_i = 0;
  int current_b = 0;
  late final List<StoryBucket> sbl;
  late final int bucketLenIndexed;
  StoryCubit() : super(StoryInitial()) {
    print("cubit_created");
  }

  assignBucket(_sbl) {
    sbl = _sbl;
    bucketLenIndexed = sbl.length - 1;
  }

  leftTap() {
    if (current_i == 0 && current_b == 0) {
      
    } else if (current_i == 0) {
      ///// go to before bucket
      current_b -= 1;
      current_i = sbl[current_b].last;
      markAsSeen();
      emit(StoryLeftState(StorySwapMod.bucket));
    } else {
      current_i -= 1;
      sbl[current_b].last = current_i;
      markAsSeen();
      emit(StoryLeftState(StorySwapMod.item));
    }
  }

  rightTap() {
    if (current_i == sbl[current_b].length - 1 &&
        current_b == bucketLenIndexed) {
      emit(CloseState());
    } else if (current_i == sbl[current_b].length - 1) {
      ///// go to forward bucket
      current_b += 1;
      current_i = sbl[current_b].last;
      markAsSeen();
      sbl[current_b].allSeen = true;
      emit(StoryRightState(StorySwapMod.bucket));
    } else {
      current_i += 1;
      sbl[current_b].last = current_i;
      markAsSeen();
      emit(StoryRightState(StorySwapMod.item));
    }
  }

  storyTap(int bucketIndex) {
    current_b = bucketIndex;
    current_i = sbl[current_b].last;
    emit(StoryTappedState(current_b, current_i));
  }

  playStory() {
    emit(StoryPlayingState());
  }

  pauseStory() {
    emit(StoryHoldedState());
  }

  closeStory() {
    emit(CloseState());
  }

  goHome() {
    emit(StoryHomeState());
  }

  void markAsSeen() {
    sbl[current_b].stories[current_i].seen = true;
  }
}
