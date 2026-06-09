// SPDX-FileCopyrightText: 2019-Present Christian Kußowski
// SPDX-FileCopyrightText: 2019-Present Contributors to FluffyChat
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class ZoomableMediaView extends StatefulWidget {
  const ZoomableMediaView({
    required this.child,
    this.minScale = 1.0,
    this.maxScale = 10.0,
    this.onInteractionEnd,
    super.key,
  });

  final Widget child;
  final double minScale;
  final double maxScale;
  final GestureScaleEndCallback? onInteractionEnd;

  @override
  State<ZoomableMediaView> createState() => _ZoomableMediaViewState();
}

class _ZoomableMediaViewState extends State<ZoomableMediaView> {
  static const _mouseWheelScaleStep = 0.0007;

  final TransformationController _transformationController =
      TransformationController();

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  double get _currentScale => _transformationController.value.getMaxScaleOnAxis();

  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;

    final kind = event.kind;
    if (kind != PointerDeviceKind.mouse && kind != PointerDeviceKind.trackpad) {
      return;
    }

    GestureBinding.instance.pointerSignalResolver.register(event, (event) {
      final scrollEvent = event as PointerScrollEvent;
      final scaleDelta = math.exp(
        -scrollEvent.scrollDelta.dy * _mouseWheelScaleStep,
      );
      final currentScale = _currentScale;
      final nextScale = (currentScale * scaleDelta).clamp(
        widget.minScale,
        widget.maxScale,
      );
      if ((nextScale - currentScale).abs() < 0.0001) return;

      final focalPoint = scrollEvent.localPosition;
      final sceneBefore = _transformationController.toScene(focalPoint);
      final zoomFactor = nextScale / currentScale;
      final matrix = Matrix4.identity()
        ..translateByDouble(focalPoint.dx, focalPoint.dy, 0, 1)
        ..scaleByDouble(zoomFactor, zoomFactor, 1, 1)
        ..translateByDouble(-focalPoint.dx, -focalPoint.dy, 0, 1)
        ..multiply(_transformationController.value);
      _transformationController.value = matrix;
      final sceneAfter = _transformationController.toScene(focalPoint);
      final correction = sceneAfter - sceneBefore;
      _transformationController.value = _transformationController.value.clone()
        ..translateByDouble(correction.dx, correction.dy, 0, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerSignal: _handlePointerSignal,
      child: InteractiveViewer(
        transformationController: _transformationController,
        minScale: widget.minScale,
        maxScale: widget.maxScale,
        trackpadScrollCausesScale: false,
        onInteractionEnd: widget.onInteractionEnd,
        child: widget.child,
      ),
    );
  }
}
