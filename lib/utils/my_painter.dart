import 'dart:math';
import 'package:flutter/material.dart';
import 'my_calculator.dart';

class MyPainter
{
  // 数字を文字にする
  static String doubleToString(double value, int digit) {
    // 数字を桁数(digit)分を文字にする
    String text;
    if(value == 0.0) {
      text = " 0";
    } else if(value.abs() >= 1.0 * pow(10, -(digit-1))) {
      text = value.toStringAsPrecision(digit);
    } else {
      text = value.toStringAsExponential(digit-1);
    }

    // -の分のスペースを開ける
    if(value > 0) {
      text = " $text";
    }

    return text;
  }

  // 色0～100
  static Color getColor(double par){
    Color color = const Color.fromARGB(255, 255, 0, 0);
    color = const Color.fromARGB(255, 255, 255, 0);
    color = const Color.fromARGB(255, 0, 255, 0);
    color = const Color.fromARGB(255, 0, 255, 255);
    color = const Color.fromARGB(255, 0, 0, 255);

    color = const Color.fromARGB(255, 255, 0, 0);

    double get = par / 100 * 4;
    if(get <= 1){
      color = Color.fromARGB(255, 0, (255 * get).toInt(), 255);
    }
    else if(get > 1 && get <= 2){
      get -= 1;
      color = Color.fromARGB(255, 0, 255, (255 - 255 * get).toInt());
    }
    else if(get > 2 && get <= 3){
      get -= 2;
      color = Color.fromARGB(255, (255 * get).toInt(), 255, 0);
    }
    else if(get > 3 && get <= 4){
      get -= 3;
      color = Color.fromARGB(255, 255, (255 - 255 * get).toInt(), 0);
    }

    return color;
  }


  // 矢印
  static void arrow(Offset start, end, double width, Color color, Canvas canvas,{double? lineWidth}){
    Paint p = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeWidth = lineWidth != null ? 2 * lineWidth : 2 * width;
    
    if(start.dx > end.dx){
      canvas.drawLine(start, Offset(end.dx+4.3*width, end.dy), p);
    }else if(start.dx < end.dx){
      canvas.drawLine(start, Offset(end.dx-4.3*width, end.dy), p);
    }else if(start.dy > end.dy){
      canvas.drawLine(start, Offset(end.dx, end.dy+4.3*width), p);
    }else if(start.dy < end.dy){
      canvas.drawLine(start, Offset(end.dx, end.dy-4.3*width), p);
    }

    p.strokeWidth = 2 * width;

    double arrowSize = 5 * width;
    const arrowAngle = pi / 6;

    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final angle = atan2(dy, dx);

    final path = Path();
    path.moveTo(
      end.dx - arrowSize * cos(angle - arrowAngle),
      end.dy - arrowSize * sin(angle - arrowAngle),
    );
    path.lineTo(end.dx, end.dy);
    path.lineTo(
      end.dx - arrowSize * cos(angle + arrowAngle),
      end.dy - arrowSize * sin(angle + arrowAngle),
    );
    path.close();
    canvas.drawPath(path, p);
  }

  // 2点間を繋ぐ角度自由の長方形
  static void angleRectangle(Canvas canvas, Offset p0, Offset p1, double width, Color color, bool isfull){
    final paint = Paint()
      ..color = color;
    if(!isfull) paint.style = PaintingStyle.stroke;

    var p = MyCalculator.angleRectanglePos(p0, p1, width);

    Offset topLeft = p.$1;
    Offset topRight = p.$2;
    Offset bottomRight = p.$3;
    Offset bottomLeft = p.$4;

    Path path = Path();
    path.moveTo(topLeft.dx, topLeft.dy);
    path.lineTo(topRight.dx, topRight.dy);
    path.lineTo(bottomRight.dx, bottomRight.dy);
    path.lineTo(bottomLeft.dx, bottomLeft.dy);
    path.close();

    canvas.drawPath(path, paint);
  }

  // 多角形
  static void polygon(Canvas canvas, List<Offset> offsetList, Color color, bool isfull){
    final paint = Paint()
      ..color = color;
    if(!isfull) paint.style = PaintingStyle.stroke;

    final path = Path();
    for(int i = 0; i < offsetList.length; i++){
      if(i == 0){
        path.moveTo(offsetList[i].dx, offsetList[i].dy);
      }
      else{
        path.lineTo(offsetList[i].dx, offsetList[i].dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  // 虹色帯
  static void rainbowBand(Canvas canvas, Rect rect, int number){
    final double minX = rect.left;
    final double maxX = rect.right;
    final double minY = rect.top;
    final double maxY = rect.bottom;
  
    final paint = Paint();

    if(rect.height > rect.width){
      for(int i = 0; i < number; i++){
        paint.color = getColor((number-i)/number * 100);
        final path = Path();
        path.moveTo(maxX, (maxY - minY) / number * i + minY);
        path.lineTo(maxX, (maxY - minY) / number * (i+1) + minY);
        path.lineTo(minX, (maxY - minY) / number * (i+1) + minY);
        path.lineTo(minX, (maxY - minY) / number * i + minY);
        path.close();
        canvas.drawPath(path, paint);
      }
    }else{
      for(int i = 0; i < number; i++){
        paint.color = getColor(i/number * 100);
        final path = Path();
        path.moveTo((maxX - minX) / number * i + minX, minY);
        path.lineTo((maxX - minX) / number * (i+1) + minX, minY);
        path.lineTo((maxX - minX) / number * (i+1) + minX, maxY);
        path.lineTo((maxX - minX) / number * i + minX, maxY);
        path.close();
        canvas.drawPath(path, paint);
      }
    }
  }

  // 文字
  static void text(
    Canvas canvas, 
    Offset offset, 
    String text, 
    double fontSize, 
    Color color, 
    bool isOutline, 
    double width,
    {Alignment alignment = Alignment.topLeft}) {
  
    Offset alignOffset(Offset base, TextPainter tp, Alignment align) {
      return base - Offset(tp.width * (align.x + 1) / 2, tp.height * (align.y + 1) / 2);
    }

    if(isOutline) {
      final textSpanOutline = TextSpan(
        text: text,
        style: TextStyle(
          foreground: Paint()
            ..style = PaintingStyle.stroke // 輪郭（りんかく）
            ..strokeWidth = 5 // 輪郭の太さ
            ..strokeJoin = StrokeJoin.round // 輪郭の角を滑らかに
            ..color = Colors.white,
          fontSize: fontSize,
        ),
      );
      final textPainterOutline = TextPainter(
        text: textSpanOutline,
        textDirection: TextDirection.ltr,
      );
      textPainterOutline.layout(
        minWidth: 0,
        maxWidth: width,
      );
      textPainterOutline.paint(canvas, alignOffset(offset, textPainterOutline, alignment));
    }
    
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: width,
    );
    textPainter.paint(canvas, alignOffset(offset, textPainter, alignment));
  }

  // 正三角形
  static void triangleEquilateral(Offset offset, double height, double angle, Paint paint, Canvas canvas) {
    double lineLength = height / cos(pi/6);
    final path = Path();
    path.moveTo(offset.dx, offset.dy);
    path.lineTo(offset.dx - lineLength * cos(angle - pi/6), offset.dy + lineLength * sin(angle - pi/6));
    path.lineTo(offset.dx - lineLength * cos(angle + pi/6), offset.dy + lineLength * sin(angle + pi/6));
    path.close();
    canvas.drawPath(path, paint);
  }

  // メモリ
  static void memory(Canvas canvas, Rect rect, double max, double min, double value, bool isReverse) {
    Paint paint = Paint();

    double diff = max - min; // 値の間隔
    if(diff == 0.0) return; 

    // 値の範囲に応じた拡大率を計算
    double digitScale = 1.0;
    if (diff > 10.0) {
      while (diff > 10.0) {
        diff /= 10.0;
        digitScale /= 10.0;
      }
    } else if (diff < 1.0 && diff > 0) {
      while (diff < 1.0) {
        diff *= 10.0;
        digitScale *= 10.0;
      }
    }

    double maxScale = max * digitScale;
    double nextValue = value * digitScale;
    maxScale = double.parse(maxScale.toStringAsFixed(3));
    nextValue = double.parse(nextValue.toStringAsFixed(3));

    if((maxScale*100).toInt() % (nextValue*100).toInt() != 0) {
      maxScale = ((maxScale / nextValue).floor()) * nextValue;
    }

    maxScale /= digitScale;
    nextValue /= digitScale;
    diff /= digitScale;

    canvas.drawLine(rect.topCenter, rect.bottomCenter, paint);

    for (int i = 0; ; i++) {
      double value = maxScale - i * nextValue;
      if (value < min - 1/(digitScale*100)) break;

      Offset p = Offset.zero;
      if(!isReverse) {
        p = Offset(rect.center.dx, rect.top + (max - value) / diff * rect.height);
      } else {
        p = Offset(rect.center.dx, rect.top + (value - min) / diff * rect.height);
      }
      canvas.drawLine(Offset(rect.center.dx - 5, p.dy), Offset(rect.center.dx + 5, p.dy), paint);

      String label;
      if(value.abs() <= 1/(digitScale*100)) {
        label = " 0";
      } else {
        label = doubleToString(value, 2);
      }

      text(canvas, Offset(rect.center.dx + 10, p.dy-13), label, 16, Colors.black, false, 500);
    }
  }

  // ローラー支点
  static void roller(Canvas canvas, Offset pos, double angle, {double radius = 5, double? lineWidth}) {
    // pos を中心に回転
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(angle); // ラジアン単位

    Paint paint = Paint()
      ..color = const Color.fromARGB(255, 0, 0, 0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    // 円の半径
    double newRadius = radius;
    // ラインの幅
    double newlineWidth = lineWidth ?? radius * 4;

    // 支点（円）
    canvas.drawCircle(Offset(0, newRadius), newRadius, paint);
    // 地面ライン
    canvas.drawLine(
      Offset(newlineWidth / 2, newRadius * 2),
      Offset(-newlineWidth / 2, newRadius * 2),
      paint,
    );

    canvas.restore();
  }

  // 矢印
  static void arrow2(Canvas canvas, Offset start, Offset end, 
    {double headSize = 20, double? lineWidth, Color color = const Color.fromARGB(255, 0, 0, 0)}) {

    Paint paint = Paint()
    ..color = color
    ..style = PaintingStyle.fill
    ..strokeWidth = lineWidth ?? headSize / 2.5;


    // 方向ベクトル
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final angle = atan2(dy, dx);

    // 本体の線
    canvas.drawLine(start, Offset(end.dx - headSize * cos(angle) / 1.7, end.dy - headSize * sin(angle) / 1.7), paint);

    // 矢じりの両側を計算
    final path = Path();
    path.moveTo(end.dx, end.dy);
    path.lineTo(
      end.dx - headSize * cos(angle - pi / 6),
      end.dy - headSize * sin(angle - pi / 6),
    );
    path.lineTo(
      end.dx - headSize * cos(angle + pi / 6),
      end.dy - headSize * sin(angle + pi / 6),
    );
    path.close();

    canvas.drawPath(path, paint);
  }
}