part of 'story_bucket_cubit.dart';

enum StorySwapMod { bucket, item }

@immutable
abstract class StoryBucketState {}

class StoryInitialState extends StoryBucketState {}

class StoryRightState extends StoryBucketState {
  final StorySwapMod mod;
  StoryRightState(this.mod);
}

class StoryLeftState extends StoryBucketState {
  final StorySwapMod mod;
  StoryLeftState(this.mod);
}

class StoryLoadingState extends StoryBucketState {}

class StoryPausedState extends StoryBucketState {
  final bool isLoaded;
  StoryPausedState(this.isLoaded);
}

class StoryPlayingState extends StoryBucketState {}

class StoryCloseState extends StoryBucketState {}

class StoryReadyState extends StoryBucketState {}
