import 'package:flutter/material.dart';

class Camera {
  Camera(this.scale, this.worldPos, this.screenPos);

  double scale; // 拡大率
  Offset worldPos; // ワールド上のカメラの位置
  Offset screenPos; // スクリーンの上のカメラの位置

  void init(double scale, Offset worldPos, Offset screenPos) {
    this.scale = scale;
    this.worldPos = worldPos;
    this.screenPos = screenPos;
  }

  // ワールド座標をスクリーン座標に変換
  Offset worldToScreen(Offset pos) {
    Offset newPos = Offset(pos.dx - worldPos.dx, pos.dy - worldPos.dy);
    newPos = Offset(newPos.dx * scale, newPos.dy * scale);
    newPos = Offset(newPos.dx + screenPos.dx, - newPos.dy + screenPos.dy);
    return newPos;
  }

  // スクリーン座標をワールド座標に変換
  Offset screenToWorld(Offset pos) {
    // print(pos);
    Offset newPos = Offset(pos.dx - screenPos.dx, -(pos.dy - screenPos.dy));
    // print(newPos);
    newPos = Offset(newPos.dx / scale, newPos.dy / scale);
    // print(scale);
    newPos = Offset(newPos.dx + worldPos.dx, newPos.dy + worldPos.dy);
    return newPos;
  }
}