// SPDX-FileCopyrightText: 2019-Present Christian Kußowski
// SPDX-FileCopyrightText: 2019-Present Contributors to FluffyChat
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:fluffychat/pages/image_viewer/video_player.dart';
import 'package:fluffychat/widgets/mxc_image.dart';
import 'package:fluffychat/widgets/zoomable_media_view.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import 'image_viewer.dart';
import 'image_viewer_policy.dart';

class ImageViewerMediaGrid extends StatelessWidget {
  final ImageViewerController controller;

  const ImageViewerMediaGrid(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    if (ImageViewerPolicy.isMobile) {
      return _mobileImageGrid();
    }
    return _desktopImageGrid();
  }

  Widget _mobileImageGrid() {
    return PhotoViewGallery.builder(
      scrollDirection: Axis.vertical,
      pageController: controller.pageController,
      scrollPhysics: const AlwaysScrollableScrollPhysics(),
      itemCount: controller.allEvents.length,
      onPageChanged: controller.onPageChanged,
      builder: (context, i) {
        final event = controller.allEvents[i];
        switch (event.messageType) {
          case MessageTypes.Video:
            return PhotoViewGalleryPageOptions.customChild(
              child: Padding(
                padding: const EdgeInsets.only(top: 52.0),
                child: Center(
                  child: GestureDetector(
                    onTap: () {},
                    child: EventVideoPlayer(event),
                  ),
                ),
              ),
              disableGestures: true,
              heroAttributes: PhotoViewHeroAttributes(tag: event.eventId),
            );
          case MessageTypes.Image:
          case MessageTypes.Sticker:
          default:
            return PhotoViewGalleryPageOptions.customChild(
              minScale: PhotoViewComputedScale.contained,
              initialScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 3,
              heroAttributes: PhotoViewHeroAttributes(tag: event.eventId),
              child: GestureDetector(
                onTap: () {},
                child: MxcImage(
                  key: ValueKey(event.eventId),
                  event: event,
                  fit: BoxFit.contain,
                  isThumbnail: false,
                  animated: true,
                ),
              ),
            );
        }
      },
      backgroundDecoration: const BoxDecoration(
        color: Colors.transparent,
      ),
    );
  }

  Widget _desktopImageGrid() {
    return PageView.builder(
      scrollDirection: Axis.vertical,
      controller: controller.pageController,
      physics: ImageViewerPolicy.pageViewPhysics(),
      itemCount: controller.allEvents.length,
      onPageChanged: controller.onPageChanged,
      itemBuilder: (context, i) {
        final event = controller.allEvents[i];
        switch (event.messageType) {
          case MessageTypes.Video:
            return Padding(
              padding: const EdgeInsets.only(top: 52.0),
              child: Center(
                child: GestureDetector(
                  onTap: () {},
                  child: EventVideoPlayer(event),
                ),
              ),
            );
          case MessageTypes.Image:
          case MessageTypes.Sticker:
          default:
            return ZoomableMediaView(
              minScale: 1.0,
              maxScale: 10.0,
              onInteractionEnd: controller.onInteractionEnds,
              child: Center(
                child: Hero(
                  tag: event.eventId,
                  child: GestureDetector(
                    onTap: () {},
                    child: MxcImage(
                      key: ValueKey(event.eventId),
                      event: event,
                      fit: BoxFit.contain,
                      isThumbnail: false,
                      animated: true,
                    ),
                  ),
                ),
              ),
            );
        }
      },
    );
  }
}
