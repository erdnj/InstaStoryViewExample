part of 'story_cubit.dart';

@immutable
abstract class StoryState {}

class StoryInitial extends StoryState {}

class StoryHomeState extends StoryState {}

class StoryTappedState extends StoryState {
  final int bucketID;
  final int itemID;

  StoryTappedState(this.bucketID, this.itemID);
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

class StoryHoldedState extends StoryState {}

class StoryPlayingState extends StoryState {}

class CloseState extends StoryState {}
