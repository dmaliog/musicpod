import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:yaru/yaru.dart';

import '../../app.dart';
import '../../build_context_x.dart';
import '../../common.dart';
import '../../constants.dart';
import '../../data.dart';
import '../../get.dart';
import '../../player.dart';
import 'blurred_full_height_player_image.dart';
import 'full_height_player_image.dart';
import 'full_height_player_top_controls.dart';
import 'full_height_title_and_artist.dart';
import 'up_next_bubble.dart';

class FullHeightPlayer extends StatelessWidget with WatchItMixin {
  const FullHeightPlayer({
    super.key,
    required this.audio,
    required this.nextAudio,
    required this.playPrevious,
    required this.playNext,
    required this.playerViewMode,
    required this.videoController,
    required this.isVideo,
    required this.isOnline,
    required this.appModel,
  });

  final Audio? audio;
  final Audio? nextAudio;
  final Future<void> Function() playPrevious;
  final Future<void> Function() playNext;

  final PlayerViewMode playerViewMode;
  final AppModel appModel;

  final VideoController videoController;
  final bool isVideo;
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;
    final size = context.m.size;
    final playerToTheRight = size.width > kSideBarThreshHold;
    final fullScreen = watchPropertyValue((AppModel m) => m.fullScreen);

    final active = audio?.path != null || isOnline;
    final activeControls = audio?.path != null || isOnline;

    final titleAndArtist = FullHeightTitleAndArtist(
      audio: audio,
    );

    const sliderAndTime = PlayerTrack();

    final iconColor = isVideo ? Colors.white : theme.colorScheme.onSurface;

    void onFullScreenPressed() {
      appModel.setFullScreen(
        playerViewMode == PlayerViewMode.fullWindow ? false : true,
      );

      appModel.setShowWindowControls(
        (fullScreen == true && playerToTheRight) ? false : true,
      );
    }

    final bodyWithControls = Stack(
      alignment: Alignment.topRight,
      children: [
        if (isVideo)
          RepaintBoundary(
            child: Video(
              controller: videoController,
            ),
          )
        else
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 35),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  FullHeightPlayerImage(
                    audio: audio,
                    isOnline: isOnline,
                  ),
                  const SizedBox(
                    height: kYaruPagePadding,
                  ),
                  titleAndArtist,
                  const SizedBox(
                    height: kYaruPagePadding,
                  ),
                  const SizedBox(
                    height: kYaruPagePadding,
                    width: 400,
                    child: sliderAndTime,
                  ),
                  const SizedBox(
                    height: kYaruPagePadding,
                  ),
                  PlayerMainControls(
                    podcast: audio?.audioType == AudioType.podcast,
                    playPrevious: playPrevious,
                    playNext: playNext,
                    active: active,
                  ),
                ],
              ),
            ),
          ),
        FullHeightPlayerTopControls(
          audio: audio,
          iconColor: iconColor,
          activeControls: activeControls,
          playerViewMode: playerViewMode,
          onFullScreenPressed: onFullScreenPressed,
          isVideo: isVideo,
        ),
        if (nextAudio?.title != null &&
            nextAudio?.artist != null &&
            !isVideo &&
            size.width > 600)
          Positioned(
            left: 10,
            bottom: 10,
            child: UpNextBubble(
              audio: audio,
              nextAudio: nextAudio,
            ),
          ),
      ],
    );

    final body = isMobile
        ? GestureDetector(
            onVerticalDragEnd: (details) {
              if (details.primaryVelocity != null &&
                  details.primaryVelocity! > 150) {
                appModel.setFullScreen(false);
              }
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 40),
              child: bodyWithControls,
            ),
          )
        : bodyWithControls;

    final headerBar = HeaderBar(
      adaptive: false,
      title: const Text(
        '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      foregroundColor: isVideo == true ? Colors.white : null,
      backgroundColor: isVideo == true ? Colors.black : Colors.transparent,
    );

    final fullHeightPlayer = isVideo
        ? Scaffold(
            backgroundColor: Colors.black,
            appBar: headerBar,
            body: body,
          )
        : Column(
            children: [
              if (!isMobile) headerBar,
              Expanded(
                child: body,
              ),
            ],
          );

    if ((audio?.imageUrl != null ||
            audio?.albumArtUrl != null ||
            audio?.pictureData != null) &&
        isOnline &&
        !isVideo) {
      return Stack(
        children: [
          BlurredFullHeightPlayerImage(
            size: size,
            audio: audio,
          ),
          fullHeightPlayer,
        ],
      );
    }

    return fullHeightPlayer;
  }
}
