class StoryBucket implements Comparable<StoryBucket> {
  final List<StoryItem> stories;
  final int length;
  final String ppPath;
  final String owner;
  int last = 0;
  bool allSeen = false;

  StoryBucket(this.stories, this.ppPath, this.owner) : length = stories.length;

  markAsSeen(int index) {
    stories[index].seen = true;
    if (index == length - 1) {
      allSeen = true;
    }
  }

  @override
  int compareTo(other) {
    // age < other.age
    if (!allSeen && other.allSeen) {
      return -1;
    }

    // age > other.age
    else if (allSeen && !other.allSeen) {
      return 1;
    }

    int result = owner.compareTo(other.owner);
    if (result < 0) {
      return -1;
    } else if (result > 0) {
      return 1;
    }

    // age == other.age
    return 0;
  }
}

abstract class StoryItem {
  final String path;
  bool seen = false;
  Duration? duration;

  StoryItem(this.path, {this.duration});
}

class ImageStoryItem extends StoryItem {
  ImageStoryItem(String path)
      : super(path, duration: const Duration(seconds: 5));
}

class VideoStoryItem extends StoryItem {
  VideoStoryItem(String path, {duration}) : super(path, duration: duration);
}