// SPDX-FileCopyrightText: 2019-Present Christian Kußowski
// SPDX-FileCopyrightText: 2019-Present Contributors to FluffyChat
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:math' as math;

import 'package:fluffychat/utils/platform_infos.dart';
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
  static const _webWheelDeltaFactor = 0.2;

  final TransformationController _transformationController =
      TransformationController();
  Matrix4? _gestureStartMatrix;
  double? _gestureStartScale;

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  double get _currentScale => _transformationController.value.getMaxScaleOnAxis();

  void _zoomAround(
    Offset focalPoint, {
    required double targetScale,
    Matrix4? baseMatrix,
    double? baseScale,
  }) {
    final currentMatrix = baseMatrix ?? _transformationController.value;
    final currentScale = baseScale ?? currentMatrix.getMaxScaleOnAxis();
    final nextScale = targetScale.clamp(widget.minScale, widget.maxScale);
    if ((nextScale - currentScale).abs() < 0.0001) return;

    final controller = TransformationController(currentMatrix.clone());
    final sceneBefore = controller.toScene(focalPoint);
    controller.value = Matrix4.identity()
      ..translateByDouble(focalPoint.dx, focalPoint.dy, 0, 1)
      ..scaleByDouble(nextScale / currentScale, nextScale / currentScale, 1, 1)
      ..translateByDouble(-focalPoint.dx, -focalPoint.dy, 0, 1)
      ..multiply(currentMatrix);
    final sceneAfter = controller.toScene(focalPoint);
    final correction = sceneAfter - sceneBefore;
    controller.value = controller.value.clone()
      ..translateByDouble(correction.dx, correction.dy, 0, 1);
    _transformationController.value = controller.value;
    controller.dispose();
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _gestureStartMatrix = _transformationController.value.clone();
    _gestureStartScale = _currentScale;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (details.pointerCount < 2) return;
    final startMatrix = _gestureStartMatrix;
    final startScale = _gestureStartScale;
    if (startMatrix == null || startScale == null) return;
    _zoomAround(
      details.localFocalPoint,
      targetScale: startScale * details.scale,
      baseMatrix: startMatrix,
      baseScale: startScale,
    );
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    _gestureStartMatrix = null;
    _gestureStartScale = null;
    widget.onInteractionEnd?.call(details);
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;

    final kind = event.kind;
    if (kind != PointerDeviceKind.mouse && kind != PointerDeviceKind.trackpad) {
      return;
    }

    GestureBinding.instance.pointerSignalResolver.register(event, (event) {
      final scrollEvent = event as PointerScrollEvent;
      final normalizedDelta = scrollEvent.scrollDelta.dy *
          (PlatformInfos.isWeb ? _webWheelDeltaFactor : 1.0);
      final scaleDelta = math.exp(-normalizedDelta * _mouseWheelScaleStep);
      _zoomAround(
        scrollEvent.localPosition,
        targetScale: _currentScale * scaleDelta,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onScaleStart: _handleScaleStart,
      onScaleUpdate: _handleScaleUpdate,
      onScaleEnd: _handleScaleEnd,
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerSignal: _handlePointerSignal,
        child: InteractiveViewer(
          transformationController: _transformationController,
          minScale: widget.minScale,
          maxScale: widget.maxScale,
          scaleEnabled: false,
          trackpadScrollCausesScale: false,
          onInteractionEnd: widget.onInteractionEnd,
          child: widget.child,
        ),
      ),
    );
  }
}
