part of 'story_cubit.dart';

@immutable
abstract class StoryState {}

class StoryInitial extends StoryState {

}

enum StorySwapMod { bucket, item }

class StoryRightState extends StoryState {
  final StorySwapMod mod;
  StoryRightState(this.mod);
}

class StoryLeftState extends StoryState {
  final StorySwapMod mod;
  StoryLeftState(this.mod);
}

class StoryLoadingState extends StoryState {}

class StoryPausedState extends StoryState {}


class StoryContinueState extends StoryState {}


class StoryPlayingState extends StoryState {}

class CloseState extends StoryState {}
class StoryReadyState extends StoryState {}


