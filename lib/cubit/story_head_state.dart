part of 'story_head_cubit.dart';

@immutable
abstract class StoryHeadState {}

class SHInitialState extends StoryHeadState {}

class SHLoadingState extends StoryHeadState {}

class SHHomeState extends StoryHeadState {
  final List<StoryBucket> sbList;

  SHHomeState(this.sbList);
}

class SHViewState extends StoryHeadState {}

class SHNewState extends StoryHeadState {
  final int indexNewBucket;
  SHNewState(this.indexNewBucket);
}
