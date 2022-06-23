part of 'story_bucket_cubit_cubit.dart';

@immutable
abstract class StoryBucketState {}

class StoryBucketInitial extends StoryBucketState {}

class SbLoadingState extends StoryBucketState {}

class SbHomeState extends StoryBucketState {
  final List<StoryBucket> sbl;

  SbHomeState(this.sbl);
}

class SbViewState extends StoryBucketState {}
