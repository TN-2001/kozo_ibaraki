import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// 拡大縮小とパン操作ができる汎用的なウィジェット
class BaseZoomableWidget extends StatefulWidget {
  /// 表示するコンテンツ
  final Widget child;
  
  /// 最小スケール
  final double minScale;
  
  /// 最大スケール
  final double maxScale;
  
  /// 初期スケール
  final double initialScale;
  
  /// マウスホイールの感度
  final double scrollSensitivity;

  const BaseZoomableWidget({
    super.key,
    required this.child,
    this.minScale = 1.0,
    this.maxScale = 4.0,
    this.initialScale = 1.0,
    this.scrollSensitivity = 0.001,
  });

  @override
  State<BaseZoomableWidget> createState() => _ZoomableWidgetState();
}

class _ZoomableWidgetState extends State<BaseZoomableWidget> {
  late TransformationController _transformationController;
  
  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    if (widget.initialScale != 1.0) {
      _transformationController.value = Matrix4.identity()
        ..scale(widget.initialScale);
    }
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  /// マウスホイールでのズーム処理
  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      final delta = event.scrollDelta.dy;
      
      // 現在の変換行列を取得
      final matrix = _transformationController.value.clone();
      
      // 現在のスケールを取得
      final currentScale = matrix.getMaxScaleOnAxis();
      
      // 新しいスケールを計算
      final newScale = (currentScale - delta * widget.scrollSensitivity)
          .clamp(widget.minScale, widget.maxScale);
      
      // スケール変更の比率
      final scaleDelta = newScale / currentScale;
      
      // マウス位置を中心にズーム
      final focalPoint = event.localPosition;
      
      // 変換行列を更新
      final updatedMatrix = _calculateZoomMatrix(
        matrix,
        scaleDelta,
        focalPoint,
      );
      
      setState(() {
        _transformationController.value = updatedMatrix;
      });
    }
  }

  /// ズーム時の変換行列を計算
  Matrix4 _calculateZoomMatrix(
    Matrix4 matrix,
    double scale,
    Offset focalPoint,
  ) {
    final double px = focalPoint.dx;
    final double py = focalPoint.dy;
    
    // フォーカルポイントを原点に移動 → スケール → 元に戻す
    return Matrix4.identity()
      ..translate(px, py)
      ..scale(scale, scale)
      ..translate(-px, -py)
      ..multiply(matrix);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: _handlePointerSignal,
      child: InteractiveViewer(
        transformationController: _transformationController,
        minScale: widget.minScale,
        maxScale: widget.maxScale,
        panEnabled: true,
        scaleEnabled: true,
        child: widget.child,
      ),
    );
  }
}
