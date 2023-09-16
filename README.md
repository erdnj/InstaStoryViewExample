# Pretty Instagram Story Example

## Changelog

* Cubits and views renamed.
* Before cubit naming is kind a complicated and difficult to identify them, now top cubit is StoryHeadCubit and each story's cubit is StoryBucketCubit.
* Logic parts simplified.
* Gesture logic moved to GestureBehaviorer widget and its logic shortened as possible with keeping intended physic behaviours.
* Cubic animation moved to CubicAnimationWidget.
* PageChangeNotifier removed, instead PageControllers itself has used as notifier.
* Stateful widgets removed except main page and storyViewItem pages due to ticker dependencies.
* Variable naming refreshed.
* **There was models for story datas which are StoryBucket and StoryItem.** As new, User model added to StoryBucket. As design choice User model kept under StoryBucket model.
* Error logs due to video controller's wrong disposal has resolved.
* Fast transition video non-starting cases has resolved. Simple test video has uploaded at bottom.


## Discussion

* On android(my physical device(jason-crDroid7.31-android11)) has still logging ```E/Surface : freeAllBuffers: 6 buffers were freed while being dequeued!``` from video_player package's android backend player ExoPlayer. Through my tests, it log that line whenever I dispose controller even it is unused. I have assumed it as non-important log as it always doing it on my device.
* Above logs release point is [Surface.cpp](https://android.googlesource.com/platform/frameworks/native/+/master/libs/gui/Surface.cpp#2304) on android.
* Binding animationController to videoController is help to get rid of **SingleTickerProviderStateMixin** dependency on Stateful Widget. In my design I only kept current video controller, and one animation controller. Also I want to keep showing images with AssetImage instead of video player. So I stick with Stateful Widget.



## Features
* Cubic transition between story groups
* Auto video timing animation with time bar
* Story group swiping with sliding screen
* Catch where you left on previosly watched story groups.
* Watched stories marked but not used as functionality, it could be use for further developments.
* After quit the story view, auto sort the story groups.
* Unfinished story groups have green border.
* Finished ones have grey and at end.
* Pause/Continue with hold and release touches. 
<br />



## ~~Unproblematic Downside~~ Has Resolved

* ~~When you pretend to swipe from the current story to another story without lifting the finger and return to the current story, the current story stays in a paused state. If you press and pull the finger back, the story continues. Or you can click right or left to go back and forth. It is a situation that I do not want to happen, but it does not cause any problems to the user.~~
* Demo videos are old ones.

<br />

## Used Packages

* [video_player](https://pub.dev/packages/video_player)
* [flutter_bloc](https://pub.dev/packages/flutter_bloc)
* [provider](https://pub.dev/packages/provider)

<br />

## Installation

1. Download the master branch.
2. In directory which include ```pubspec.yaml```
3. Execute ```flutter pub get```
4. After all dependencies installed succesfully execute ```flutter run lib/main.dart```

<br />

## Test Video

https://github.com/erdnj/InstaStoryViewExample/assets/69752782/0a471243-683e-4beb-a582-837465ba4dda


<br />

## Demo(Old)

* Demo data collected from [Pexels](https://www.pexels.com/) and used as ```Asset Media```.


<br />

https://user-images.githubusercontent.com/69752782/175782724-e0bca585-c08c-4093-8666-cb61d66e21c6.mov

<br />

https://user-images.githubusercontent.com/69752782/175783225-878ce1a3-7bad-4f3c-becc-22622e4561f0.mov


